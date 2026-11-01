import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/ad_service.dart';
import 'services/timestamp_access_manager.dart';
import 'services/timestamp_deck_manager.dart';
import 'splash_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable edge-to-edge system UI (draw behind navigation bar)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  await initializeDateFormatting('ko_KR', null);
  
  // Initialize Services
  try {
    await AdService.initialize();
    await TimestampAccessManager().init();
    await TimestampDeckManager().init();
  } catch (e) {
    debugPrint('Init error: $e');
  }

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1013),
        canvasColor: const Color(0xFF0F1013),
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF17191E),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC6FF00),
          surface: Color(0xFF0F1013),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        useMaterial3: true,
        fontFamily: 'NanumSquareB',
      ),
      home: SplashScreen(cameras: cameras),
    );
  }
}
