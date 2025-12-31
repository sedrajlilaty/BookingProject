import 'package:flutter/material.dart';
import 'package:flutter_application_8/network/Helper/cach_helper.dart';
import 'package:flutter_application_8/screens/SplashScreen.dart';
import 'package:sizer/sizer.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// ✅ أضف Sizer هنا

import 'Theme/theme_cubit.dart';
import 'Theme/theme_state.dart';
import 'l10n/Cubit.dart';

import 'network/network_service.dart';
import 'providers/authoProvider.dart';
import 'providers/booking_provider.dart';
import 'main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // تهيئة CacheHelper
  await CacheHelper.init(prefs);

  // تهيئة Network
  try {
    await Network.init();
  } catch (e) {
    // Continue even if network init fails
  }

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
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            return Sizer(
              builder: (context, orientation, deviceType) {
                return MaterialApp(
                  title: 'King Booking App',
                  debugShowCheckedModeBanner: false,
                  locale: langState.locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'),
                    Locale('ar'),
                  ],
                  themeMode: themeState is DarkState ? ThemeMode.dark : ThemeMode.light,
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    brightness: Brightness.light,
                  ),
                  darkTheme: ThemeData(
                    brightness: Brightness.dark,
                  ),
                  home: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (authProvider.isLoggedIn) {
                        return MainNavigationScreen(
                          isOwner: authProvider.user?.userType == 'owner',
                        );
                      }
                      return const SplashScreen();
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
