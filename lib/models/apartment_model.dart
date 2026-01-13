// apartment_model.dart

import 'package:flutter_application_8/network/urls.dart';

class Apartment {
  final String id;
  final String name;
  final String type;
  final String governorate;
  final String city;
  final String? detailedLocation;
  final int rooms;
  final int bathrooms;
  final double area;
  final double price;
  final String description;
  final List<String> images; // هذه ستحتوي على الروابط الكاملة المصححة
  final bool isBooked;
  final DateTime createdAt;
  bool isFavorited;
  Apartment({
    required this.id,
    required this.name,
    required this.type,
    required this.governorate,
    required this.city,
    this.detailedLocation,
    required this.rooms,
    required this.bathrooms,
    required this.area,
    required this.price,
    required this.description,
    required this.images,
    this.isBooked = false,
    required this.createdAt,
    this.isFavorited = false,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    final bool favoriteStatus =
        json['is_favorited'] == true || json['is_favorited'] == 1;

    // سطر الطباعة للتأكد من بيانات السيرفر
    print(
      "📡 Server Data for Apartment ${json['id']}: is_favorited = ${json['is_favorited']} (Parsed as: $favoriteStatus)",
    );
    String safeString(dynamic value) => value?.toString() ?? '';

    String fixImageUrl(String path) {
      if (path.isEmpty) return '';

      // 1. استخراج اسم الملف فقط
      String fileName = path.split('/').last;

      // 2. بناء الرابط الصحيح: بدون كلمة /api/ وبدون تكرار storage
      // تأكد أن الـ IP هو فعلاً 192.168.137.91 وهو الـ IP الخاص بجهاز الكمبيوتر حالياً
      final String baseUrl = Urls.domain;
      final String finalUrl = "$baseUrl/storage/apartments/$fileName";

      // هذا السطر للتأكد - ستلاحظ الآن اختفاء كلمة /api/
      print("🎯 Corrected URL: $finalUrl");

      return finalUrl;
    }

    // معالجة الصور بنفس المنطق السابق
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = List<String>.from(
        (json['images'] as List).map((item) {
          if (item is Map && item.containsKey('image')) {
            return fixImageUrl(item['image'].toString());
          }
          return fixImageUrl(item.toString());
        }),
      );
    }

    return Apartment(
      id: safeString(json['id']),
      name: safeString(json['name']),
      type: safeString(json['type']),
      governorate: safeString(json['governorate']),
      city: safeString(json['city']),
      detailedLocation: json['detailed_location']?.toString(),
      description: safeString(json['description']),
      rooms: int.tryParse(json['rooms']?.toString() ?? '0') ?? 0,
      bathrooms: int.tryParse(json['bathrooms']?.toString() ?? '0') ?? 0,
      area: double.tryParse(json['area']?.toString() ?? '0') ?? 0.0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      images: parsedImages,
      isFavorited: json['is_favorited'] == true || json['is_favorited'] == 1,
      isBooked: json['is_booked'] == 1 || json['is_booked'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
