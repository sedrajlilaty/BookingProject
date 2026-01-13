import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/models/userModel.dart';
import 'package:flutter_application_8/network/Helper/cach_helper.dart';
import 'package:flutter_application_8/network/urls.dart' show Urls;
import 'package:shared_preferences/shared_preferences.dart';
// ⚠️ تأكد أن اسم الملف صحيح

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  final SharedPreferences _prefs;

  // 🏗️ المُنشئ
  AuthProvider(this._prefs) {
    _loadUserFromStorage();
  }

  // 🔧 Getters للوصول الآمن للبيانات
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  // 📥 تحميل البيانات من التخزين
  Future<void> _loadUserFromStorage() async {
    try {
      final userJson = _prefs.getString('user_data');
      final token = _prefs.getString('auth_token');

      if (userJson != null && token != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;

        // ✅ التعديل: استخدم factory constructor لكي يتم تصحيح الـ IP تلقائياً
        _user = User.fromJson(userMap);

        _token = token;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("خطأ في تحميل البيانات المحلية: $e");
    }
  }

  // 🔐 تسجيل الدخول
  Future<void> login({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String userType,
    required String birthDate,
    String? personalImage,
    String? idImageUrl,
    required String token,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String userEmail = email;
      if (userEmail.isEmpty) {
        userEmail = '$phone@temp.com';
      }

      String? fullProfileImageUrl = personalImage;
      String? fullIdImageUrl = idImageUrl;

      if (personalImage != null && !personalImage.startsWith('http')) {
        String baseUrl = Urls.domain;
        fullProfileImageUrl = '$personalImage';
      }

      if (idImageUrl != null && !idImageUrl.startsWith('http')) {
        String baseUrl = Urls.domain;
        fullIdImageUrl = '$idImageUrl';
      }

      final user = User(
        id: userId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: userEmail,
        userType: userType,
        birthDate: birthDate,
        personalImage: fullProfileImageUrl,
        idImageUrl: fullIdImageUrl,
        token: token,
      );

      _user = user;
      _token = token;

      await _prefs.setString('user_data', jsonEncode(user.toJson()));
      await _prefs.setString('auth_token', token);
      CacheHelper.saveData(key: 'token', value: token);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚪 تسجيل الخروج
  // 🚪 تسجيل الخروج (ربط مع الباك إند باستخدام Dio)
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final dio = Dio(); // يمكنك استخدام instance جاهزة إذا كانت متوفرة لديك

    try {
      // 1. التحقق من وجود توكن قبل الإرسال
      if (_token != null) {
        // إرسال الطلب للباك إند
        final response = await dio.post(
          '${Urls.domain}/api/logout',
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $_token', // إرسال التوكن لتعريف الجلسة
            },
          ),
        );

        if (response.statusCode == 200) {
          debugPrint("تم تسجيل الخروج من السيرفر بنجاح");
        }
      }
    } on DioException catch (e) {
      // طباعة الخطأ إذا فشل الاتصال بالسيرفر
      debugPrint("خطأ في الاتصال بالسيرفر: ${e.message}");
    } catch (e) {
      debugPrint("خطأ غير متوقع: $e");
    } finally {
      // 2. مسح البيانات محلياً (هذه الخطوة تنفذ دائماً لضمان خروج المستخدم)
      _user = null;
      _token = null;
      _isLoading = false;

      // حذف البيانات من التخزين الدائم
      await _prefs.remove('user_data');
      await _prefs.remove('auth_token');

      // مسح التوكن من الكلاس المساعد إذا كنت تستخدمه
      await CacheHelper.removeData(key: 'token');

      notifyListeners();
    }
  }

  // ⏱️ ضبط حالة التحميل
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
