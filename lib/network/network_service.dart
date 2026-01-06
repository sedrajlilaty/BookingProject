import 'package:dio/dio.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/network/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Network {
  static late Dio dio;
  static String language = 'en';
  static String? _cachedToken;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _cachedToken = _prefs?.getString(kToken);

      dio = Dio(
        BaseOptions(
          baseUrl: Urls.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: _getHeaders(),
        ),
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            await _updateToken();
            options.headers['Authorization'] = 'Bearer $_cachedToken';
            options.headers['Accept'] = 'application/json';
            return handler.next(options);
          },
          onError: (error, handler) async {
            if (error.response?.statusCode == 401) {
              _cachedToken = null;
              await _prefs?.remove(kToken);
            }
            return handler.next(error);
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _updateToken() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();

      final newToken = _prefs?.getString(kToken);

      if (newToken != _cachedToken) {
        _cachedToken = newToken;
      }
    } catch (e) {
      // Silent fail
    }
  }

  // ✅ دالة للحصول على headers الحالية
  static Map<String, dynamic> _getHeaders() {
    return {
      if (_cachedToken != null && _cachedToken!.isNotEmpty)
        'Authorization': 'Bearer $_cachedToken',
      'Accept': 'application/json',
      // 'Content-Type': 'application/json', // ⚠️ لا تضف هذا لـ multipart/form-data
    };
  }

  static Future<void> updateToken(String newToken) async {
    try {
      _cachedToken = newToken;

      _prefs ??= await SharedPreferences.getInstance();

      await _prefs?.setString(kToken, newToken);
    } catch (e) {
      rethrow;
    }
  }

  // ✅ دالة للحصول على التوكن الحالي
  static String? get currentToken => _cachedToken;

  // ✅ دالة للتحقق من وجود توكن
  static bool get hasToken => _cachedToken != null && _cachedToken!.isNotEmpty;

  static Future<void> clearToken() async {
    try {
      _cachedToken = null;

      _prefs ??= await SharedPreferences.getInstance();

      await _prefs?.remove(kToken);
    } catch (e) {
      // Silent fail
    }
  }

  // ✅ دوال الطلبات المحسنة

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      await _updateToken();

      return await dio.get(
        url,
        queryParameters: query,
        options: options ?? Options(headers: _getHeaders()),
      );
    } on DioException {
      rethrow;
    }
  }

  static Future<Response> postData({
    required String url,
    dynamic data,
    Options? options,
    bool isMultipart = false,
    String? token,
  }) async {
    try {
      await _updateToken();

      final Options requestOptions =
          options ??
          Options(
            headers: {
              ..._getHeaders(),
              if (isMultipart) 'Content-Type': 'multipart/form-data',
            },
          );

      return await dio.post(url, data: data, options: requestOptions);
    } on DioException {
      rethrow;
    }
  }

  static Future<Response> putData({
    required String url,
    dynamic data,
    Options? options,
  }) async {
    try {
      print('✏️ PUT: $url');
      await _updateToken();

      return await dio.put(
        url,
        data: data,
        options: options ?? Options(headers: _getHeaders()),
      );
    } on DioException catch (e) {
      print('❌ خطأ في PUT $url: ${e.message}');
      rethrow;
    }
  }

  static Future<Response> patchData({
    required String url,
    dynamic data,
    Options? options,
  }) async {
    try {
      print('🔧 PATCH: $url');
      await _updateToken();

      return await dio.patch(
        url,
        data: data,
        options: options ?? Options(headers: _getHeaders()),
      );
    } on DioException catch (e) {
      print('❌ خطأ في PATCH $url: ${e.message}');
      rethrow;
    }
  }

  static Future<Response> deleteData({
    required String url,
    dynamic data,
    Options? options,
  }) async {
    try {
      print('🗑️ DELETE: $url');
      await _updateToken();

      return await dio.delete(
        url,
        data: data,
        options: options ?? Options(headers: _getHeaders()),
      );
    } on DioException catch (e) {
      print('❌ خطأ في DELETE $url: ${e.message}');
      rethrow;
    }
  }

  // ✅ دالة لتحميل ملفات (لإضافة الشقق)
  static Future<Response> uploadFiles({
    required String url,
    required FormData formData,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      print('📁 UPLOAD: $url');
      print('📊 عدد الملفات: ${formData.files.length}');
      print('📊 عدد الحقول: ${formData.fields.length}');

      await _updateToken();

      return await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {..._getHeaders(), 'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      print('❌ خطأ في رفع الملفات: ${e.message}');
      print('📋 تفاصيل الخطأ: ${e.response?.data}');
      rethrow;
    }
  }

  // ✅ دالة لاختبار التوكن
  static Future<void> testToken() async {
    try {
      print('🧪 اختبار التوكن...');
      print('📌 التوكن المخزن: ${hasToken ? "موجود" : "غير موجود"}');

      if (_cachedToken != null) {
        print(
          '🔐 التوكن: ${_cachedToken!.substring(0, _cachedToken!.length > 20 ? 20 : _cachedToken!.length)}...',
        );
        print('📏 الطول: ${_cachedToken!.length} حرف');
      }

      // التحقق من التخزين
      _prefs ??= await SharedPreferences.getInstance();

      final storedToken = _prefs?.getString(kToken);
      print(
        '💾 التوكن في SharedPreferences: ${storedToken != null ? "موجود" : "غير موجود"}',
      );

      if (storedToken != null &&
          _cachedToken != null &&
          storedToken == _cachedToken) {
        print('✅ التوكن متطابق في الذاكرة والتخزين');
      } else if (storedToken != _cachedToken) {
        print('⚠️ تحذير: التوكن غير متطابق بين الذاكرة والتخزين');
      }
    } catch (e) {
      print('❌ خطأ في اختبار التوكن: $e');
    }
  }
}
