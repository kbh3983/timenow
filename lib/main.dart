import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:camera/camera.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/ad_service.dart';
import 'services/app_localizations.dart';
import 'services/app_settings_service.dart';
import 'services/timestamp_access_manager.dart';
import 'services/timestamp_deck_manager.dart';
import 'stamps/stamp_text_store.dart';
import 'camera_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock app orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Enable edge-to-edge system UI (draw behind navigation bar)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Initialize date formatting for all supported locales
  await initializeDateFormatting();
  
  // Initialize Services
  try {
    await AppSettingsService().init();
    await AdService.initialize();
    await TimestampAccessManager().init();
    await TimestampDeckManager().init();
    await StampTextStore().init();
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
    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        final settings = AppSettingsService();
        final isLight = settings.isLight;

        return MaterialApp(
          title: 'LOG',
          debugShowCheckedModeBanner: false,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLanguages
              .map((info) => info.locale)
              .toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            brightness: isLight ? Brightness.light : Brightness.dark,
            scaffoldBackgroundColor: settings.scaffoldBackgroundColor,
            canvasColor: settings.scaffoldBackgroundColor,
            appBarTheme: AppBarTheme(
              backgroundColor: settings.appBarColor,
              foregroundColor: settings.textColor,
              elevation: 0,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: settings.cardBackgroundColor,
            ),
            colorScheme: ColorScheme(
              brightness: isLight ? Brightness.light : Brightness.dark,
              primary: settings.accentColor,
              onPrimary: isLight ? Colors.white : Colors.black,
              secondary: settings.accentColor,
              onSecondary: isLight ? Colors.white : Colors.black,
              error: Colors.redAccent,
              onError: Colors.white,
              surface: settings.cardBackgroundColor,
              onSurface: settings.textColor,
            ),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            useMaterial3: true,
            fontFamily: AppLocalizations.uiFontFamily,
            fontFamilyFallback: AppLocalizations.fontFallbackChain,
          ),
          home: CameraScreen(cameras: cameras),
        );
      },
    );
  }
}
