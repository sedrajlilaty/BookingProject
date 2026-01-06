// في ملف جديد apartment_model.dart
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
  final List<String> images;
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
    // دالة داخلية مساعدة لتحويل أي قيمة (حتى لو Map) إلى String
    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is Map || value is List) return value.toString();
      return value.toString();
    }

    return Apartment(
      id: safeString(json['id']),
      name: safeString(json['name']),
      type: safeString(json['type']),
      governorate: safeString(json['governorate']),
      city: safeString(json['city']),
      detailedLocation: json['detailed_location']?.toString(),
      description: safeString(json['description']),

      // الأرقام: تحويل آمن جداً
      rooms: int.tryParse(json['rooms']?.toString() ?? '0') ?? 0,
      bathrooms: int.tryParse(json['bathrooms']?.toString() ?? '0') ?? 0,
      area: double.tryParse(json['area']?.toString() ?? '0') ?? 0.0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,

      // الصور
      images:
          json['images'] is List
              ? List<String>.from(json['images'].map((item) => item.toString()))
              : [],

      isBooked:
          json['is_booked'] == 1 ||
          json['is_booked'] == true ||
          json['is_booked'].toString() == "true",

      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
  // يمكنك إضافة toJson/fromJson إذا كنت سترسل البيانات للخادم
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'governorate': governorate,
      'city': city,
      'detailedLocation': detailedLocation,
      'rooms': rooms,
      'bathrooms': bathrooms,
      'area': area,
      'price': price,
      'description': description,
      'images': images,
      'isBooked': isBooked,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
