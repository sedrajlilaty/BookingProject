import 'package:flutter/material.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'يرجى تسجيل الدخول',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    bool _notificationsEnabled = true;

    // auth_provider.dart
    // profile_screen.dart - دالة تسجيل الخروج الكاملة
    void _handleLogout(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 10),
                  Text('تسجيل الخروج'),
                ],
              ),
              content: const Text(
                'هل أنت متأكد من رغبتك في تسجيل الخروج؟\n\n'
                'سيتم مسح جميع بياناتك من هذا الجهاز.',
                textAlign: TextAlign.right,
              ),
              actions: [
                // زر الإلغاء
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    print('❌ تم إلغاء تسجيل الخروج');
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: accentColor),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: accentColor),
                  ),
                ),

                // زر تسجيل الخروج
                ElevatedButton(
                  onPressed: () async {
                    print('🚀 بدء تنفيذ تسجيل الخروج...');

                    // 1. إغلاق dialog
                    Navigator.pop(context);

                    // 2. إظهار مؤشر تحميل
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) => Center(
                            child: CircularProgressIndicator(
                              color: accentColor,
                            ),
                          ),
                    );

                    try {
                      // 3. جلب AuthProvider
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );

                      // 4. تنفيذ تسجيل الخروج
                      await authProvider.logout();

                      // 5. إغلاق مؤشر التحميل
                      Navigator.pop(context);

                      // 6. التنقل لشاشة الدخول
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );

                      // 7. إظهار رسالة نجاح
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم تسجيل الخروج بنجاح'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      print('🎉 تم تسجيل الخروج والتنقل بنجاح');
                    } catch (e) {
                      // في حالة خطأ
                      Navigator.pop(context); // إغلاق مؤشر التحميل

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('حدث خطأ أثناء تسجيل الخروج: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );

                      print('❌ خطأ في تسجيل الخروج: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // ثم في مكان زر تسجيل الخروج في build method:

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                    // 🖼️ عرض الصورة الشخصية من الرابط
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withOpacity(0.1),
                        border: Border.all(color: accentColor, width: 3),
                      ),
                      child:
                          user.profileImageUrl != null
                              ? ClipOval(
                                child: Image.network(
                                  user.profileImageUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: accentColor,
                                      ),
                                    );
                                  },
                                ),
                              )
                              : Center(
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: accentColor,
                                ),
                              ),
                    ),
                    SizedBox(height: 16),

                    // 👤 الاسم الكامل من بيانات المستخدم
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),

                    // 📧 البريد الإلكتروني من بيانات المستخدم
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),

                    // 🏷️ نوع المستخدم
                    Chip(
                      label: Text(
                        user.userType == 'owner' ? 'مالك' : 'مستأجر',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: accentColor,
                    ),

                    SizedBox(height: 8),

                    // 📱 رقم الهاتف
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(user.phone),
                      ],
                    ),

                    SizedBox(height: 8),

                    OutlinedButton(
                      onPressed: () {
                        // TODO: إضافة منطق تعديل الملف الشخصي
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: accentColor),
                      ),
                      child: Row(
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
              SizedBox(height: 24),

              Card(
                color: Colors.grey[300],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.settings, color: accentColor),
                          SizedBox(width: 12),
                          Expanded(
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
                    ListTile(
                      leading: Icon(Icons.notifications, color: accentColor),
                      title: Text('الإشعارات'),
                      subtitle: Text('تفعيل/تعطيل الإشعارات'),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {},
                        activeColor: accentColor,
                      ),
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
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.help, color: accentColor),
                              SizedBox(width: 12),
                              Expanded(
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
              SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.grey[300],
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _handleLogout(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 12),
                        Expanded(
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
                          padding: EdgeInsets.all(6),
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
