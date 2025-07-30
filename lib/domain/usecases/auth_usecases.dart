import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/typedef.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class LoginUser {
  final ApiService _apiService;

  LoginUser(this._apiService);

  ResultFuture<User> call(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      if (response['success'] == true && response['user'] != null) {
        final User user = User.fromJson(response['user']);
        return Right(user);
      } else {
        return Left(const AuthFailure('Login gagal'));
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('401')) {
      return const AuthFailure('Email atau password salah');
    } else if (exception.toString().contains('network')) {
      return const NetworkFailure('Tidak ada koneksi internet');
    } else if (exception.toString().contains('server')) {
      return const ServerFailure('Terjadi kesalahan pada server');
    } else if (exception.toString().contains('timeout')) {
      return const TimeoutFailure('Koneksi timeout');
    } else {
      return ServerFailure('Terjadi kesalahan: ${exception.toString()}');
    }
  }
}

class RegisterUser {
  final ApiService _apiService;

  RegisterUser(this._apiService);

  ResultFuture<User> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String kelas,
  }) async {
    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        kelas: kelas,
        passwordConfirmation: password,
        bio: null, // Optional bio field
      );
      
      if (response['success'] == true && 
          response['data'] != null && 
          response['data']['user'] != null) {
        final User user = User.fromJson(response['data']['user']);
        return Right(user);
      } else {
        return Left(const ValidationFailure('Registrasi gagal'));
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('422')) {
      return const ValidationFailure('Data registrasi tidak valid');
    } else if (exception.toString().contains('409')) {
      return const ValidationFailure('Email sudah terdaftar');
    } else if (exception.toString().contains('network')) {
      return const NetworkFailure('Tidak ada koneksi internet');
    } else if (exception.toString().contains('server')) {
      return const ServerFailure('Terjadi kesalahan pada server');
    } else if (exception.toString().contains('timeout')) {
      return const TimeoutFailure('Koneksi timeout');
    } else {
      return ServerFailure('Terjadi kesalahan: ${exception.toString()}');
    }
  }
}

class LogoutUser {
  final ApiService _apiService;

  LogoutUser(this._apiService);

  ResultVoid call() async {
    try {
      await _apiService.logout();
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('network')) {
      return const NetworkFailure('Tidak ada koneksi internet');
    } else if (exception.toString().contains('server')) {
      return const ServerFailure('Terjadi kesalahan pada server');
    } else if (exception.toString().contains('timeout')) {
      return const TimeoutFailure('Koneksi timeout');
    } else {
      return ServerFailure('Terjadi kesalahan: ${exception.toString()}');
    }
  }
}

class GetCurrentUser {
  final ApiService _apiService;

  GetCurrentUser(this._apiService);

  ResultFuture<User> call() async {
    try {
      final response = await _apiService.getProfile();
      if (response != null && 
          response['success'] == true && 
          response['data'] != null) {
        final User user = User.fromJson(response['data']);
        return Right(user);
      } else {
        return Left(const AuthFailure('Gagal mengambil data pengguna'));
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('401')) {
      return const AuthFailure('Sesi telah berakhir');
    } else if (exception.toString().contains('network')) {
      return const NetworkFailure('Tidak ada koneksi internet');
    } else if (exception.toString().contains('server')) {
      return const ServerFailure('Terjadi kesalahan pada server');
    } else if (exception.toString().contains('timeout')) {
      return const TimeoutFailure('Koneksi timeout');
    } else {
      return ServerFailure('Terjadi kesalahan: ${exception.toString()}');
    }
  }
}
