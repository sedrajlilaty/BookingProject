// token_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';

  // جلب التوكن المخزن
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token != null && token.isNotEmpty) {
        return token;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // التحقق من وجود توكن
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // حذف التوكن (للتسجيل الخروج)
  static Future<void> deleteToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove('is_logged_in');
    } catch (e) {
      // Silent fail
    }
  }

  // التحقق من صلاحية التوكن (اختياري)
  static Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;

    return true;
  }
}
