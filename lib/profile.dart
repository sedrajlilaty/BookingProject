// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_8/EditProfileScreen.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/customButtomNavigation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // بيانات المستخدم (يمكن استبدالها ببيانات حقيقية من API)
  String userName = " سدرة جليلاتي";
  String userEmail = "jlilatysedra@gmail.com";
  String userPhone = "0942232861";
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  int _currentIndex = 3;
  void _navigateToPage(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  // دالة لاختيار صورة من المعرض
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  // دالة لالتقاط صورة من الكاميرا
  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  // دالة لعرض خيارات تغيير الصورة
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('اختر من المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة تسجيل الخروج
  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                // هنا كود تسجيل الخروج الحقيقي
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // انتقل إلى شاشة تعديل الملف الشخصي
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditProfileScreen(
                        userName: userName,
                        userEmail: userEmail,
                        userPhone: userPhone,
                        onSave: (newName, newEmail, newPhone) {
                          setState(() {
                            userName = newName;
                            userEmail = newEmail;
                            userPhone = newPhone;
                          });
                        },
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // صورة الملف الشخصي
            GestureDetector(
              onTap: _showImagePickerOptions,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                    child:
                        _profileImage == null
                            ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // اسم المستخدم
            Text(
              userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Text(
              userEmail,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 32),

            // قائمة الخيارات
            _buildProfileOptions(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        // بدلاً من _buildCustomBottomNavigationBar()
        currentIndex: _currentIndex,
        onTabChanged: _navigateToPage,
        activeColor: accentColor,
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          /* _buildOptionTile(
            icon: Icons.person_outline,
            title: 'معلوماتي الشخصية',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PersonalInfoScreen(
                        userName: userName,
                        userEmail: userEmail,
                        userPhone: userPhone,
                      ),
                ),
              );
            },
          ),*/
          _buildOptionTile(
            icon: Icons.lock_outline,
            title: 'الأمان والخصوصية',
            onTap: () {
              // انتقل إلى شاشة الأمان
            },
          ),
          _buildOptionTile(
            icon: Icons.notifications_active_outlined,
            title: 'الإشعارات',
            onTap: () {
              // انتقل إلى شاشة الإشعارات
            },
          ),
          _buildOptionTile(
            icon: Icons.language,
            title: 'اللغة',
            onTap: () {
              _showLanguageDialog();
            },
          ),
          _buildOptionTile(
            icon: Icons.help_outline,
            title: 'المساعدة والدعم',
            onTap: () {
              // انتقل إلى شاشة المساعدة
            },
          ),
          _buildOptionTile(
            icon: Icons.info_outline,
            title: 'عن التطبيق',
            onTap: () {
              // انتقل إلى شاشة عن التطبيق
            },
          ),
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            color: Colors.red,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black,
          fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey[300]),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اختر اللغة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('العربية'),
                trailing: const Icon(Icons.check),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                trailing: null,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
