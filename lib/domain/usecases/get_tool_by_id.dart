import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/typedef.dart';
import '../../models/tool_model.dart';
import '../../services/api_service.dart';

class GetToolById {
  final ApiService _apiService;

  GetToolById(this._apiService);

  ResultFuture<Tool> call(String toolId) async {
    try {
      final int id = int.parse(toolId);
      final response = await _apiService.getTool(id);
      final Tool tool = Tool.fromJson(response['data']);
      return Right(tool);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception is FormatException) {
      return const ValidationFailure('ID alat tidak valid');
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
