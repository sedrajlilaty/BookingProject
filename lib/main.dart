import 'package:flutter/material.dart';
import 'package:flutter_application_8/screens/SplashScreen.dart';
import 'package:sizer/sizer.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'Theme/theme_cubit.dart';
import 'Theme/theme_state.dart';
import 'l10n/Cubit.dart';

import 'network/Helper/cach_helper.dart';
import 'network/network_service.dart';
import 'providers/authoProvider.dart';
import 'providers/booking_provider.dart';
import 'main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await CacheHelper.init();
  await Network.init();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<LanguageCubit>(create: (_) => LanguageCubit(prefs)),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, langState) {
                return MaterialApp(
                  title: 'King Booking App',
                  debugShowCheckedModeBanner: false,

                  // 🌍 Language
                  locale: langState.locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,

                  // 🎨 Theme
                  themeMode:
                      themeState is DarkState
                          ? ThemeMode.dark
                          : ThemeMode.light,

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

                  // 🏠 Start Screen
                  home: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.isLoggedIn) {
                        return MainNavigationScreen(
                          isOwner: authProvider.user?.userType == 'tenant',
                        );
                      } else {
                        return const MainNavigationScreen(isOwner: true);
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
