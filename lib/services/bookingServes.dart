import 'package:dio/dio.dart';
import 'package:flutter_application_8/network/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  final Dio _dio = Dio();
  final String baseUrl = Urls.baseUrl; // عدل الرابط حسب سيرفرك

  Future<bool> addBooking({
    required int apartmentId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
        'auth_token',
      ); // التأكد من جلب التوكن المخزن

      final response = await _dio.post(
        '$baseUrl/bookings',
        data: {
          'apartment_id': apartmentId,
          'start_date': startDate,
          'end_date': endDate,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Booking Error: $e");
      return false;
    }
  }
}
