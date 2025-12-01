import 'package:flutter/material.dart';
import 'package:flutter_application_8/SplashScreen.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'King Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryBackgroundColor,
        hintColor: accentColor,
        fontFamily:
            'Cairo', // مثال على خط عربي، تأكد من إضافته إلى pubspec.yaml
      ),
      home: const SplashScreen(), // ابدأ بشاشة تسجيل الدخول
    );
  }
}
