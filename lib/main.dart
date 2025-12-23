import 'package:flutter/material.dart';
import 'package:flutter_application_8/main_navigation_screen.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:flutter_application_8/providers/booking_provider.dart';
import 'package:flutter_application_8/screens/SplashScreen.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

void main() async {
  // ⚙️ تهيئة Flutter الأساسية
  WidgetsFlutterBinding.ensureInitialized();

  // 📁 تهيئة SharedPreferences (التخزين المحلي)
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // 🎮 إضافة AuthProvider مع حقن SharedPreferences
        ChangeNotifierProvider(create: (context) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (context) => BookingProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        fontFamily: 'Cairo',
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // 🔄 التحقق من تسجيل الدخول
          if (authProvider.isLoggedIn) {
            return MainNavigationScreen(
              isOwner: authProvider.user?.userType == 'owner',
            );
          } else {
            return const SplashScreen();
          }
        },
      ),
    );
  }
}
