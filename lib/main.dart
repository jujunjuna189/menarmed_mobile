import 'package:menarmed_mobile/service/push_token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:menarmed_mobile/routes/route_generator.dart';
import 'package:menarmed_mobile/service/fire_background.dart';
import 'package:menarmed_mobile/service/local_notification_service.dart';
import 'package:menarmed_mobile/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:menarmed_mobile/service/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FireBackground.instance.initialized();
  await LocalNotificationService.instance.initialize();
  try {
    await PushNotificationService.initialize();
  } catch (error) {
    debugPrint('Push notification initialization failed: $error');
  }
  PushTokenService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      navigatorKey: PushNotificationService.navigatorKey,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: buildMaterialColor(bgPrimary),
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: bgPrimary,
              primary: bgPrimary,
              surface: const Color(0xFFF4F5F6),
              surfaceTint: Colors.transparent,
            ).copyWith(
              surfaceContainerLowest: Colors.white,
              surfaceContainerLow: const Color(0xFFF4F5F6),
              surfaceContainer: const Color(0xFFEEEEEE),
              surfaceContainerHigh: const Color(0xFFE5E5E5),
              surfaceContainerHighest: const Color(0xFFD5D5D5),
            ),
        scaffoldBackgroundColor: const Color(0xFFF4F5F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F5F6),
          foregroundColor: textDark,
          surfaceTintColor: Colors.transparent,
        ),
        bottomAppBarTheme: const BottomAppBarThemeData(
          color: bgPrimary,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      initialRoute: '/splash',
      onGenerateRoute: RouteGenerator.generateRoute,
      builder: EasyLoading.init(),
    );
  }
}
