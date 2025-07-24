import 'dart:io';
import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class NetworkUtils {
  static void handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const TimeoutException('Koneksi timeout. Silakan coba lagi.');
      
      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          throw const NetworkException('Tidak ada koneksi internet.');
        }
        throw const NetworkException('Gagal terhubung ke server.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _getErrorMessage(error.response?.data);
        
        switch (statusCode) {
          case 400:
            throw ValidationException(message ?? 'Data tidak valid.');
          case 401:
            throw const AuthException('Sesi telah berakhir. Silakan login kembali.');
          case 403:
            throw const PermissionException('Anda tidak memiliki akses.');
          case 404:
            throw const NotFoundException('Data tidak ditemukan.');
          case 422:
            final errors = _extractValidationErrors(error.response?.data);
            throw ValidationException(message ?? 'Data tidak valid.', errors: errors);
          case 500:
            throw const ServerException('Terjadi kesalahan pada server.');
          default:
            throw ServerException(
              message ?? 'Terjadi kesalahan tidak dikenal.',
              statusCode: statusCode,
            );
        }
      
      case DioExceptionType.cancel:
        throw const NetworkException('Permintaan dibatalkan.');
      
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          throw const NetworkException('Tidak ada koneksi internet.');
        }
        throw const NetworkException('Terjadi kesalahan tidak dikenal.');
      
      default:
        throw const NetworkException('Terjadi kesalahan jaringan.');
    }
  }
  
  static String? _getErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? data['msg'];
    }
    return null;
  }
  
  static Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final Map<String, List<String>> validationErrors = {};
        errors.forEach((key, value) {
          if (value is List) {
            validationErrors[key] = value.map((e) => e.toString()).toList();
          } else {
            validationErrors[key] = [value.toString()];
          }
        });
        return validationErrors;
      }
    }
    return null;
  }
  
  static bool isNetworkError(Exception exception) {
    return exception is NetworkException ||
           exception is TimeoutException ||
           (exception is SocketException);
  }
  
  static bool isServerError(Exception exception) {
    return exception is ServerException;
  }
  
  static bool isAuthError(Exception exception) {
    return exception is AuthException;
  }
}