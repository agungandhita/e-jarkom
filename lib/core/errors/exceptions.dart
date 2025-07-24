class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  const ServerException(this.message, {this.statusCode});
  
  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  
  const AuthException(this.message, {this.statusCode});
  
  @override
  String toString() => 'AuthException: $message (Status: $statusCode)';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;
  
  const ValidationException(this.message, {this.errors});
  
  @override
  String toString() => 'ValidationException: $message';
}

class PermissionException implements Exception {
  final String message;
  
  const PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: $message';
}

class NotFoundException implements Exception {
  final String message;
  
  const NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: $message';
}

class TimeoutException implements Exception {
  final String message;
  
  const TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}

class FormatException implements Exception {
  final String message;
  
  const FormatException(this.message);
  
  @override
  String toString() => 'FormatException: $message';
}