import 'package:flutter/material.dart';
import 'package:flutter_application_8/models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;

  // 📝 إضافة حجز جديد
  void addBooking(Map<String, dynamic> bookingData) {
    final newBooking = Booking(
      id: bookingData['id'],
      userId: bookingData['userId'],
      apartmentId: bookingData['apartmentId'],
      apartmentName: bookingData['apartmentName'],
      apartmentImage: bookingData['apartmentImage'],
      apartmentLocation: bookingData['apartmentLocation'],
      startDate: bookingData['startDate'],
      endDate: bookingData['endDate'],
      pricePerDay: bookingData['pricePerDay'],
      totalPrice: bookingData['totalPrice'],
      status: _parseStatus(bookingData['status']),
      paymentMethod: bookingData['paymentMethod'],
      bookingDate: bookingData['bookingDate'],
      hasRated: bookingData['hasRated'] ?? false,
    );

    _bookings.add(newBooking);
    notifyListeners();

    // حفظ في قاعدة البيانات (اختياري)
    _saveToDatabase(newBooking);
  }

  // 📊 الحصول على حجوزات مستخدم معين باستخدام user.id
  List<Booking> getUserBookings(String userId) {
    return _bookings.where((booking) => booking.userId == userId).toList();
  }

  // 📋 الحصول على حجوزات شقة معينة (للمالك)
  List<Booking> getApartmentBookings(String apartmentId) {
    return _bookings
        .where((booking) => booking.apartmentId == apartmentId)
        .toList();
  }

  // ✏️ تحديث حالة الحجز
  void updateBookingStatus(String bookingId, BookingStatus newStatus) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  // 🗑️ حذف حجز
  void deleteBooking(String bookingId) {
    _bookings.removeWhere((b) => b.id == bookingId);
    notifyListeners();
  }

  // 📝 تحديث تقييم الحجز
  void updateBookingRating(String bookingId, double rating, String review) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        hasRated: true,
        userRating: rating,
        userReview: review,
      );
      notifyListeners();
    }
  }

  // 🔍 تحويل نص الحالة إلى enum
  BookingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'pending':
        return BookingStatus.pending;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }

  // 💾 حفظ في قاعدة البيانات (محاكاة)
  Future<void> _saveToDatabase(Booking booking) async {
    // هنا تكتب كود الاتصال بقاعدة البيانات الحقيقية
    print('تم حفظ حجز للمستخدم: ${booking.userId}');
  }
}
