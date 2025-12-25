import 'package:flutter/material.dart';
import 'package:flutter_application_8/Theme/theme_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_8/main_navigation_screen.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:flutter_application_8/providers/booking_provider.dart';
import 'package:flutter_application_8/screens/SplashScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Theme/theme_cubit.dart';
import 'constants.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
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
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'King Booking App',
            debugShowCheckedModeBanner: false,

            // 🌞 الثيم الفاتح
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: primaryBackgroundColor,
              scaffoldBackgroundColor: primaryBackgroundColor,
              hintColor: accentColor,
              fontFamily: 'Cairo',
              appBarTheme: const AppBarTheme(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
              ),
            ),

            // 🌙 الثيم الداكن
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: accentColor,
              scaffoldBackgroundColor: const Color(0xFF121212),
              hintColor: accentColor,
              fontFamily: 'Cairo',
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),


            themeMode:
            state is DarkState ? ThemeMode.dark : ThemeMode.light,

            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
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
        },
      ),
    );
  }
}
