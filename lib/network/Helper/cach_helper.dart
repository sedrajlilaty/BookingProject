import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  // استخدام متغير خاص مع علامة ? للإشارة أنه قد يكون null
  static SharedPreferences? _sharedPreferences;

  // دالة init واحدة تأخذ SharedPreferences كمعامل
  static Future<void> init(SharedPreferences prefs) async {
    _sharedPreferences = prefs;
    print('✅ CacheHelper: تم التهيئة بنجاح');
  }

  // دالة مساعدة للحصول على SharedPreferences مع التحقق من التهيئة
  static SharedPreferences get sharedPreferences {
    if (_sharedPreferences == null) {
      throw Exception(
        '⚠️ CacheHelper غير مهيأة! استدع CacheHelper.init() أولاً',
      );
    }
    return _sharedPreferences!;
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    // استخدام getter مع التحقق التلقائي
    final prefs = sharedPreferences;

    if (value is String) {
      return await prefs.setString(key, value);
    } else if (value is int) {
      return await prefs.setInt(key, value);
    } else if (value is bool) {
      return await prefs.setBool(key, value);
    } else if (value is double) {
      return await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      return await prefs.setStringList(key, value);
    } else {
      print('⚠️ CacheHelper: نوع غير مدعوم: ${value.runtimeType}');
      throw Exception('نوع غير مدعوم: ${value.runtimeType}');
    }
  }

  static dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  // دوال مساعدة للحصول على أنواع محددة
  static String? getString(String key) {
    return sharedPreferences.getString(key);
  }

  static int? getInt(String key) {
    return sharedPreferences.getInt(key);
  }

  static bool? getBool(String key) {
    return sharedPreferences.getBool(key);
  }

  static double? getDouble(String key) {
    return sharedPreferences.getDouble(key);
  }

  static List<String>? getStringList(String key) {
    return sharedPreferences.getStringList(key);
  }

  static bool contains(String key) {
    return sharedPreferences.containsKey(key);
  }

  static Future<bool> removeData({required String key}) {
    return sharedPreferences.remove(key);
  }

  static Future<bool> removeAllData() {
    return sharedPreferences.clear();
  }

  // دالة للتحقق من التهيئة
  static bool get isInitialized => _sharedPreferences != null;
}
