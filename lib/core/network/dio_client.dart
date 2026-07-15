import 'package:dio/dio.dart';
import '../helpers/logger_helper.dart';

/// Custom API Exceptions wrapping Dio errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errorData;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorData,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// A premium, production-ready Dio networking client equipped with authentication interceptors.
class DioClient {
  final Dio _dio;

  DioClient({required String baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.addAll([
      _AuthInterceptor(dioClient: this),
      _LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  /// Perform HTTP GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Perform HTTP POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Map Dio errors into semantic ApiException
  ApiException _handleDioError(DioException error) {
    String message = 'An unexpected network error occurred';
    int? code = error.response?.statusCode;
    dynamic data = error.response?.data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please verify your internet connection.';
        break;
      case DioExceptionType.badResponse:
        if (code == 401) {
          message = 'Unauthorized request. Authentication failed.';
        } else if (code == 403) {
          message = 'Access forbidden.';
        } else if (code == 404) {
          message = 'Requested resource not found.';
        } else if (code == 500) {
          message = 'Internal server error occurred.';
        } else if (data != null && data is Map && data.containsKey('message')) {
          message = data['message'].toString();
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        message = 'Failed to connect to the server. Please check your network.';
        break;
      default:
        break;
    }
    return ApiException(message: message, statusCode: code, errorData: data);
  }
}

/// An interceptor to handle Bearer JWT tokens and automate Token Refresh flows
class _AuthInterceptor extends Interceptor {
  final DioClient dioClient;
  _AuthInterceptor({required this.dioClient});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // TODO: Retrieve actual JWT from local storage
    const String? localJwtToken = 'mock_jwt_token_here';
    
    if (localJwtToken != null) {
      options.headers['Authorization'] = 'Bearer $localJwtToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Auto-refresh token on 401 Unauthorized status
    if (err.response?.statusCode == 401) {
      Logger.warning('Access token expired. Triggering token refresh...', 'AuthInterceptor');
      
      try {
        final newTokens = await _refreshTokens();
        if (newTokens != null) {
          // Retry the failed request with the new token
          final RequestOptions requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer ${newTokens['accessToken']}';
          
          final Response response = await dioClient.dio.fetch(requestOptions);
          return handler.resolve(response);
        }
      } catch (refreshErr) {
        Logger.error('Token refresh failed', refreshErr, null, 'AuthInterceptor');
      }
    }
    handler.next(err);
  }

  /// Placeholder refresh token flow
  Future<Map<String, String>?> _refreshTokens() async {
    // In production: Call refresh API, save to secure storage, and return tokens.
    // For now, return null to avoid infinite refresh loops
    await Future.delayed(const Duration(milliseconds: 800));
    return null;
  }
}

/// Beautiful console logger for network activity
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.debug('🚀 GET/POST: ${options.method} ${options.uri}', 'DioClient');
    if (options.data != null) {
      Logger.debug('📦 Body: ${options.data}', 'DioClient');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.debug('✅ Status Code: [${response.statusCode}] for ${response.requestOptions.uri}', 'DioClient');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.error('❌ Network Error: [${err.response?.statusCode}] ${err.requestOptions.uri}', err.message, null, 'DioClient');
    handler.next(err);
  }
}
