import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/typedef.dart';
import '../entities/video.dart';
import '../../services/api_service.dart';

class GetVideos {
  final ApiService _apiService;

  GetVideos(this._apiService);

  ResultFuture<List<Video>> call() async {
    try {
      final response = await _apiService.getVideos();
      final List<Video> videos = (response['data'] as List)
          .map((json) => Video.fromJson(json))
          .toList();
      return Right(videos);
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

class GetVideoById {
  final ApiService _apiService;

  GetVideoById(this._apiService);

  ResultFuture<Video> call(String videoId) async {
    try {
      final response = await _apiService.getVideoById(int.parse(videoId));
      final Video video = Video.fromJson(response['data']);
      return Right(video);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('404')) {
      return const NotFoundFailure('Video tidak ditemukan');
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

class UpdateVideoViews {
  final ApiService _apiService;

  UpdateVideoViews(this._apiService);

  ResultVoid call(int videoId) async {
    try {
      await _apiService.updateVideoView(videoId);
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('404')) {
      return const NotFoundFailure('Video tidak ditemukan');
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
