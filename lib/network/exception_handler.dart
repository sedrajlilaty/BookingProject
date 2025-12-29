import 'package:dio/dio.dart';

const Map<String, Map> messages = {
  "ar": {
    "unknown_error": "حدث خطأ غير معروف",
    "server_unavailable": "الخادم غير متاح",
    "connection_timeout": "انتهت مهلة الاتصال",
    "send_timeout": "انتهت مهلة الاتصال",
    "receive_timeout": "الخادم غير متاح ):",
    "server_down": "الخادم غير متوفر حالياً ):",
    "server_error": "حدث خطأ في المخدّم ):",
    "unauthorized": "الوصول غير مصرح به",
    "request_cancelled": "تم إلغاء الطلب",
    "internet_check": "تحقق من اتصالك بالإنترنت",
    "certificate_error": "خطأ في الشهادة",
    "connection_error": "خطأ في الاتصال",
    "bad_response": "تم تلقي استجابة سيئة"
  },
  "en": {
    "unknown_error": "An unknown error occurred",
    "server_unavailable": "Server unavailable",
    "connection_timeout": "Connection timed out",
    "send_timeout": "Send timeout",
    "receive_timeout": "Server unavailable",
    "server_down": "Server is currently down",
    "server_error": "Server error occurred",
    "unauthorized": "Unauthorized access",
    "request_cancelled": "Request cancelled",
    "internet_check": "Check your internet connection",
    "certificate_error": "Certificate error",
    "connection_error": "Connection error",
    "bad_response": "A bad response was received"
  }
};

String unknownError() {
  return 'unknown_error';
}

String exceptionsHandle({
  required DioException error,
}) {
  String message = "unknown_error";

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      message = 'server_unavailable';
      break;
    case DioExceptionType.sendTimeout:
      message = 'connection_timeout';
      break;
    case DioExceptionType.receiveTimeout:
      message = 'receive_timeout';
      break;
    case DioExceptionType.badResponse:
      if (error.response?.statusCode == 503) {
        message = "server_down";
        break;
      }

      if (error.response?.statusCode == 500) {
        message = "server_error";
        break;
      }

      if (error.response?.statusCode == 401) {
        message = "unauthorized";
        break;
      }

      message = error.response?.data['message'];
      return message;

    case DioExceptionType.cancel:
      message = 'request_cancelled';
      break;
    case DioExceptionType.unknown:
      message = 'internet_check';
      break;
    case DioExceptionType.badCertificate:
      message = 'certificate_error';
      break;
    case DioExceptionType.connectionError:
      message = 'connection_error';
      break;
  }

  return messages["en"]?[message];
}
