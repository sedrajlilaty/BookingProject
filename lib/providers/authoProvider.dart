import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/models/userModel.dart';
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
  // 📥 تحميل البيانات من التخزين
  Future<void> _loadUserFromStorage() async {
    try {
      print('🔄 جاري تحميل بيانات المستخدم من التخزين...');

      final userJson = _prefs.getString('user_data');
      final token = _prefs.getString('auth_token');

      print('🔍 البحث عن بيانات:');
      print('   - user_data: ${userJson != null ? "موجود" : "غير موجود"}');
      print('   - auth_token: ${token != null ? "موجود" : "غير موجود"}');

      if (userJson != null && token != null) {
        print('📄 JSON المستخدم: $userJson');

        try {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          print('🗺️ خريطة المستخدم: $userMap');

          // ⚠️ **التصحيح: استخدام نفس بنية الحقول التي تحفظها في toJson**
          _user = User(
            id: userMap['id']?.toString() ?? '',
            firstName: userMap['firstName']?.toString() ?? '',
            lastName: userMap['lastName']?.toString() ?? '',
            phone: userMap['phone']?.toString() ?? '',
            email: userMap['email']?.toString() ?? '',
            userType: userMap['userType']?.toString() ?? '',
            birthDate: userMap['birthDate']?.toString() ?? '',
            profileImageUrl: userMap['profileImageUrl']?.toString(),
            idImageUrl: userMap['idImageUrl']?.toString(),
            token: token, // استخدم التوكن من Storage مباشرة
          );

          _token = token;

          print('✅ تم تحميل المستخدم بنجاح:');
          print('   👤 الاسم: ${_user!.fullName}');
          print('   📞 الهاتف: ${_user!.phone}');
          print('   🎯 النوع: ${_user!.userType}');
          print('   🔐 التوكن: ${_token!.substring(0, 20)}...');

          notifyListeners();
        } catch (e) {
          print('❌ خطأ في تحليل JSON: $e');
          await logout();
        }
      } else {
        print('⚠️ لا توجد بيانات محفوظة للدخول');
      }
    } catch (e) {
      print('❌ خطأ في تحميل المستخدم: $e');
      await logout();
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
    String? profileImageUrl,
    String? idImageUrl,
    required String token,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('💾 بدء حفظ بيانات المستخدم...');

      // إذا كانت email فارغة، أنشئ واحدة افتراضية
      String userEmail = email;
      if (userEmail.isEmpty) {
        userEmail = '$phone@temp.com';
        print('📧 تم إنشاء email افتراضي: $userEmail');
      }

      // ⚠️ تحويل مسارات الصور إلى URLs كاملة إذا لزم الأمر
      String? fullProfileImageUrl = profileImageUrl;
      String? fullIdImageUrl = idImageUrl;

      if (profileImageUrl != null && !profileImageUrl.startsWith('http')) {
        String baseUrl = 'http://10.0.2.2:8000'; // ⚠️ غير بناءً على خادمك
        fullProfileImageUrl = '$baseUrl/storage/$profileImageUrl';
        print('🖼️ تحويل مسار الصورة الشخصية: $fullProfileImageUrl');
      }

      if (idImageUrl != null && !idImageUrl.startsWith('http')) {
        String baseUrl = 'http://10.0.2.2:8000'; // ⚠️ غير بناءً على خادمك
        fullIdImageUrl = '$baseUrl/storage/$idImageUrl';
        print('🆔 تحويل مسار صورة الهوية: $fullIdImageUrl');
      }

      final user = User(
        id: userId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: userEmail,
        userType: userType,
        birthDate: birthDate,
        profileImageUrl: fullProfileImageUrl,
        idImageUrl: fullIdImageUrl,
        token: token,
      );

      _user = user;
      _token = token;

      await _prefs.setString('user_data', jsonEncode(user.toJson()));
      await _prefs.setString('auth_token', token);

      print('✅ تم حفظ بيانات المستخدم بنجاح');
      print('👤 المستخدم: ${user.fullName}');
      print('📞 الهاتف: ${user.phone}');
      print('🎯 النوع: ${user.userType}');
      print('🖼️ الصورة الشخصية: ${user.profileImageUrl}');
    } catch (e) {
      print('❌ خطأ في حفظ بيانات المستخدم: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚪 تسجيل الخروج
  Future<void> logout() async {
    print('🚪 بدء عملية تسجيل الخروج');

    // 🔍 طباعة البيانات قبل الحذف للمراقبة
    print('👤 المستخدم قبل الخروج: ${_user?.fullName ?? "لا يوجد"}');
    if (_token != null && _token!.isNotEmpty) {
      // ⚠️ تجنب خطأ substring إذا كان التوكن قصيراً
      int endIndex = _token!.length > 20 ? 20 : _token!.length;
      print('🔐 التوكن قبل الخروج: ${_token!.substring(0, endIndex)}...');
    } else {
      print('🔐 التوكن قبل الخروج: فارغ');
    }

    // 🧹 مسح البيانات من الذاكرة
    _user = null;
    _token = null;
    _isLoading = false;

    // 🗑️ مسح التخزين المحلي
    bool storageCleared = true;
    try {
      // محاولة حذف البيانات
      await _prefs.remove('user_data');
      await _prefs.remove('auth_token');

      // التحقق من الحذف
      final checkUser = _prefs.getString('user_data');
      final checkToken = _prefs.getString('auth_token');

      if (checkUser == null && checkToken == null) {
        print('✅ تم مسح التخزين بنجاح');
      } else {
        print('⚠️ تحذير: قد تكون البيانات موجودة');
        storageCleared = false;

        // محاولة ثانية أكثر قوة
        await _prefs.clear(); // مسح كل شيء إذا فشل الحذف المحدد
        print('🧹 تم مسح جميع بيانات التخزين');
      }
    } catch (e) {
      print('❌ خطأ في مسح التخزين: $e');
      storageCleared = false;

      // محاولة بديلة
      try {
        await _prefs.clear();
        print('🧹 تم مسح التخزين باستخدام clear()');
      } catch (e2) {
        print('❌ فشل مسح التخزين تماماً: $e2');
      }
    }

    // 🔔 إعلام المكونات بالتغيير
    notifyListeners();

    print('✅ عملية تسجيل الخروج مكتملة');
    print('👤 المستخدم بعد الخروج: ${_user?.fullName ?? "null"}');
    print('🔐 التوكن بعد الخروج: ${_token ?? "null"}');
    print('📁 حالة التخزين: ${storageCleared ? "نظيف" : "مشكلة"}');
  }

  // ⏱️ ضبط حالة التحميل
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
