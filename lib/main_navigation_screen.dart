import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/customButtomNavigation.dart';
import 'package:flutter_application_8/screens/homePage.dart';
import 'package:flutter_application_8/screens/favorateScreen.dart';
import 'package:flutter_application_8/screens/myBookingScreen.dart';
import 'package:flutter_application_8/screens/profile.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          ApartmentBookingScreen(),
          FavoritesScreen(),
          MyBookingsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
        activeColor: accentColor,
      ),
    );
  }
}
