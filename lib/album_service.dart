import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';

class MonthAlbumData {
  final Map<DateTime, File> thumbnails;
  final Map<DateTime, int> counts;
  final Map<DateTime, List<File>> photosByDate;

  MonthAlbumData({
    required this.thumbnails,
    required this.counts,
    required this.photosByDate,
  });
}

class AlbumService {
  static Future<Directory> get _photosRoot async {
    final docs = await getApplicationDocumentsDirectory();
    final root = Directory('${docs.path}/photos');
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  /// Extract DateTime from photo/video filename (photo_XXXXX.jpg or video_XXXXX.mp4 → DateTime).
  /// Falls back to file modified time if filename parsing fails.
  static DateTime getPhotoDate(File file) {
    final name = file.path.split(Platform.pathSeparator).last;
    final match = RegExp(r'(photo|video)_(\d+)\.').firstMatch(name);
    if (match != null) {
      final ms = int.tryParse(match.group(2)!);
      if (ms != null) {
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
    }
    // Fallback to file modified time
    return file.statSync().modified;
  }

  static bool isVideo(File file) {
    final path = file.path.toLowerCase();
    return path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi');
  }

  static bool isMediaFile(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('_thumb.jpg')) return false;
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.avi');
  }

  static Future<List<String>> getAlbums() async {
    final root = await _photosRoot;
    final entities = await root.list().toList();
    final albums = entities
        .whereType<Directory>()
        .map((e) => e.path.split(Platform.pathSeparator).last)
        .toList();

    // Default '일상' folder (항상 기본 앨범으로 제공)
    if (!albums.contains('일상')) {
      await Directory('${root.path}/일상').create();
      albums.add('일상');
      // Set default color for '일상' if not exists
      final colors = await getAlbumColors();
      if (!colors.containsKey('일상')) {
        await saveAlbumColor('일상', 0xFFEDED6D); // Soft Yellow for '일상'
      }
    }
    return albums;
  }

  static Future<Map<String, int>> getAlbumColors() async {
    final root = await _photosRoot;
    final file = File('${root.path}/album_colors.json');
    if (!await file.exists()) return {};
    try {
      final content = await file.readAsString();
      final Map<String, dynamic> json = jsonDecode(content);
      return json.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {};
    }
  }

  static Future<void> saveAlbumColor(String name, int colorValue) async {
    final root = await _photosRoot;
    final file = File('${root.path}/album_colors.json');
    Map<String, int> colors = await getAlbumColors();
    colors[name] = colorValue;
    await file.writeAsString(jsonEncode(colors));
  }

  static Future<void> createAlbum(String name, {int? colorValue}) async {
    final root = await _photosRoot;
    final dir = Directory('${root.path}/$name');
    if (!await dir.exists()) {
      await dir.create();
    }
    if (colorValue != null) {
      await saveAlbumColor(name, colorValue);
    }
  }

  static Future<void> deleteAlbum(String name) async {
    final root = await _photosRoot;
    final dir = Directory('${root.path}/$name');

    if (await dir.exists()) {
      // 기기 시스템 갤러리(Media Storage)에 이미 안전하게 저장되어 있으므로
      // 앱 내 특정 폴더 삭제 시 해당 폴더만 깔끔하게 제거 ('일상'으로 이전하지 않음)
      await dir.delete(recursive: true);
    }

    final file = File('${root.path}/album_colors.json');
    if (await file.exists()) {
      try {
        final colors = await getAlbumColors();
        if (colors.containsKey(name)) {
          colors.remove(name);
          await file.writeAsString(jsonEncode(colors));
        }
      } catch (_) {}
    }
  }

  static Future<bool> updateAlbum({
    required String oldName,
    required String newName,
    required int colorValue,
  }) async {
    final root = await _photosRoot;
    if (oldName != newName) {
      final oldDir = Directory('${root.path}/$oldName');
      final newDir = Directory('${root.path}/$newName');

      if (await newDir.exists()) {
        return false; // 이미 존재하는 폴더명
      }

      if (await oldDir.exists()) {
        await oldDir.rename(newDir.path);
      } else {
        await newDir.create();
      }

      // 색상 json에서 oldName 삭제 및 newName 저장
      final file = File('${root.path}/album_colors.json');
      try {
        final colors = await getAlbumColors();
        colors.remove(oldName);
        colors[newName] = colorValue;
        await file.writeAsString(jsonEncode(colors));
      } catch (_) {}
    } else {
      // 색상만 변경
      await saveAlbumColor(oldName, colorValue);
    }
    return true;
  }

  static Future<void> savePhoto(Uint8List bytes, String albumName, {DateTime? originalDate}) async {
    final root = await _photosRoot;
    final albumDir = Directory('${root.path}/$albumName');
    if (!await albumDir.exists()) {
      await albumDir.create();
    }

    // Compress PNG → JPEG quality 85 for ~5-10x size reduction
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 85,
      format: CompressFormat.jpeg,
    );

    final timestamp = originalDate ?? DateTime.now();
    final filename = 'photo_${timestamp.millisecondsSinceEpoch}.jpg';
    final file = File('${albumDir.path}/$filename');
    await file.writeAsBytes(compressed);
  }

  static Future<File> saveVideo(File videoFile, String albumName, {DateTime? originalDate}) async {
    final root = await _photosRoot;
    final albumDir = Directory('${root.path}/$albumName');
    if (!await albumDir.exists()) {
      await albumDir.create();
    }

    final timestamp = originalDate ?? DateTime.now();
    final filename = 'video_${timestamp.millisecondsSinceEpoch}.mp4';
    final targetFile = File('${albumDir.path}/$filename');
    await videoFile.copy(targetFile.path);

    // 썸네일 미리 생성
    try {
      await getVideoThumbnail(targetFile);
    } catch (_) {}

    return targetFile;
  }

  /// 비디오 파일의 첫 프레임 썸네일 파일 반환 (없으면 FFmpeg로 추출)
  static Future<File?> getVideoThumbnail(File videoFile) async {
    final thumbPath = '${videoFile.path}_thumb.jpg';
    final thumbFile = File(thumbPath);
    if (await thumbFile.exists()) {
      return thumbFile;
    }

    try {
      final cmd = '-y -ss 00:00:00.100 -i "${videoFile.path}" -vframes 1 -q:v 2 "$thumbPath"';
      await FFmpegKit.execute(cmd);
      if (await thumbFile.exists()) {
        return thumbFile;
      }
    } catch (e) {
      debugPrint('getVideoThumbnail error: $e');
    }
    return null;
  }

  static Future<Map<DateTime, Set<String>>> getPhotoDotsForMonth(
    DateTime month, {
    String? albumName,
  }) async {
    final root = await _photosRoot;
    final Map<DateTime, Set<String>> dots = {};

    List<Directory> targetDirs = [];
    if (albumName == null || albumName == '전체') {
      final entities = await root.list().toList();
      targetDirs = entities.whereType<Directory>().toList();
    } else {
      targetDirs = [Directory('${root.path}/$albumName')];
    }

    for (var dir in targetDirs) {
      if (!await dir.exists()) continue;
      final currentAlbumName = dir.path.split(Platform.pathSeparator).last;
      final files = await dir.list().toList();
      for (var file in files) {
        if (file is File && isMediaFile(file)) {
          final photoDate = getPhotoDate(file);
          final date = DateTime(
            photoDate.year,
            photoDate.month,
            photoDate.day,
          );
          if (date.year == month.year && date.month == month.month) {
            dots.putIfAbsent(date, () => {}).add(currentAlbumName);
          }
        }
      }
    }
    return dots;
  }

  /// Single-pass loader for month photos: thumbnails, counts, and day groupings.
  static Future<MonthAlbumData> getMonthAlbumData(
    DateTime month, {
    String? albumName,
  }) async {
    final root = await _photosRoot;
    final Map<DateTime, List<File>> dateFiles = {};

    List<Directory> targetDirs = [];
    if (albumName == null || albumName == '전체') {
      final entities = await root.list().toList();
      targetDirs = entities.whereType<Directory>().toList();
    } else {
      targetDirs = [Directory('${root.path}/$albumName')];
    }

    for (var dir in targetDirs) {
      if (!await dir.exists()) continue;
      final files = await dir.list().toList();
      for (var file in files) {
        if (file is File && isMediaFile(file)) {
          final photoDate = getPhotoDate(file);
          final date = DateTime(
            photoDate.year,
            photoDate.month,
            photoDate.day,
          );
          if (date.year == month.year && date.month == month.month) {
            dateFiles.putIfAbsent(date, () => []).add(file);
          }
        }
      }
    }

    final Map<DateTime, File> thumbnails = {};
    final Map<DateTime, int> counts = {};

    for (var entry in dateFiles.entries) {
      entry.value.sort(
        (a, b) => getPhotoDate(b).compareTo(getPhotoDate(a)),
      );
      thumbnails[entry.key] = entry.value.first;
      counts[entry.key] = entry.value.length;
    }

    return MonthAlbumData(
      thumbnails: thumbnails,
      counts: counts,
      photosByDate: dateFiles,
    );
  }

  /// Returns the most recent photo file for each date in the given month.
  static Future<Map<DateTime, File>> getPhotoThumbnailsForMonth(
    DateTime month, {
    String? albumName,
  }) async {
    final data = await getMonthAlbumData(month, albumName: albumName);
    return data.thumbnails;
  }

  /// Returns the number of photos for each date in the given month.
  static Future<Map<DateTime, int>> getPhotoCountsForMonth(
    DateTime month, {
    String? albumName,
  }) async {
    final root = await _photosRoot;
    final Map<DateTime, int> counts = {};

    List<Directory> targetDirs = [];
    if (albumName == null || albumName == '전체') {
      final entities = await root.list().toList();
      targetDirs = entities.whereType<Directory>().toList();
    } else {
      targetDirs = [Directory('${root.path}/$albumName')];
    }

    for (var dir in targetDirs) {
      if (!await dir.exists()) continue;
      final files = await dir.list().toList();
      for (var file in files) {
        if (file is File && isMediaFile(file)) {
          final photoDate = getPhotoDate(file);
          final date = DateTime(
            photoDate.year,
            photoDate.month,
            photoDate.day,
          );
          if (date.year == month.year && date.month == month.month) {
            counts[date] = (counts[date] ?? 0) + 1;
          }
        }
      }
    }
    return counts;
  }

  static Future<List<File>> getPhotosByDate(
    DateTime date, {
    String? albumName,
  }) async {
    final root = await _photosRoot;
    final List<File> result = [];

    List<Directory> targetDirs = [];
    if (albumName == null || albumName == '전체') {
      final entities = await root.list().toList();
      targetDirs = entities.whereType<Directory>().toList();
    } else {
      targetDirs = [Directory('${root.path}/$albumName')];
    }

    for (var dir in targetDirs) {
      if (!await dir.exists()) continue;
      final files = await dir.list().toList();
      for (var file in files) {
        if (file is File && isMediaFile(file)) {
          final photoDate = getPhotoDate(file);
          final fileDate = DateTime(
            photoDate.year,
            photoDate.month,
            photoDate.day,
          );
          if (DateUtils.isSameDay(fileDate, date)) {
            result.add(file);
          }
        }
      }
    }

    // Sort by timestamp (newest first)
    result.sort((a, b) => getPhotoDate(b).compareTo(getPhotoDate(a)));
    return result;
  }

  static Future<List<File>> getAllPhotos({String? albumName}) async {
    final root = await _photosRoot;
    final List<File> result = [];

    List<Directory> targetDirs = [];
    if (albumName == null || albumName == '전체') {
      final entities = await root.list().toList();
      targetDirs = entities.whereType<Directory>().toList();
    } else {
      targetDirs = [Directory('${root.path}/$albumName')];
    }

    for (var dir in targetDirs) {
      if (!await dir.exists()) continue;
      final files = await dir.list().toList();
      for (var file in files) {
        if (file is File && isMediaFile(file)) {
          result.add(file);
        }
      }
    }

    // Sort by timestamp (newest first)
    result.sort((a, b) => getPhotoDate(b).compareTo(getPhotoDate(a)));
    return result;
  }

  /// Returns photos grouped by "yyyy.MM" with filename-parsed dates (zero statSync I/O)
  static Future<Map<String, List<File>>> getAllPhotosGrouped({
    String? albumName,
  }) async {
    final allPhotos = await getAllPhotos(albumName: albumName);
    final Map<String, List<File>> grouped = {};
    for (var file in allPhotos) {
      final date = getPhotoDate(file);
      final key = "${date.year}.${date.month.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(key, () => []).add(file);
    }
    return grouped;
  }

  // ───── Photo Note (Caption) Persistence ─────

  static Future<Map<String, String>> getAllNotes() async {
    final root = await _photosRoot;
    final file = File('${root.path}/photo_notes.json');
    if (!await file.exists()) return {};
    try {
      final content = await file.readAsString();
      final Map<String, dynamic> json = jsonDecode(content);
      return json.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  static Future<String?> getNote(String photoPath) async {
    final notes = await getAllNotes();
    final fileName = photoPath.split(Platform.pathSeparator).last;
    return notes[fileName] ?? notes[photoPath];
  }

  static Future<void> saveNote(String photoPath, String note) async {
    final root = await _photosRoot;
    final file = File('${root.path}/photo_notes.json');
    final notes = await getAllNotes();
    final fileName = photoPath.split(Platform.pathSeparator).last;
    if (note.trim().isEmpty) {
      notes.remove(fileName);
      notes.remove(photoPath);
    } else {
      notes[fileName] = note.trim();
    }
    await file.writeAsString(jsonEncode(notes));
  }

  static Future<void> deleteNote(String photoPath) async {
    final root = await _photosRoot;
    final file = File('${root.path}/photo_notes.json');
    final notes = await getAllNotes();
    final fileName = photoPath.split(Platform.pathSeparator).last;
    notes.remove(fileName);
    notes.remove(photoPath);
    await file.writeAsString(jsonEncode(notes));
  }
}
