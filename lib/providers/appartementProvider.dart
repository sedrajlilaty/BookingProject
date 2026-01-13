import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_8/network/urls.dart';
import '../models/apartment_model.dart'; // تأكد من المسار

class ApartmentProvider with ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;
  Apartment? _currentApartment;

  bool get isLoading => _isLoading;
  Apartment? get currentApartment => _currentApartment;

  // دالة جلب شقة واحدة بواسطة الـ ID
  // داخل ApartmentProvider
  Future<Apartment?> fetchApartmentById(dynamic id) async {
    try {
      // التأكد من الرابط والـ ID
      final String apartmentId = id.toString();
      final String url = "${Urls.baseUrl}/apartments/$apartmentId";

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // طباعة نوع البيانات للتأكد (اختياري للتصحيح)
        print("Response Data Type: ${response.data.runtimeType}");

        dynamic responseData = response.data;
        Map<String, dynamic> finalMap;

        // إذا كان السيرفر يرسل البيانات داخل مفتاح مثل 'data' أو 'apartment'
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('apartment')) {
            finalMap = responseData['apartment'];
          } else if (responseData.containsKey('data')) {
            finalMap = responseData['data'];
          } else {
            finalMap = responseData;
          }

          // إرسال الخريطة للموديل
          return Apartment.fromJson(finalMap);
        }
      }
    } catch (e) {
      // تغيير طريقة الطباعة لضمان عدم حدوث خطأ النوع هنا
      debugPrint("حدث خطأ أثناء الجلب: ${e.toString()}");
    }
    return null;
  }
}
