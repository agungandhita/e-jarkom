import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/typedef.dart';
import '../../models/tool_model.dart';
import '../../services/api_service.dart';

class GetTools {
  final ApiService _apiService;
  
  GetTools(this._apiService);
  
  ResultFuture<List<Tool>> call() async {
    try {
      final response = await _apiService.getTools();
      final List<Tool> tools = (response['data'] as List)
          .map((json) => Tool.fromJson(json))
          .toList();
      return Right(tools);
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