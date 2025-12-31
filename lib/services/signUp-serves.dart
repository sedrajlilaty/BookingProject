// ignore: file_names
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/network/urls.dart';

class Signupserves {
  static Future<Response?> Signup(
    context,
    String name,
    String lastName,
    String phone,
    String password,
    String passwordConfirmation,
    String birthdate,
    String userType,
    File nationalIdImage,
    File personalImage,
  ) async {
    final Dio dio = Dio();
    final String baseUrl = Urls.domain;
    final String register = '/api/register';
    dio.options.baseUrl = baseUrl;
    var formData = FormData.fromMap({
      "name": name,
      "last_name": lastName,
      "phone": phone,
      "password": password,
      "password_confirmation": passwordConfirmation,
      "birthdate": birthdate,
      "account_type": userType,
      "national_id_image": await MultipartFile.fromFile(nationalIdImage.path),
      "personal_image": await MultipartFile.fromFile(personalImage.path),
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
