import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: accentColor,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: accentColor,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text('الملف الشخصي'),
                subtitle: Text('user@example.com'),
                trailing: Icon(Icons.edit),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('الإعدادات'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.help),
                    title: Text('المساعدة'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}