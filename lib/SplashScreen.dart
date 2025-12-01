import 'package:flutter/material.dart';
import 'dart:async';
import 'constants.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor, // اللون الجديد #283618
      body: Stack(
        children: <Widget>[
          // أيقونة المنزل الذهبية في المركز
          Center(
            child: Icon(
              Icons.house_rounded, // أو Icons.home
              size: 120,
              color: accentColor, // لون ذهبي #DDA15E
            ),
          ),

          // طبقة فوقية للمؤشر
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const CircularProgressIndicator(
                  color: accentColor, // لون متناسق مع الخلفية
                  strokeWidth: 3.0,
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
