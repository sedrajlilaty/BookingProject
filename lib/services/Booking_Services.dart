import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  static const String baseUrl = "http://your-api-url.com/api"; // ضع رابط السيرفر الخاص بك هنا

  static Future<Response?> addBooking(
    BuildContext context, {
    required String apartmentId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // جلب توكن المستخدم المسجل

      Dio dio = Dio();
      // إضافة التوكن للهيدر ليعرف السيرفر من هو المستخدم
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.headers["Accept"] = "application/json";

      // بناء البيانات المرسلة حسب المطلوب في Postman
      FormData formData = FormData.fromMap({
        "apartment_id": apartmentId,
        "start_date": startDate,
        "end_date": endDate,
      });

      // إرسال الطلب (تأكد هل هو POST أم GET حسب إعداد السيرفر لديك)
      // في Postman كان مكتوب GET ولكن عادة الحجز يكون POST
      final response = await dio.post("$baseUrl/bookings", data: formData);

      return response;
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? "فشل الاتصال بالسيرفر";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
      return null;
    }
  }
}