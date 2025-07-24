abstract class Failure {
  final String message;
  final int? code;
  
  const Failure(this.message, {this.code});
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }
  
  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

// Server Failures
class ServerFailure extends Failure {
  const ServerFailure(String message, {int? code}) : super(message, code: code);
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {int? code}) : super(message, code: code);
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure(String message, {int? code}) : super(message, code: code);
}

// Authentication Failures
class AuthFailure extends Failure {
  const AuthFailure(String message, {int? code}) : super(message, code: code);
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {int? code}) : super(message, code: code);
}

// Permission Failures
class PermissionFailure extends Failure {
  const PermissionFailure(String message, {int? code}) : super(message, code: code);
}

// Not Found Failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {int? code}) : super(message, code: code);
}

// Timeout Failures
class TimeoutFailure extends Failure {
  const TimeoutFailure(String message, {int? code}) : super(message, code: code);
}