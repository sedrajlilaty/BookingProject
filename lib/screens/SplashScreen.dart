import 'package:flutter/material.dart';
import 'package:flutter_application_8/screens/welcomeScreen2.dart';
import 'dart:async';
import '../constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Theme/theme_cubit.dart';
import '../Theme/theme_state.dart';

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
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final bool isDarkMode = state is DarkState;

        // ألوان حسب الثيم
        final backgroundColor = isDarkMode ? Colors.grey[900]! : primaryBackgroundColor;
        final cardColor = isDarkMode ? Colors.grey[800]! : cardBackgroundColor;
        final textColor = isDarkMode ? Colors.white : darkTextColor;
        final secondaryBackground = isDarkMode ? Colors.grey[850]! : primaryBackgroundColor.withOpacity(0.8);
        final overlayColor = isDarkMode ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: Stack(
              children: [
                // الخلفية مع gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [backgroundColor, secondaryBackground, overlayColor],
                    ),
                  ),
                ),
                // المركز: أيقونة التطبيق
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Icon(Icons.home_work, size: 120, color: accentColor),
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
                      const SizedBox(height: 60),
                      // المؤشرات الدائرية
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
                                  valueColor: AlwaysStoppedAnimation(accentColor.withOpacity(0.3)),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(accentColor),
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'جاري التحميل...',
                        style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // أيقونات في الأسفل كخلفية
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
      },
    );
  }
}
