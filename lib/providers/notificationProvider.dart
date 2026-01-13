import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/network/urls.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;
  final Dio _dio = Dio();

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  // الرابط الأساسي من ملف الـ Urls
  final String _baseUrl = Urls.notifications;

  // 1. جلب الإشعارات (المقروءة وغير المقروءة)
  Future<void> fetchNotifications(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.get(
        _baseUrl,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        // تأكد من هيكلة البيانات القادمة من الباك إند
        List data = response.data['data'] ?? [];
        _notifications =
            data.map((n) => NotificationModel.fromJson(n)).toList();

        // تحديث العداد
        _updateUnreadCount();
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  // 2. تحديد إشعار واحد كمقروء (تم تصحيح الرابط هنا)
  Future<void> markAsRead(int id, String token) async {
    try {
      // ✅ تصحيح: استخدام _baseUrl بدلاً من المسار الناقص
      final response = await _dio.post(
        '$_baseUrl/$id/read',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index].isRead = true;
          _updateUnreadCount();
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error marking as read: $e");
    }
  }

  // 3. تحديد الكل كمقروء
  Future<void> markAllAsRead(String token) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/read-all',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        for (var n in _notifications) {
          n.isRead = true;
        }
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      print("Error marking all as read: $e");
    }
  }

  // دالة داخلية لتحديث العداد بسهولة
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }
}
