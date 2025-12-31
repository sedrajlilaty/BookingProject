import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/apartment_model.dart';
import '../../models/my_appartment_model.dart';
import '../../network/exception_handler.dart';
import '../../network/network_service.dart';
import '../../network/urls.dart';

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

  List<dynamic> images = [];
  
  void showPicker(BuildContext context, {bool isDocument = false}) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.blue,
                ),
                title: const Text('Choose from gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery, isDocument: isDocument);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Colors.blue,
                ),
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

  Future<void> _pickImage(ImageSource source, {bool isDocument = false}) async {
    final ImagePicker picker = ImagePicker();

    try {
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
    } catch (e) {
      debugPrint("Image picker error: $e");
    }
  }

  void removeImageFromList({required int index, required int imageId}) {
    if (images[index] is File) {
      images.removeAt(index);
    } else {
      // trashImages.add(imageId);
      images.removeAt(index);
    }
    emit(ChangePhotoState());
  }

  Future<void> addAppartment() async {
    Map<String, dynamic> map = {
      "name": nameController.text.trim(),
      "governorate": governorateController.text.trim(),
      "city": cityController.text.trim(),
      "location": locationController.text.trim(),
      "type": typeController.text.trim(),
      "rooms": roomsController.text.trim(),
      "bathrooms": bathroomsController.text.trim(),
      "area": areaController.text.trim(),
      "price": priceController.text.trim(),
      "description": descriptionController.text.trim(),
    };
    if (images.isNotEmpty) {
      map['images'] = [
        for (var i in images) {await MultipartFile.fromFile(i.path)}.toList(),
      ];
    }
    if (formState.currentState!.validate()) {
      emit(AppartmentLoading());
      try {
        FormData formData = FormData.fromMap(map);
        await Network.postData(url: Urls.addAppartments, data: formData);
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
      if (error.type == DioExceptionType.badResponse) {
        emit(AppartmentCubitError(message: error.response?.data['message']));
      } else {
        emit(AppartmentCubitError(message: unknownError()));
      }
    }
  }

  List<ApartmentModel> myappartments = [];
Future<void> getMyApartment() async {
    try {
      myappartments = [];
      emit(AppartmentLoading());

      final Response response = await Network.getData(url: Urls.getMyAppartments,
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
