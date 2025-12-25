import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final Color activeColor;
  final bool isOwner; // true = مالك, false = مستأجر

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.isOwner,
    this.activeColor = accentColor,
  }) : super(key: key);

  List<NavItem> get _ownerNavItems => [
    NavItem(
      index: 0,
      icon: Icons.apartment_outlined,
      activeIcon: Icons.apartment,
      label: 'شققك',
    ),
    NavItem(
      index: 1,
      icon: Icons.request_page_outlined,
      activeIcon: Icons.request_page,
      label: 'طلبات الحجز',
    ),
    NavItem(
      index: 2,
      icon: Icons.add_home_outlined,
      activeIcon: Icons.add_home,
      label: 'إضافة شقة',
    ),
    NavItem(
      index: 3,
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: 'الملف الشخصي',
    ),
  ];

  List<NavItem> get _tenantNavItems => [
    NavItem(
      index: 0,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'الرئيسية',
    ),
    NavItem(
      index: 1,
      icon: Icons.favorite_outlined,
      activeIcon: Icons.favorite,
      label: 'المفضلة',
    ),
    NavItem(
      index: 2,
      icon: Icons.book_online_outlined,
      activeIcon: Icons.book_online,
      label: 'حجوزاتي',
    ),
    NavItem(
      index: 3,
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: 'الملف الشخصي',
    ),
  ];

  List<NavItem> get _navItems {
    return isOwner ? _ownerNavItems : _tenantNavItems;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final navItems = _navItems;

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
        height: 75,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            navItems.length,
                (index) => _buildNavItem(
              context: context,
              item: navItems[index],
              isActive: currentIndex == navItems[index].index,
              isDarkMode: isDarkMode,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required NavItem item,
    required bool isActive,
    required bool isDarkMode,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTabChanged(item.index),
          splashColor: activeColor.withOpacity(0.2),
          highlightColor: activeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive
                      ? activeColor
                      : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive
                        ? activeColor
                        : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class NavItem {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
