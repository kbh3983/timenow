// 시각 검증용: 샘플 스탬프를 원본 좌표(390x390 캔버스) 그대로 PNG 로 렌더링합니다.
// 실행: flutter test tool/render_sample_stamps_test.dart  (결과: build/sample_stamp_renders/)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timenow/stamps/sample_stamp_renderer.dart';
import 'package:timenow/timestamp_overlays.dart';

Future<void> _loadFonts() async {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final re = RegExp(r'- family: (\S+)\s+fonts:\s+- asset: (\S+)');
  for (final m in re.allMatches(pubspec)) {
    final loader = FontLoader(m.group(1)!);
    final bytes = File(m.group(2)!).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('render', (tester) async {
    await tester.runAsync(() async {
      await _loadFonts();
      final out = Directory('build/sample_stamp_renders')..createSync(recursive: true);
      final now = DateTime(2022, 9, 19, 20, 41);
      final only = Platform.environment['STAMPS']?.split(',');
      for (final d in TimestampDesign.values.where((d) => d.isSampleStamp)) {
        if (only != null && !only.contains(d.name)) continue;
        final count = SampleStampLibrary.scaleCount(d.name);
        final scene = SampleStampLibrary.buildScene(d.name,
            scaleIndex: count >= 3 ? 1 : 0, now: now);
        await SampleStampImageCache.loadAll(scene.imagePaths);
        final rec = ui.PictureRecorder();
        final canvas = Canvas(rec);
        const px = 2.0;
        canvas.scale(px);
        canvas.drawRect(const Rect.fromLTWH(0, 0, 390, 390), Paint()..color = const Color(0xFF555B66));
        for (final e in scene.elements) {
          e.paint(canvas, SampleStampImageCache.images);
        }
        final img = await rec.endRecording().toImage((390 * px).toInt(), (390 * px).toInt());
        final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
        File('${out.path}/${d.name}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      }
    });
  });
}

