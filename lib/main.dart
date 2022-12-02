//import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

import 'package:fretece/utils/constants.dart';
import 'package:fretece/utils/user_settings.dart';
import 'pages/home_page.dart';

void main() async {
  //DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  //startForegroundService(); //<--solo android

  final prefs = UserSettings();
  await prefs.initPrefs('desktop');
  runApp(const MyApp());
}

Future<bool> startForegroundService() async {
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: 'Ikuzain',
    notificationText: 'Ikuzain en background',
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(
        name: 'background_icon',
        defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );
  await FlutterBackground.initialize(androidConfig: androidConfig);
  return FlutterBackground.enableBackgroundExecution();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const title = appName;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: title),
    );
  }
}
