import 'dart:convert';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String userType;
  final String birthDate;
  final String? profileImageUrl;
  final String? idImageUrl;
  final String token;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.userType,
    required this.birthDate,
    this.profileImageUrl,
    this.idImageUrl,
    required this.token,
  });

  // 📝 دالة للحصول على الاسم الكامل
  String get fullName => '$firstName $lastName';

  // 📊 تحويل الكائن إلى Map للتخزين
  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'email': email,
    'userType': userType,
    'birthDate': birthDate,
    'profileImageUrl': profileImageUrl,
    'idImageUrl': idImageUrl,
    'token': token,
  };

  // 📥 تحويل Map إلى كائن User
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'].toString(),
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    userType: json['userType'] ?? '',
    birthDate: json['birthDate'] ?? '',
    profileImageUrl: json['profileImageUrl'],
    idImageUrl: json['idImageUrl'],
    token: json['token'] ?? '',
  );
}
