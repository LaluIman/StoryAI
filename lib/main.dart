import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:story_generator/Screens/splash_screen.dart';

void main() {
  runApp(
    DevicePreview(
      isToolbarVisible: false,
      enabled: true,
      defaultDevice: Devices.ios.iPhone13ProMax,
      devices: [Devices.ios.iPhone13ProMax],
      builder: (context) => MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "PlusJakartaSans",
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
