import 'package:dio/dio.dart';
import '../config/design_system.dart';

class ErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }

    return 'حدث خطأ غير متوقع';
  }

  static String _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت.';
      
      case DioExceptionType.sendTimeout:
        return 'استغرق الإرسال وقتاً طويلاً. يرجى المحاولة مرة أخرى.';
      
      case DioExceptionType.receiveTimeout:
        return 'استغرق الخادم وقتاً طويلاً للرد. يرجى المحاولة مرة أخرى.';
      
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب.';
      
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return 'لا يوجد اتصال بالإنترنت.';
        }
        return 'خطأ في الاتصال. تحقق من اتصالك بالإنترنت.';
      
      default:
        return 'حدث خطأ. يرجى المحاولة مرة أخرى.';
    }
  }

  static String _handleBadResponse(Response? response) {
    if (response == null) {
      return 'خطأ في الخادم. يرجى المحاولة لاحقاً.';
    }

    final data = response.data;
    String? errorMessage;

    // Try to extract error message from response
    if (data is Map<String, dynamic>) {
      errorMessage = data['detail'] ?? data['error'] ?? data['message'];
    }

    switch (response.statusCode) {
      case 400:
        return errorMessage ?? 'البيانات المدخلة غير صحيحة.';
      
      case 401:
        return 'جلستك انتهت. يرجى تسجيل الدخول مجدداً.';
      
      case 403:
        return 'ليس لديك صلاحية للقيام بهذا الإجراء.';
      
      case 404:
        return 'العنصر المطلوب غير موجود.';
      
      case 409:
        return 'هذا العنصر موجود بالفعل.';
      
      case 422:
        return 'يرجى التحقق من البيانات المدخلة.';
      
      case 429:
        return 'عدد محاولات كثيرة. يرجى الانتظار قليلاً.';
      
      case 500:
        return 'خطأ في الخادم. يرجى المحاولة لاحقاً.';
      
      case 503:
        return 'الخادم غير متاح حالياً. يرجى المحاولة لاحقاً.';
      
      default:
        return 'حدث خطأ (${response.statusCode}). يرجى المحاولة مرة أخرى.';
    }
  }

  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
             error.type == DioExceptionType.unknown ||
             (error.message?.contains('SocketException') ?? false);
    }
    return false;
  }

  static bool isAuthError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }
    return false;
  }

  static bool isClientError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode != null &&
             error.response!.statusCode! >= 400 &&
             error.response!.statusCode! < 500;
    }
    return false;
  }

  static bool isServerError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode != null &&
             error.response!.statusCode! >= 500;
    }
    return false;
  }
}
