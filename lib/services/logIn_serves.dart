import 'dart:developer' show log;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/network/urls.dart';

class LoginServes {
  static Future<Response?> logIn(
    context,
    String phone,
    String password,
    String account_type,
  ) async {
    final Dio dio = Dio();
    final String baseUrl = Urls.domain;
    final String login = '/api/login';
    dio.options.baseUrl = baseUrl;

    try {
      final response = await dio.post(
        login,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        data: {
          "phone": phone,
          "password": password,
          "account_type": account_type,
        },
      );

      log('Response data: ${response.data}');
      return response;
    } on DioException catch (e) {
      log('Dio error: ${e.response?.data ?? e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response!.data['message'] ?? 'Invalid credentials'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    } catch (e) {
      log('Unexpected error: $e');
      return null;
    }
  }
}
