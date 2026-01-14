class ApartmentModel {
  final int id;
  final int userId;
  final String name;
  final String governorate;
  final String city;
  final String location;
  final String type;
  final int rooms;
  final int bathrooms;
  final int area;
  final int price;
  final String description;
  final String createdAt;
  final String updatedAt;
  final List<ApartmentImage> images;
  bool isFavorited;

  ApartmentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.governorate,
    required this.city,
    required this.location,
    required this.type,
    required this.rooms,
    required this.bathrooms,
    required this.area,
    required this.price,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    this.isFavorited = false,
  });

  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    final bool favoriteStatus =
        json['is_favorited'] == true || json['is_favorited'] == 1;

    // سطر الطباعة للتأكد من بيانات السيرفر
    print(
      "📡 Server Data for Apartment ${json['id']}: is_favorited = ${json['is_favorited']} (Parsed as: $favoriteStatus)",
    );
    return ApartmentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      governorate: json['governorate'] ?? '',
      city: json['city'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      rooms: json['rooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: json['area'] ?? 0,
      price: json['price'] ?? 0,
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isFavorited: json['is_favorited'] == true || json['is_favorited'] == 1,

      images:
          (json['images'] as List?)
              ?.map((e) => ApartmentImage.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ApartmentImage {
  final int id;
  final int apartmentId;
  final String image; // ستحتوي على الرابط المصلح
  final String createdAt;
  final String updatedAt;

  ApartmentImage({
    required this.id,
    required this.apartmentId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApartmentImage.fromJson(Map<String, dynamic> json) {
    // --- منطق تصحيح الرابط ---
    String originalPath = json['image'] ?? '';
    String fixedUrl = originalPath;

    if (originalPath.isNotEmpty) {
      // 1. استخراج اسم الصورة فقط (تجاوز أي IP قديم قادم من السيرفر)
      String fileName = originalPath.split('/').last;

      // 2. بناء الرابط الجديد بالـ IP الصحيح ومسار الـ Storage
      // ملاحظة: تأكد من الـ IP 192.168.137.102 أو استخدم AppUrls.baseUrl
      fixedUrl = "http://192.168.137.102:8000/storage/apartments/$fileName";

      print("🎯 Image Fixed in ApartmentImage: $fixedUrl");
    }

    return ApartmentImage(
      id: json['id'] ?? 0,
      apartmentId: json['apartment_id'] ?? 0,
      image: fixedUrl, // تخزين الرابط الجديد
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
