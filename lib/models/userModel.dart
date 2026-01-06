import 'package:flutter_application_8/network/urls.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  // تم تغيير email ليقبل null لأن الصورة لم تظهره في كائن الـ user، تأكد من ذلك
  final String? email;
  final String userType;
  final String birthDate;
  final String? personalImage; // سنستخدم هذا لعرض الصورة القادمة من السيرفر
  final String? idImageUrl;
  final String token;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    required this.userType,
    required this.birthDate,
    this.personalImage,
    this.idImageUrl,
    required this.token,
  });

  String get fullName => '$firstName $lastName';

  // داخل User.dart
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': firstName, // السيرفر يستخدم name
    'last_name': lastName, // السيرفر يستخدم last_name
    'phone': phone,
    'email': email,
    'user_type': userType,
    'birth_date': birthDate,
    'personal_image': personalImage, // تأكد من هذا الاسم
    'token': token,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    String? rawPath = json['personal_image'] ?? json['profileImageUrl'];
    String fixedPath = "";

    if (rawPath != null && rawPath.isNotEmpty) {
      // 2. استبدال أي IP قديم أو محلي بالـ IP الذي تستخدمه حالياً
      // سيحول 192.168.137.101 إلى 192.168.1.106
      fixedPath = rawPath
          .replaceAll('192.168.137.101', '192.168.1.106')
          .replaceAll('127.0.0.1', '192.168.1.106')
          .replaceAll('localhost', '192.168.1.106');

      // تأكد أن الرابط يبدأ بـ http
      if (!fixedPath.startsWith('http')) {
        fixedPath = 'http://192.168.1.106:8000/storage/$fixedPath';
      }
    }

    return User(
      id: json['id']?.toString() ?? '',
      firstName: json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      userType: json['user_type'] ?? '',
      birthDate: json['birth_date'] ?? '',
      personalImage: fixedPath, // هنا يتم تخزين الرابط المصحح
      token: json['token'] ?? '',
    );
  }
}
