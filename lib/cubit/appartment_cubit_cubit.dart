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

        print('🔑 استخدام التوكن للمصادقة');

        FormData formData = FormData();

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

        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++) {
            File imageFile = images[i];

            if (await _isValidImageFile(imageFile)) {
              String fileName = path.basename(imageFile.path);
              String extension = path.extension(imageFile.path).toLowerCase();

              String contentType = 'image/jpeg';
              if (extension == '.png') {
                contentType = 'image/png';
              } else if (extension == '.jpg' || extension == '.jpeg') {
                contentType = 'image/jpeg';
              }

              formData.files.add(
                MapEntry(
                  'images[]',
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
                  message:
                      'صورة غير صالحة: ${imageFile.path}. يجب أن تكون الصورة بصيغة jpg أو png',
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

        Response response = await Network.postData(
          url: Urls.addAppartments,
          data: formData,
          isMultipart: true,
        );

        _clearFields();

        emit(AppartmentSuccess());
      } on DioException catch (error) {
        String errorMessage = 'حدث خطأ في إضافة الشقة';

        if (error.response?.data != null) {
          final data = error.response!.data;
          if (data is Map<String, dynamic>) {
            // استخراج رسالة الخطأ الرئيسية
            if (data.containsKey('message')) {
              errorMessage = data['message'].toString();
            }

            // استخراج الأخطاء التفصيلية
            if (data.containsKey('errors')) {
              final errors = data['errors'];
              if (errors is Map<String, dynamic>) {
                errorMessage += '\n';
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessage += '• $key: ${value.join(', ')}\n';
                  }
                });
              }
            }
          }
        }

        emit(AppartmentCubitError(message: errorMessage));
      } catch (e) {
        emit(AppartmentCubitError(message: 'حدث خطأ غير متوقع: $e'));
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
