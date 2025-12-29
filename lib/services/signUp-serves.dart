// ignore: file_names
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Signupserves {
  static Future<Response?> Signup(
    context,
    String name,
    String last_name,
    String phone,
    String password,
    String password_confirmation,
    String birthdate,
    String _userType,
    File national_id_image,
    File personal_image,
  ) async {
    final Dio dio = Dio();
    final String baseUrl = 'http://192.168.137.201:8000/api';
    final String register = '/register';
    dio.options.baseUrl = baseUrl;
    var formData = FormData.fromMap({
      "name": name,
      "last_name": last_name,
      "phone": phone,
      "password": password,
      "password_confirmation": password_confirmation,
      "birthdate": birthdate,
      "account_type": _userType,
      "national_id_image": await MultipartFile.fromFile(national_id_image.path),
      "personal_image": await MultipartFile.fromFile(personal_image.path),
    });
    try {
      final response = await dio.post(
        register,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
        data: formData,
      );

      log('Response data: ${response.data}');
      return response;
    } on DioException catch (e) {
      log('Dio error: ${e.response?.data ?? e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response!.statusMessage ?? 'Invalid credentials'),
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
