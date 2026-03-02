import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error getting cameras: $e');
    // 카메라 없어도 UI는 볼 수 있도록 빈 리스트로 계속 진행
  }
  runApp(const TimenowApp());
}

class TimenowApp extends StatelessWidget {
  const TimenowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timenow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      // 카메라 유무와 관계없이 항상 CameraScreen 표시 (UI 테스트 가능)
      home: CameraScreen(cameras: cameras),
    );
  }
}
