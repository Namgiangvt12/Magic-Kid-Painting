import 'dart:ui';
import 'package:flutter/material.dart';
import 'screens/app_navigator.dart';

import 'services/app_settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettingsService().init();
  runApp(const MyApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        return MaterialApp(
          title: 'Color Kids',
          debugShowCheckedModeBanner: false,
          scrollBehavior: AppScrollBehavior(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00668A),
              primary: const Color(0xFF00668A),
              secondary: const Color(0xFF674BB5),
              tertiary: const Color(0xFF795900),
              surface: const Color(0xFFFBF9F3),
            ),
            scaffoldBackgroundColor: const Color(0xFFFBF9F3),
            useMaterial3: true,
            fontFamily: 'Nunito Sans',
          ),
          home: const AppNavigator(),
        );
      },
    );
  }
}

