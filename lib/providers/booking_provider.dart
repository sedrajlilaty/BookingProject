import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_8/models/apartment_model.dart';
import 'package:flutter_application_8/models/booking_model.dart';
import 'package:flutter_application_8/models/my_appartment_model.dart';
import 'package:flutter_application_8/network/urls.dart';

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  // 1. جلب طلبات الحجز الخاصة بالمؤجر (Owner)
  Future<void> fetchOwnerBookings(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await Dio().get(
        '${Urls.domain}/api/owner/bookings', // الرابط من صورتك الأخيرة
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        final List data = response.data['data'];
        // تحويل البيانات باستخدام FromJson المصحح
        _bookings = data.map((json) => Booking.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching owner bookings: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Set<int> _locallyRatedBookings = {};

  void markAsRated(int bookingId) {
    _locallyRatedBookings.add(bookingId);
    notifyListeners();
  }

  bool isRated(int bookingId) => _locallyRatedBookings.contains(bookingId);
  // 2. جلب حجوزات المستخدم (المستأجر - User)
  Future<void> fetchUserBookings(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await Dio().get(
        '${Urls.domain}/api/bookings', // الرابط العام للحجوزات
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        final List data = response.data['data'];
        _bookings = data.map((json) => Booking.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching user bookings: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //hello world
  // 3. إنشاء حجز جديد (إرسال الطلب للسيرفر لكي يظهر للمؤجر)
  Future<bool> createBookingOnServer(
    Map<String, dynamic> bookingData,
    String token,
  ) async {
    try {
      debugPrint("Sending Data: $bookingData");
      final response = await Dio().post(
        '${Urls.domain}/api/bookings',
        data: bookingData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // تحديث القائمة بعد الإضافة الناجحة
        await fetchUserBookings(token);
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException) {
        // طباعة تفاصيل الخطأ القادم من Laravel
        debugPrint("❌ سبب رفض السيرفر (400): ${e.response?.data}");

        // إذا كان هناك رسالة خطأ محددة في الـ JSON القادم من السيرفر
        if (e.response?.data != null && e.response?.data['message'] != null) {
          debugPrint("📝 رسالة الخطأ: ${e.response?.data['message']}");
        }
      } else {
        debugPrint("خطأ غير متوقع: $e");
      }
      return false;
    }
  }

  final Dio _dio = Dio();
  Future<bool> updateBooking(
    int bookingId,
    Map<String, dynamic> data,
    String token,
  ) async {
    // الرابط كما ظهر في الـ Postman الخاص بك
    final String url = "${Urls.domain}/api/bookings/$bookingId";

    try {
      final response = await _dio.put(
        url,
        data: data, // Dio يقوم بتحويل الـ Map تلقائياً إلى JSON
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        // التأكد من نجاح العملية من بيانات الاستجابة (حسب صورة Postman)
        if (response.data['success'] == true) {
          // تحديث الحجوزات محلياً حتى يظهر التعديل في الكارد فوراً
          await fetchUserBookings(token);

          notifyListeners();
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      // التعامل مع أخطاء Dio بشكل مخصص
      print("خطأ Dio في تحديث الحجز: ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      print("خطأ عام: $e");
      return false;
    }
  }

  // داخل ApartmentProvider

  // 4. دالة المؤجر للموافقة أو الرفض
  Future<void> handleBookingAction(
    dynamic bookingId,
    String action,
    String token,
  ) async {
    try {
      await Dio().post(
        '${Urls.domain}/api/owner/bookings/$bookingId/$action', // action: 'approve' or 'reject'
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // بعد الأكشن، تحديث قائمة طلبات المؤجر
      await fetchOwnerBookings(token);
    } catch (e) {
      debugPrint("خطأ في معالجة الطلب: $e");
    }
  }

  // دالة فلترة الحجوزات محلياً حسب ID المستخدم (للتأكيد الإضافي)
  List<Booking> getUserBookingsLocally(String userId) {
    return _bookings
        .where((b) => b.userId.toString() == userId.toString())
        .toList();
  }

  Future<void> cancelUserBooking(dynamic id, String token) async {
    final dio = Dio();

    // الرابط الصحيح بناءً على Postman (رابط المستأجر)
    final url = '${Urls.baseUrl}/bookings/$id/cancel';

    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // تحديث الحالة في القائمة المحلية
        final index = _bookings.indexWhere(
          (b) => b.id.toString() == id.toString(),
        );
        if (index != -1) {
          // إذا لم ترد استخدام copyWith، تأكد من إزالة كلمة final من حقل status في الموديل
          _bookings[index] = _bookings[index].copyWith(
            status: BookingStatus.cancelled,
          );
          notifyListeners();
        }
      }
    } on DioException catch (e) {
      print("Error: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? "Failed to cancel");
    }
  }

  Future<void> submitReview({
    required dynamic bookingId,
    required double rating,
    required String comment,
    required String token,
  }) async {
    final dio = Dio();
    final url = '${Urls.domain}/api/bookings/$bookingId/rate';

    try {
      final response = await dio.post(
        url,
        data: {'rating': rating.toInt(), 'comment': comment},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _updateLocalBookingStatus(
          bookingId,
        ); // دالة مساعدة لتحديث الحالة محلياً
      }
    } on DioException catch (e) {
      print("Rating Error: ${e.response?.data}");

      // --- الحل هنا ---
      // إذا كان السيرفر يخبرنا أن التقييم موجود مسبقاً (غالباً StatusCode 422 أو 400)
      // أو إذا كانت الرسالة تحتوي على كلمة "already rated"
      final errorMessage = e.response?.data['message']?.toString() ?? "";

      if (errorMessage.contains("already rated") ||
          e.response?.statusCode == 422) {
        // حتى لو فشل الطلب لأنه مكرر، نعتبره "تم التقييم" لكي يتغير الزر في الواجهة
        _updateLocalBookingStatus(bookingId);

        // لا ترمي خطأ هنا لكي لا تظهر SnackBar حمراء للمستخدم، بل اعتبرها نجاحاً "منطقياً"
        return;
      }

      throw Exception(
        errorMessage.isEmpty ? "Failed to submit rating" : errorMessage,
      );
    }
  }

  // دالة مساعدة لتجنب تكرار الكود وتحديث القائمة
  void _updateLocalBookingStatus(dynamic bookingId) {
    final index = _bookings.indexWhere(
      (b) => b.id.toString() == bookingId.toString(),
    );
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(hasRated: true);
      // إذا كنت تستخدم الـ Set الذي اقترحناه سابقاً:
      markAsRated(int.parse(bookingId.toString()));
      notifyListeners();
    }
  }
  // أضف هذه المتغيرات لحفظ بيانات التقييم القادمة من السيرفر

  // متغير لحفظ بيانات التقييم بشكل مؤقت عند طلبها
  Map<String, dynamic>? currentApartmentRating;

  Future<void> getApartmentRating(dynamic apartmentId) async {
    final dio = Dio();
    // الرابط بناءً على الـ IP الخاص بك والمسار في Postman
    final url = '${Urls.baseUrl}/apartments/$apartmentId/rating';

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        // السيرفر يرسل البيانات داخل حقل "data"
        currentApartmentRating = response.data['data'];
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching rating: $e");
      throw Exception("فشل جلب بيانات التقييم من السيرفر");
    }
  }
}
