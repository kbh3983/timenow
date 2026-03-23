import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'splash_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error getting cameras: $e');
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
        fontFamily: 'NanumSquareB',
      ),
      home: SplashScreen(cameras: cameras),
    );
  }
}
