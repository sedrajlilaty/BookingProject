import 'package:flutter_application_8/network/network_service.dart';
import 'package:flutter_application_8/network/urls.dart';

class FavoriteService {
  // جلب قائمة المفضلات
  Future<List<dynamic>> getAllFavorites() async {
    try {
      final response = await Network.getData(url: '${Urls.baseUrl}/favorites');

      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // إضافة أو حذف من المفضلة
  Future<bool> toggleFavorite(int apartmentId) async {
    try {
      // 1. تأكد أن كلاس Network يرسل التوكن تلقائياً،
      // وإذا لم يكن كذلك، يجب تمريره في الـ headers هنا.
      final response = await Network.postData(
        url: '${Urls.baseUrl}/favorites/$apartmentId',
      );

      // 2. بناءً على صورة Postman، السيرفر يعيد حقل "success" داخل الـ data
      // يفضل التأكد من محتوى الرد وليس فقط الـ statusCode
      if (response.statusCode == 200) {
        final data =
            response.data; // افترضنا أن الـ response يعيد كائن يحتوي على data
        print("📡 Toggle Favorite Response: $data"); // للطباعة والتأكد

        // نتحقق من وجود حقل success وقيمته true
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      print("❌ Error in toggleFavorite: $e");
      return false;
    }
  }

  // التحقق من حالة المفضلة لشقة معينة
  Future<bool> isFavorite(int apartmentId) async {
    try {
      final response = await Network.getData(
        url: '${Urls.baseUrl}/favorites/check/$apartmentId',
      );

      if (response.statusCode == 200) {
        return response.data['is_favorite'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
