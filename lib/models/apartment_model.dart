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
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    // دالة داخلية للتعامل مع النصوص الفارغة
    String safeString(dynamic value) => value?.toString() ?? '';

    // دالة تصحيح رابط الصورة واستبدال الـ IP
    String fixImageUrl(String path) {
      if (path.isEmpty) return '';

      // استبدال العناوين المحلية بـ IP الجهاز
      String fixed = path
          .replaceAll('127.0.0.1', '192.168.1.106')
          .replaceAll('localhost', '192.168.1.106')
          .replaceAll('192.168.137.101', '192.168.1.106');

      // إضافة النطاق (Domain) إذا كان المسار لا يبدأ بـ http
      if (!fixed.startsWith('http')) {
        return '${Urls.domain}/storage/$fixed';
      }
      return fixed;
    }

    // 1. معالجة الصور أولاً وتخزينها في قائمة مستقلة
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

    // 2. إرجاع كائن Apartment بعد تجهيز كافة البيانات
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
      images: parsedImages, // استخدام القائمة الجاهزة
      isBooked: json['is_booked'] == 1 || json['is_booked'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
