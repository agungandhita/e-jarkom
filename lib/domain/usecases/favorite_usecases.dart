import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/typedef.dart';
import '../../models/tool_model.dart';
import '../../services/api_service.dart';

class GetUserFavorites {
  final ApiService _apiService;

  GetUserFavorites(this._apiService);

  ResultFuture<List<Tool>> call() async {
    try {
      final response = await _apiService.getFavorites();
      final List<Tool> favorites = (response['data'] as List)
          .map((json) => Tool.fromJson(json))
          .toList();
      return Right(favorites);
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

class AddToFavorites {
  final ApiService _apiService;

  AddToFavorites(this._apiService);

  ResultVoid call(int toolId) async {
    try {
      await _apiService.toggleFavorite(toolId);
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('401')) {
      return const AuthFailure('Sesi telah berakhir');
    } else if (exception.toString().contains('404')) {
      return const NotFoundFailure('Alat tidak ditemukan');
    } else if (exception.toString().contains('409')) {
      return const ValidationFailure('Alat sudah ada di favorit');
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

class RemoveFromFavorites {
  final ApiService _apiService;

  RemoveFromFavorites(this._apiService);

  ResultVoid call(int toolId) async {
    try {
      await _apiService.toggleFavorite(toolId);
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('401')) {
      return const AuthFailure('Sesi telah berakhir');
    } else if (exception.toString().contains('404')) {
      return const NotFoundFailure('Favorit tidak ditemukan');
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

class CheckIsFavorite {
  final ApiService _apiService;

  CheckIsFavorite(this._apiService);

  ResultFuture<bool> call(int toolId) async {
    try {
      final response = await _apiService.checkFavorite(toolId);
      final bool isFavorite = response['is_favorited'] ?? false;
      return Right(isFavorite);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('401')) {
      return const AuthFailure('Sesi telah berakhir');
    } else if (exception.toString().contains('404')) {
      return const NotFoundFailure('Alat tidak ditemukan');
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
