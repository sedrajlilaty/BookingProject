// نموذج بيانات الحجز
enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking {
  final String id;
  final String userId;
  final String apartmentId;
  final String apartmentName;
  final String apartmentImage;
  final String apartmentLocation;
  final DateTime startDate;
  final DateTime endDate;
  final double pricePerDay;
  final double totalPrice;
  final BookingStatus status;
  final String paymentMethod;
  final DateTime bookingDate;
  final bool hasRated;
  final double? userRating;
  final String? userReview;

  Booking({
    required this.id,
    required this.userId,
    required this.apartmentId,
    required this.apartmentName,
    required this.apartmentImage,
    required this.apartmentLocation,
    required this.startDate,
    required this.endDate,
    required this.pricePerDay,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.bookingDate,
    this.hasRated = false,
    this.userRating,
    this.userReview,
  });

  // إنشاء نسخة معدلة من الحجز
  Booking copyWith({
    String? id,
    String? userId,
    String? apartmentId,
    String? apartmentName,
    String? apartmentImage,
    String? apartmentLocation,
    DateTime? startDate,
    DateTime? endDate,
    double? pricePerDay,
    double? totalPrice,
    BookingStatus? status,
    String? paymentMethod,
    DateTime? bookingDate,
    bool? hasRated,
    double? userRating,
    String? userReview,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      apartmentId: apartmentId ?? this.apartmentId,
      apartmentName: apartmentName ?? this.apartmentName,
      apartmentImage: apartmentImage ?? this.apartmentImage,
      apartmentLocation: apartmentLocation ?? this.apartmentLocation,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookingDate: bookingDate ?? this.bookingDate,
      hasRated: hasRated ?? this.hasRated,
      userRating: userRating ?? this.userRating,
      userReview: userReview ?? this.userReview,
    );
  }

  // التحقق مما إذا كان الحجز حاليًا
  bool get isCurrent {
    final now = DateTime.now();
    return (status == BookingStatus.confirmed ||
            status == BookingStatus.pending) &&
        startDate.isBefore(now) &&
        endDate.isAfter(now);
  }

  // التحقق مما إذا كان الحجز مكتملاً
  bool get isCompleted {
    return status == BookingStatus.completed ||
        (status == BookingStatus.confirmed && endDate.isBefore(DateTime.now()));
  }

  // عدد أيام الحجز
  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }
}

// نموذج بيانات الشقة
class Apartment {
  final String id;
  final String name;
  final String description;
  final String location;
  final String city;
  final double pricePerDay;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> amenities;
  final bool isAvailable;
  final String ownerId;

  Apartment({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.city,
    required this.pricePerDay,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.images,
    required this.amenities,
    this.isAvailable = true,
    required this.ownerId,
  });
}
