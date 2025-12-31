import 'package:flutter_application_8/network/network_service.dart';
import 'package:flutter_application_8/network/urls.dart';

class FavoriteService {
  // جلب قائمة المفضلات
  Future<List<dynamic>> getAllFavorites() async {
    try {
      final response = await Network.getData(
        url: '${Urls.baseUrl}/favorites',
      );

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
      final response = await Network.postData(
        url: '${Urls.baseUrl}/favorites/$apartmentId',
      );

      return response.statusCode == 200;
    } catch (e) {
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
