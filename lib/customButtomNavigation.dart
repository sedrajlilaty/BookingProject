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

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              isActive: currentIndex == 0,
              isDarkMode: isDarkMode,
            ),

            _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.favorite_outlined,
              activeIcon: Icons.favorite,
              label: 'Favorite',
              isActive: currentIndex == 1,
              isDarkMode: isDarkMode,
            ),

            _buildNavItem(
              context: context,
              index: 2,
              icon: Icons.book_online_outlined,
              activeIcon: Icons.book_online,
              label: 'Booking',
              isActive: currentIndex == 2,
              isDarkMode: isDarkMode,
            ),

            _buildNavItem(
              context: context,
              index: 3,
              icon: Icons.person_outlined,
              activeIcon: Icons.person,
              label: 'Profile',
              isActive: currentIndex == 3,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required bool isDarkMode,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTabChanged(index),
          splashColor: activeColor.withOpacity(0.2),
          highlightColor: activeColor.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color:
                      isActive
                          ? activeColor
                          : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
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
                            : (isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[600]),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
                ),

                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
