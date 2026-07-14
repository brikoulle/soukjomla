import 'package:dio/dio.dart';
import '../models/user_models.dart';
import 'app_config.dart';

class ApiClient {
  late Dio _dio;
  String? _authToken;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor in development
    if (AppConfig.isDevelopment) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    // Add auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            // Could trigger token refresh here
            // For now, just pass through to caller
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Multipart form data for file uploads
  Future<Response> postMultipart(
    String path, {
    required Map<String, dynamic> fields,
    Map<String, List<int>>? files,
  }) async {
    try {
      final formData = FormData();

      // Add text fields
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Add file fields
      files?.forEach((fieldName, fileBytes) {
        formData.files.add(
          MapEntry(
            fieldName,
            MultipartFile.fromBytes(fileBytes, filename: fieldName),
          ),
        );
      });

      final response = await _dio.post(path, data: formData);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
