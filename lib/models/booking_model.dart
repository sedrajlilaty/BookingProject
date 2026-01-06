enum BookingStatus { pending, confirmed, cancelled, completed, pendingUpdate }

class Booking {
  final dynamic id;
  final dynamic userId;
  final dynamic apartmentId;
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
  final int durationInDays; // ✅ تمت إضافة مدة الحفظ بالايام

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
    this.durationInDays = 1, // ✅ قيمة افتراضية
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // معالجة التواريخ بشكل آمن لتجنب أخطاء الصيغة
    final startDate =
        DateTime.tryParse(json['start_date']?.toString() ?? '') ??
        DateTime.now();
    final endDate =
        DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now();

    // حساب مدة الحجز تلقائياً
    final durationInDays = endDate.difference(startDate).inDays;

    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      apartmentId: json['apartment_id'] ?? 0,
      apartmentName:
          json['apartment']?['title'] ??
          json['apartment_name'] ??
          'شقة غير مسمى',
      apartmentImage:
          json['apartment']?['image_url'] ?? json['apartment_image'] ?? '',
      apartmentLocation:
          json['apartment']?['address'] ?? json['apartment_location'] ?? '',
      startDate: startDate,
      endDate: endDate,

      // ✅ الحل الجذري لخطأ Invalid double: استخدام tryParse مع قيمة افتراضية
      pricePerDay:
          double.tryParse(json['price_per_day']?.toString() ?? '0.0') ?? 0.0,
      totalPrice:
          double.tryParse(json['total_price']?.toString() ?? '0.0') ?? 0.0,

      status: _parseStatus(json['status']),
      paymentMethod: json['payment_method'] ?? 'cash',
      bookingDate:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),

      hasRated: json['has_rated'] == 1 || json['has_rated'] == true,

      // ✅ تحويل التقييم بشكل آمن
      userRating: double.tryParse(json['user_rating']?.toString() ?? '0.0'),
      userReview: json['user_review'],
      durationInDays: durationInDays,
    );
  }
  static BookingStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
      case 'approved':
        return BookingStatus.confirmed;
      case 'cancelled':
      case 'rejected':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }

  Booking copyWith({
    dynamic id,
    dynamic userId,
    dynamic apartmentId,
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
    int? durationInDays, // ✅ إضافة durationInDays لـ copyWith
  }) {
    // ✅ إذا تم تغيير startDate أو endDate، نقوم بحساب المدة الجديدة
    final newStartDate = startDate ?? this.startDate;
    final newEndDate = endDate ?? this.endDate;
    final newDurationInDays =
        durationInDays ?? newEndDate.difference(newStartDate).inDays;

    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      apartmentId: apartmentId ?? this.apartmentId,
      apartmentName: apartmentName ?? this.apartmentName,
      apartmentImage: apartmentImage ?? this.apartmentImage,
      apartmentLocation: apartmentLocation ?? this.apartmentLocation,
      startDate: newStartDate,
      endDate: newEndDate,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookingDate: bookingDate ?? this.bookingDate,
      hasRated: hasRated ?? this.hasRated,
      userRating: userRating ?? this.userRating,
      userReview: userReview ?? this.userReview,
      durationInDays: newDurationInDays, // ✅ استخدام المدة المحسوبة
    );
  }

  // ✅ دالة مساعدة للحصول على مدة الحفظ كـ String
  String get durationString {
    if (durationInDays == 1) {
      return 'يوم واحد';
    } else if (durationInDays == 2) {
      return 'يومان';
    } else if (durationInDays > 2 && durationInDays <= 10) {
      return '$durationInDays أيام';
    } else {
      return '$durationInDays يوماً';
    }
  }

  // ✅ دالة مساعدة لعرض معلومات الحجز مع المدة
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'apartment_id': apartmentId,
      'apartment_name': apartmentName,
      'apartment_image': apartmentImage,
      'apartment_location': apartmentLocation,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'price_per_day': pricePerDay,
      'total_price': totalPrice,
      'status': status.name,
      'payment_method': paymentMethod,
      'created_at': bookingDate.toIso8601String(),
      'has_rated': hasRated,
      'user_rating': userRating,
      'user_review': userReview,
      'duration_in_days': durationInDays, // ✅ إضافة المدة للـ JSON
    };
  }
}
