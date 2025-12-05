import 'package:flutter/material.dart';

import 'constants.dart';

//endDrawer بتستدعو هاد الكلاس بالمكان الي بدكن تحطو فيه ال endDrawer
class EndDrawer extends StatefulWidget {
  const EndDrawer({super.key});

  @override
  State<EndDrawer> createState() => _buildEndDrawerState();
}

class _buildEndDrawerState extends State<EndDrawer> {
  Widget build(BuildContext context) {
    return _buildEndDrawer();
  }

  Widget _buildEndDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: cardBackgroundColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: accentColor,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'john.doe@example.com',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Language Toggle
          /*  ListTile(
            leading: Icon(
              Icons.language,
              color:  Colors.black,
            ),
            title: Text(
             'Language / اللغة',
              style: TextStyle(
                color:  Colors.black,
              ),
            ),
            trailing: Switch(
              value: _isEnglish,
              onChanged: (value) {
                _toggleLanguage();
                Navigator.pop(context);
              },
              activeColor: accentColor,
            ),
            subtitle: Text(
              _isEnglish ? 'English / عربي' : 'English / عربي',
              style: TextStyle(
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
*/
          /*   // Theme Toggle
          ListTile(
            leading: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            title: Text(
              _isEnglish ? 'Dark Mode' : 'الوضع الليلي',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                _toggleTheme();
                Navigator.pop(context);
              },
              activeColor: accentColor,
            ),
            subtitle: Text(
              _isEnglish
                  ? 'Toggle dark/light mode'
                  : 'تبديل الوضع الليلي/النهاري',
              style: TextStyle(
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),*/
          const Divider(),

          ListTile(
            leading: Icon(Icons.person_outline, color: Colors.black),
            title: Text('الملف الشخصي', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: Colors.black),
            title: Text('الإعدادات', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.black),
            title: Text(
              'المساعدة والدعم',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: Colors.black),
            title: Text(
              'سياسة الخصوصية',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout_outlined, color: Colors.red),
            title: Text(
              'تسجيل الخروج',
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.black),
            title: Text('حول التطبيق', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
