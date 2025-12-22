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
