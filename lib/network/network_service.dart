import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'Helper/cach_helper.dart';

class Network {
  
  static late Dio dio;
  static String language = 'en';
  static init() {
    dio = Dio(
      BaseOptions(
        headers: {
      'Authorization':  "Bearer yVwMpcLNvCzr5rBOFSi9IZbIRanLwSG3yFYgnhHA6d30774d",
          //     "Bearer ${CacheHelper.getData(key: CacheHelperKeys.token)}",
          'Accept': 'application/json',
          // "language": language,
        },
      ),
    );

    // Logger
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        request: true,
        compact: true,
        maxWidth: 1000,
      ),
    );
  }

  // static String _getCurrentLanguage() {
  //   try {
  //     final context = navigatorKey.currentContext;

  //     if (context != null) {
  //        print(EasyLocalization.of(context)?.locale.languageCode);
  //       return EasyLocalization.of(context)?.locale.languageCode ?? 'en';
  //     }
  //     return 'en';
  //   } catch (e) {
  //     return 'en';
  //   }}
  static void updateLanguageHeader(String newLanguage) {
    language = newLanguage;
  }

  static void _setAuthHeaders() {
    dio.options.headers = {
      'Authorization':
          "Bearer yVwMpcLNvCzr5rBOFSi9IZbIRanLwSG3yFYgnhHA6d30774d",
      //     "Bearer ${CacheHelper.getData(key: CacheHelperKeys.token)}",
      'Accept': 'application/json',
      // "language": language,
    };
  }

  static Future<Response> getData({required String url, dynamic query}) async {
    _setAuthHeaders();

    return await dio.get(url, queryParameters: query);
  }

  static Future<Response> postData({required String url, dynamic data}) async {
    _setAuthHeaders();
    return await dio.post(url, data: data);
  }

  static Future<Response> putData({required String url, dynamic data}) async {
    _setAuthHeaders();
    return await dio.put(url, data: data);
  }

  static Future<Response> patchData({
    required String url,
    Map<String, dynamic>? data,
  }) async {
    _setAuthHeaders();
    return await dio.patch(url, data: data);
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? data,
  }) async {
    _setAuthHeaders();
    return await dio.delete(url, data: data);
  }
}
