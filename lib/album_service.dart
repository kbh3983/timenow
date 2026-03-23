import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AlbumService {
  static Future<Directory> get _photosRoot async {
    final docs = await getApplicationDocumentsDirectory();
    final root = Directory('${docs.path}/photos');
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  static Future<List<String>> getAlbums() async {
    final root = await _photosRoot;
    final entities = await root.list().toList();
    final albums = entities
        .whereType<Directory>()
        .map((e) => e.path.split(Platform.pathSeparator).last)
        .toList();

    // Default '일상' folder
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

  static Future<void> savePhoto(Uint8List bytes, String albumName) async {
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

    final filename = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('${albumDir.path}/$filename');
    await file.writeAsBytes(compressed);
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
        if (file is File) {
          final stats = await file.stat();
          final date = DateTime(
            stats.changed.year,
            stats.changed.month,
            stats.changed.day,
          );
          if (date.year == month.year && date.month == month.month) {
            dots.putIfAbsent(date, () => {}).add(currentAlbumName);
          }
        }
      }
    }
    return dots;
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
        if (file is File) {
          final stats = await file.stat();
          final fileDate = DateTime(
            stats.changed.year,
            stats.changed.month,
            stats.changed.day,
          );
          if (DateUtils.isSameDay(fileDate, date)) {
            result.add(file);
          }
        }
      }
    }

    // Sort by timestamp (newest first)
    result.sort((a, b) => b.statSync().changed.compareTo(a.statSync().changed));
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
        if (file is File) {
          result.add(file);
        }
      }
    }

    // Sort by timestamp (newest first)
    result.sort((a, b) => b.statSync().changed.compareTo(a.statSync().changed));
    return result;
  }
}
