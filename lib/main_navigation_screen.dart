import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/screens/owner/homePage.dart';
import 'package:flutter_application_8/screens/owner/AddApartement.dart';
import 'package:flutter_application_8/screens/owner/bookingRequest.dart';
import 'package:flutter_application_8/screens/profile.dart';
import 'package:flutter_application_8/screens/tanent/favorateScreen.dart';
import 'package:flutter_application_8/screens/tanent/myBookingScreen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  final bool isOwner; // true = مالك, false = مستأجر

  const MainNavigationScreen({Key? key, required this.isOwner}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _initializeScreens() {
    if (widget.isOwner) {
      _screens = [
        ApartmentBookingScreen(isOwner: widget.isOwner),
        const BookingRequest(),
        const AddApartmentScreen(),
        const ProfileScreen(),
      ];
    } else {
      _screens = [
        ApartmentBookingScreen(isOwner: widget.isOwner),
        const FavoritesScreen(),
        const MyBookingsScreen(),
        const ProfileScreen(),
      ];
    }
  }

  @override
  void didUpdateWidget(MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOwner != widget.isOwner) {
      setState(() {
        _currentIndex = 0;
        _initializeScreens();
        _pageController.jumpToPage(0);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        backgroundColor: Colors.transparent,
        color: accentColor,
        buttonBackgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        items: widget.isOwner
            ? <Widget>[
          const Icon(Icons.apartment, size: 30, color:textColor),
          const Icon(Icons.request_page, size: 30,color:textColor),
          const Icon(Icons.add_home, size: 30, color:textColor),
          const Icon(Icons.person, size: 30, color:textColor),
        ]
            : <Widget>[
          const Icon(Icons.home, size: 30, color:textColor),
          const Icon(Icons.favorite, size: 30, color:textColor),
          const Icon(Icons.book_online, size: 30, color:textColor),
          const Icon(Icons.person, size: 30,color:textColor),
        ],
        onTap: (index) {
          _onTabChanged(index);
        },
      ),
    );
  }
}
