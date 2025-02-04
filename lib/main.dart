import 'package:flutter/material.dart';

import 'package:fleet_ease/app_theme.dart';
import 'package:fleet_ease/screens/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // Default Light Theme
        darkTheme: AppTheme.darkTheme, // Dark Theme
        themeMode: ThemeMode.system, // Auto-switch based on device settings
        home: AuthScreen());
  }
}
