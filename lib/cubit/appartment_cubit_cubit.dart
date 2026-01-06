import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/models/my_appartment_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../network/exception_handler.dart';
import '../network/network_service.dart';
import '../network/urls.dart';

part 'appartment_cubit_state.dart';

class AppartmentCubit extends Cubit<AppartmentState> {
  AppartmentCubit() : super(AppartmentCubitInitial());
  static AppartmentCubit get(context) => BlocProvider.of(context);
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController governorateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController roomsController = TextEditingController();
  final TextEditingController bathroomsController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<File> images = [];

  void showPicker(BuildContext context, {bool isDocument = false}) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery, isDocument: isDocument);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.blue),
                title: const Text('Take a photo'),
                onTap: () {
                  _pickImage(ImageSource.camera, isDocument: isDocument);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        return token;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source, {bool isDocument = false}) async {
    final ImagePicker picker = ImagePicker();

    try {
      if (source == ImageSource.camera) {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 90,
        );
        if (pickedFile != null) {
          images.add(File(pickedFile.path));
          emit(ChangePhotoState());
        }
      } else {
        final List<XFile> pickedFiles = await picker.pickMultiImage(
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 90,
        );
        if (pickedFiles.isNotEmpty) {
          for (var pickedFile in pickedFiles) {
            images.add(File(pickedFile.path));
          }
          emit(ChangePhotoState());
        }
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    }
  }

  void removeImageFromList({required int index}) {
    images.removeAt(index);
    emit(ChangePhotoState());
  }

  Future<void> addAppartment() async {
    if (formState.currentState!.validate()) {
      emit(AppartmentLoading());

      try {
        String? authToken = await _getAuthToken();

        if (authToken == null || authToken.isEmpty) {
          emit(AppartmentCubitError(message: 'الرجاء تسجيل الدخول أولاً'));
          return;
        }

        debugPrint('🔑 التوكن: ${authToken.substring(0, 30)}...');
        debugPrint('📝 طول التوكن: ${authToken.length} حرف');

        FormData formData = FormData();

        // إضافة الحقول الأساسية
        formData.fields.addAll([
          MapEntry('name', nameController.text.trim()),
          MapEntry('governorate', governorateController.text.trim()),
          MapEntry('city', cityController.text.trim()),
          MapEntry('location', locationController.text.trim()),
          MapEntry('type', typeController.text.trim()),
          MapEntry('rooms', roomsController.text.trim()),
          MapEntry('bathrooms', bathroomsController.text.trim()),
          MapEntry('area', areaController.text.trim()),
          MapEntry('price', priceController.text.trim()),
          MapEntry('description', descriptionController.text.trim()),
        ]);

        debugPrint('📊 عدد الصور المرفوعة: ${images.length}');

        // إضافة الصور
        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++) {
            File imageFile = images[i];

            debugPrint('🖼️ معالجة الصورة ${i + 1}: ${imageFile.path}');

            if (await _isValidImageFile(imageFile)) {
              String fileName = path.basename(imageFile.path);
              String extension = path.extension(imageFile.path).toLowerCase();

              debugPrint('📄 اسم الملف: $fileName');
              debugPrint('🎯 الامتداد: $extension');

              String contentType = 'image/jpeg';
              if (extension == '.png') {
                contentType = 'image/png';
              } else if (extension == '.jpg' || extension == '.jpeg') {
                contentType = 'image/jpeg';
              }

              formData.files.add(
                MapEntry(
                  'images[]', // تأكد أن Laravel يتوقع هذا الاسم
                  await MultipartFile.fromFile(
                    imageFile.path,
                    filename: fileName,
                    contentType: MediaType.parse(contentType),
                  ),
                ),
              );
            } else {
              emit(
                AppartmentCubitError(
                  message: 'صورة غير صالحة: ${imageFile.path}',
                ),
              );
              return;
            }
          }
        } else {
          emit(
            AppartmentCubitError(message: 'الرجاء إضافة صورة واحدة على الأقل'),
          );
          return;
        }

        // 1. طباعة البيانات المرسلة للمساعدة في التصحيح
        debugPrint('📤 إرسال البيانات إلى السيرفر...');
        debugPrint('🌐 الرابط: ${Urls.addAppartments}');

        // 2. إرسال الطلب باستخدام Dio مع تفاصيل أكثر
        final dio = Dio();

        // إضافة interceptor للتصحيح
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              debugPrint('🚀 Request URL: ${options.uri}');
              debugPrint(
                '🔑 Authorization Header: ${options.headers['Authorization']?.substring(0, 30)}...',
              );
              debugPrint('📦 Content-Type: ${options.headers['Content-Type']}');
              debugPrint('📊 Request Data Type: ${options.data.runtimeType}');
              return handler.next(options);
            },
            onResponse: (response, handler) {
              debugPrint('✅ Response Status: ${response.statusCode}');
              debugPrint('📄 Response Data: ${response.data}');
              return handler.next(response);
            },
            onError: (error, handler) {
              debugPrint('❌ Dio Error: $error');
              debugPrint('📊 Error Type: ${error.type}');
              debugPrint('🔢 Status Code: ${error.response?.statusCode}');
              debugPrint('📝 Error Response: ${error.response?.data}');
              return handler.next(error);
            },
          ),
        );

        // إعداد الـ timeout
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 30);

        Response response = await dio.post(
          Urls.addAppartments,
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $authToken',
              'Accept': 'application/json',
              // لا تضيف 'Content-Type' هنا لأن Dio سيضيفه تلقائياً لـ FormData
            },
          ),
        );

        debugPrint('🎉 النجاح! حالة الاستجابة: ${response.statusCode}');
        debugPrint('📋 بيانات الاستجابة: ${response.data}');

        _clearFields();
        emit(AppartmentSuccess());
      } on DioException catch (error) {
        debugPrint('❌ فشل في إضافة الشقة');

        String errorMessage = 'حدث خطأ في إضافة الشقة';

        if (error.response != null) {
          debugPrint('🔢 كود الحالة: ${error.response!.statusCode}');
          debugPrint('📝 بيانات الخطأ: ${error.response!.data}');

          // معالجة أخطاء محددة
          switch (error.response!.statusCode) {
            case 401:
              errorMessage = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';
              // يمكنك إضافة إعادة توجيه لتسجيل الدخول
              break;
            case 422:
              errorMessage = 'بيانات غير صالحة';
              if (error.response!.data is Map<String, dynamic>) {
                final errors = error.response!.data['errors'];
                if (errors != null) {
                  errorMessage = '';
                  errors.forEach((key, value) {
                    if (value is List) {
                      errorMessage += '• $key: ${value.join(', ')}\n';
                    }
                  });
                }
              }
              break;
            case 500:
              errorMessage = 'خطأ في السيرفر، يرجى المحاولة لاحقاً';
              break;
          }
        } else if (error.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'انتهت مدة الاتصال، تحقق من اتصال الإنترنت';
        } else if (error.type == DioExceptionType.connectionError) {
          errorMessage = 'خطأ في الاتصال، تحقق من اتصال الإنترنت';
        }

        emit(AppartmentCubitError(message: errorMessage));
      } catch (e) {
        debugPrint('❌ خطأ عام: $e');
        emit(
          AppartmentCubitError(message: 'حدث خطأ غير متوقع: ${e.toString()}'),
        );
      }
    }
  }

  // دالة للتحقق من صحة الصور
  Future<bool> _isValidImageFile(File file) async {
    try {
      // التحقق من وجود الملف
      if (!await file.exists()) {
        return false;
      }

      // التحقق من الامتداد
      String path = file.path.toLowerCase();
      if (!path.endsWith('.jpg') &&
          !path.endsWith('.jpeg') &&
          !path.endsWith('.png')) {
        return false;
      }

      // التحقق من حجم الملف
      final fileSize = await file.length();
      if (fileSize == 0 || fileSize > 5 * 1024 * 1024) {
        // 5MB
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void _clearFields() {
    nameController.clear();
    governorateController.clear();
    cityController.clear();
    locationController.clear();
    typeController.clear();
    roomsController.clear();
    bathroomsController.clear();
    areaController.clear();
    priceController.clear();
    descriptionController.clear();
    images.clear();
  }

  List<ApartmentModel> appartments = [];

  Future<void> getAllApartment() async {
    try {
      appartments = [];
      emit(AppartmentLoading());

      final Response response = await Network.getData(url: Urls.getAppartments);

      final List data = response.data;

      appartments = data.map((e) => ApartmentModel.fromJson(e)).toList();

      emit(AppartmentSuccess());
    } on DioException catch (error) {
      String errorMessage = 'حدث خطأ في جلب الشقق';

      if (error.type == DioExceptionType.badResponse &&
          error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'].toString();
        }
      } else {
        errorMessage = unknownError();
      }

      emit(AppartmentCubitError(message: errorMessage));
    }
  }

  List<ApartmentModel> myappartments = [];
  Future<void> getMyApartment() async {
    try {
      myappartments = [];
      emit(AppartmentLoading());

      final Response response = await Network.getData(
        url: Urls.getMyAppartments,
      );

      final List data = response.data;

      myappartments = data.map((e) => ApartmentModel.fromJson(e)).toList();

      emit(AppartmentSuccess());
    } on DioException catch (error) {
      if (error.type == DioExceptionType.badResponse) {
        emit(AppartmentCubitError(message: error.response?.data['message']));
      } else {
        emit(AppartmentCubitError(message: unknownError()));
      }
    }
  }
}
