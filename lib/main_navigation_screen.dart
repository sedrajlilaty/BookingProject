import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/customButtomNavigation.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';

import 'package:flutter_application_8/screens/owner/homePage.dart';
import 'package:flutter_application_8/screens/owner/AddApartement.dart';
import 'package:flutter_application_8/screens/owner/bookingRequest.dart';

import 'package:flutter_application_8/screens/profile.dart';
import 'package:flutter_application_8/screens/tanent/favorateScreen.dart';
import 'package:flutter_application_8/screens/tanent/myBookingScreen.dart';
import 'package:provider/provider.dart';

class MainNavigationScreen extends StatefulWidget {
  final bool isOwner; // true = مالك, false = مستأجر

  const MainNavigationScreen({Key? key, required this.isOwner})
    : super(key: key);

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
      // شاشات المالك
      _screens = [
        // _buildOwnerPlaceholderScreen('لوحة تحكم المالك'),
        ApartmentBookingScreen(isOwner: widget.isOwner),
        // _buildOwnerPlaceholderScreen('طلبات الحجز'),
        // _buildOwnerPlaceholderScreen('الملف الشخصي للمالك'),
        const BookingRequest(),
        const AddApartmentScreen(),
        const ProfileScreen(),
      ];
    } else {
      // شاشات المستأجر - تمرير isOwner لشاشة الشقق
      _screens = [
        ApartmentBookingScreen(isOwner: widget.isOwner),
        const FavoritesScreen(),
        const MyBookingsScreen(),
        const ProfileScreen(),
      ];
    }
  }

  // دالة لعرض شاشات مؤقتة للمالك
  /* Widget _buildOwnerPlaceholderScreen(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: primaryBackgroundColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work,
              size: 80,
              color: accentColor.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'قيد التطوير',
              style: TextStyle(
                fontSize: 16,
                color: darkTextColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: إضافة منطق التنقل للشاشة الفعلية
                if (title == 'شقق المالك') {
                  // الانتقال لشاشة الشقق مع تمرير isOwner = true
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ApartmentBookingScreen(isOwner: true),
                    ),
                  );
                }
                if (title == 'إضافة شقة') {
                  // الانتقال لشاشة الشقق مع تمرير isOwner = true
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddApartmentScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text('ابدأ التطوير'),
            ),
          ],
        ),
      ),
    );
  }
*/
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

  /* String _getAppBarTitle() {
    if (widget.isOwner) {
      // عناوين شاشات المالك
      switch (_currentIndex) {
        case 0:
          return 'لوحة التحكم';
        case 1:
          return 'شققك';
        case 2:
          return 'طلبات الحجز';
        case 3:
          return 'إضافة شقة';
        case 4:
          return 'الملف الشخصي';
        default:
          return 'لوحة التحكم';
      }
    } else {
      // عناوين شاشات المستأجر
      switch (_currentIndex) {
        case 0:
          return 'الرئيسية';
        case 1:
          return 'المفضلة';
        case 2:
          return 'حجوزاتي';
        case 3:
          return 'الملف الشخصي';
        default:
          return 'الرئيسية';
      }
    }
  }
*/
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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
        isOwner: widget.isOwner,
        activeColor: accentColor,
      ),
    );
  }

  // دالة لعرض الإشعارات
  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(widget.isOwner ? 'إشعارات المالك' : 'الإشعارات'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isOwner) ...[
                  const ListTile(
                    leading: Icon(Icons.request_page, color: Colors.blue),
                    title: Text('طلب حجز جديد'),
                    subtitle: Text('طلب حجز لشقتك في نيويورك'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('حجز مؤكد'),
                    subtitle: Text('تم تأكيد حجز شقتك في دبي'),
                  ),
                ] else ...[
                  const ListTile(
                    leading: Icon(Icons.home, color: Colors.blue),
                    title: Text('شقة جديدة'),
                    subtitle: Text('شقة جديدة متاحة في منطقتك المفضلة'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.green),
                    title: Text('موعد حجز'),
                    subtitle: Text('موعد حجزك سيبدأ بعد 3 أيام'),
                  ),
                ],
                const ListTile(
                  leading: Icon(Icons.info, color: Colors.orange),
                  title: Text('لا توجد إشعارات جديدة'),
                  subtitle: Text('سيتم إعلامك عند وجود تحديثات'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسناً'),
              ),
            ],
          ),
    );
  }
}
