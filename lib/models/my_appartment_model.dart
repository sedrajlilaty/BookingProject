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
  });

  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    
    return ApartmentModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      governorate: json['governorate'],
      city: json['city'],
      location: json['location'],
      type: json['type'],
      rooms: json['rooms'],
      bathrooms: json['bathrooms'],
      area: json['area'],
      price: json['price'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      images:
          (json['images'] as List)
              .map((e) => ApartmentImage.fromJson(e))
              .toList(),
    );
  }
}

class ApartmentImage {
  final int id;
  final int apartmentId;
  final String image;
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
    return ApartmentImage(
      id: json['id'],
      apartmentId: json['apartment_id'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
