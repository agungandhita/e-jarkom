import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/typedef.dart';
import '../../models/category_model.dart';
import '../../models/tool_model.dart';
import '../../services/api_service.dart';

class GetCategories {
  final ApiService _apiService;

  GetCategories(this._apiService);

  ResultFuture<List<CategoryModel>> call() async {
    try {
      final response = await _apiService.getCategories();
      final List<CategoryModel> categories = (response['data'] as List)
          .map((json) => CategoryModel.fromMap(json))
          .toList();
      return Right(categories);
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

class GetCategoryById {
  final ApiService _apiService;

  GetCategoryById(this._apiService);

  ResultFuture<CategoryModel> call(String kategoriId) async {
    try {
      final response = await _apiService.getCategory(int.parse(kategoriId));
      final CategoryModel category = CategoryModel.fromMap(response['data']);
      return Right(category);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('404')) {
      return const NotFoundFailure('Kategori tidak ditemukan');
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

class GetToolsByCategory {
  final ApiService _apiService;

  GetToolsByCategory(this._apiService);

  ResultFuture<List<Tool>> call(String kategoriId) async {
    try {
      final response = await _apiService.getToolsByCategory(
        int.parse(kategoriId),
      );
      final List<Tool> tools = (response['data'] as List)
          .map((json) => Tool.fromJson(json))
          .toList();
      return Right(tools);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('404')) {
      return const NotFoundFailure('Kategori tidak ditemukan');
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
