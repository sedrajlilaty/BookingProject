import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  void _handleLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: accentColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // إضافة منطق تسجيل الخروج هنا
                },
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: primaryBackgroundColor),
                ),
              ),
            ],
          ),
    );
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
      // إضافة منطق تغيير السمة هنا
    });
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
      // إضافة منطق الإشعارات هنا
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: accentColor,
        centerTitle: true,
        elevation: 4,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // قسم الصورة والاسم
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // صورة الملف الشخصي مع تأثير التفاعل
                    GestureDetector(
                      onTap: () {
                        // إضافة منطق تغيير الصورة
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('اضغط مطولاً لتغيير الصورة'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      onLongPress: () {
                        // فتح خيارات تغيير الصورة
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withOpacity(0.1),
                          border: Border.all(color: accentColor, width: 3),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: accentColor,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // الاسم
                    const Text(
                      'سدرة جليلاتي',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // البريد الإلكتروني
                    const Text(
                      'sedra@example.com',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    // زر تعديل الملف الشخصي
                    OutlinedButton(
                      onPressed: () {
                        // إضافة منطق تعديل الملف الشخصي
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: accentColor),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 4),
                          Text(
                            'تعديل الملف الشخصي',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // كارد الإعدادات
              Card(
                color: Colors.grey[300],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // الإعدادات
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.settings, color: accentColor),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'الإعدادات',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey[200]),

                    // تبديل السمة الداكنة
                    Divider(height: 1, color: Colors.grey[200]),
                    // تبديل الإشعارات
                    ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: accentColor,
                      ),
                      title: const Text('الإشعارات'),
                      subtitle: const Text('تفعيل/تعطيل الإشعارات'),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        activeColor: accentColor,
                      ),
                      onTap: () => _toggleNotifications(!_notificationsEnabled),
                    ),
                    Divider(height: 1, color: Colors.grey[200]),
                    Card(
                      color: primaryBackgroundColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // إضافة منطق صفحة المساعدة
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.help, color: accentColor),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'المساعدة',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'أسئلة شائعة ودعم فني',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // كارد المساعدة
              const SizedBox(height: 16),
              // كارد تسجيل الخروج
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.grey[300],
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _handleLogout,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
