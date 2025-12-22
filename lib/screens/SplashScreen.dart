import 'package:flutter/material.dart';
import 'package:flutter_application_8/screens/welcomeScreen2.dart';
import 'dart:async';
import '../constants.dart';

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
        MaterialPageRoute(builder: (context) => const WelcomeScreen2()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryBackgroundColor,
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryBackgroundColor,
                    primaryBackgroundColor.withOpacity(0.8),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: cardBackgroundColor,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Icon(
                        Icons.home_work,
                        size: 120,
                        color: accentColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.8)],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Royal Rent',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const SizedBox(height: 50),

                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                accentColor.withOpacity(0.3),
                              ),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                accentColor,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'جاري التحميل...',
                      style: TextStyle(
                        color: darkTextColor.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 30,
              left: 30,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.home_work, size: 80, color: accentColor),
              ),
            ),

            Positioned(
              bottom: 30,
              right: 30,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.home_work, size: 80, color: accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
