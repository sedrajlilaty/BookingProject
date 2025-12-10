// custom_bottom_nav_bar.dart - الإصدار مع BottomAppBar
import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final Color activeColor;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
    this.activeColor = accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BottomAppBar(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      height: 70,
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // تغيير إلى spaceBetween
        children: [
          // العناصر اليسرى
          _buildNavSection(
            context: context,
            startIndex: 0,
            endIndex: 1, // العنصرين الأولين
          ),
          // العناصر اليمنى
          _buildNavSection(
            context: context,
            startIndex: 2,
            endIndex: 3, // العنصرين الأخيرين
          ),
        ],
      ),
    );
  }

  Widget _buildNavSection({
    required BuildContext context,
    required int startIndex,
    required int endIndex,
  }) {
    return Flexible(
      fit: FlexFit.tight,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly, // مسافات متساوية داخل كل قسم
        children: [
          for (int i = startIndex; i <= endIndex; i++)
            _buildNavItem(context: context, index: i),
        ],
      ),
    );
  }

  Widget _buildNavItem({required BuildContext context, required int index}) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isActive = currentIndex == index;

    // تحديد الأيقونة والنص لكل مؤشر
    final Map<int, Map<String, dynamic>> navItems = {
      0: {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
        'label': 'Home',
      },
      1: {
        'icon': Icons.favorite_outlined,
        'activeIcon': Icons.favorite,
        'label': 'Favorite',
      },
      2: {
        'icon': Icons.book_online_outlined,
        'activeIcon': Icons.book_online,
        'label': 'Booking',
      },
      3: {
        'icon': Icons.person_outlined,
        'activeIcon': Icons.person,
        'label': 'Profile',
      },
    };

    return Expanded(
      child: InkWell(
        onTap: () => onTabChanged(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive
                  ? navItems[index]!['activeIcon']
                  : navItems[index]!['icon'],
              color:
                  isActive
                      ? activeColor
                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              navItems[index]!['label'] as String,
              style: TextStyle(
                fontSize: 12,
                color:
                    isActive
                        ? activeColor
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
