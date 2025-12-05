// custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';

////////
///ملاحظة وقت بدكن حدطوه بالصفحات بس عينو ال currentindex  وبعدا استدوعوه بمكان ال buttomNavigationButtom
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final Color activeColor;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
    this.activeColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        height: 70,
        notchMargin: 10,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              index: 0,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.favorite_outlined,
              activeIcon: Icons.favorite,
              label: 'Favorite',
              index: 1,
            ),
            const SizedBox(width: 40),
            _buildNavItem(
              context: context,
              icon: Icons.book_online_outlined,
              activeIcon: Icons.book_online,
              label: 'My Booking',
              index: 2,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.person_outlined,
              activeIcon: Icons.person,
              label: 'Profile',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isActive = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTabChanged(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color:
                  isActive
                      ? activeColor
                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
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
