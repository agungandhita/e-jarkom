import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/typedef.dart';
import '../../models/quiz_model.dart';
import '../../models/score_model.dart';
import '../../services/api_service.dart';

class GetQuizQuestions {
  final ApiService _apiService;

  GetQuizQuestions(this._apiService);

  ResultFuture<List<Quiz>> call({String? level}) async {
    try {
      final response = await _apiService.getQuizzes(
        level: level ?? 'beginner',
        page: 1,
        limit: 10,
      );
      
      // Handle different response structures
      List<dynamic> questionsData;
      if (response['data'] is List) {
        questionsData = response['data'] as List;
      } else if (response['data'] is Map && response['data']['data'] is List) {
        questionsData = response['data']['data'] as List;
      } else {
        questionsData = [];
      }
      
      final List<Quiz> questions = questionsData
          .map((json) => Quiz.fromJson(json))
          .toList();
      return Right(questions);
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

class SubmitQuizScore {
  // final ApiService _apiService;

  // SubmitQuizScore(this._apiService);

  ResultFuture<ScoreModel> call({
    required int id,
    required int score,
    required int totalQuestions,
    required String level,
    required int timeSpent,
    required String result,
    required List<Quiz> questions,
  }) async {
    try {
      final scoreResult = ScoreModel(
         id: DateTime.now().millisecondsSinceEpoch.toString(),
         userId: 'current_user',
         level: level,
         skor: score,
         totalSoal: totalQuestions,
         benar: score,
         salah: totalQuestions - score,
         tanggal: DateTime.now(),
         createdAt: DateTime.now(),
       );
      return Right(scoreResult);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception.toString().contains('401')) {
      return const AuthFailure('Sesi telah berakhir');
    } else if (exception.toString().contains('422')) {
      return const ValidationFailure('Data skor tidak valid');
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

class GetUserScores {
  final ApiService _apiService;

  GetUserScores(this._apiService);

  ResultFuture<List<ScoreModel>> call() async {
    try {
      final response = await _apiService.getMyScores();
      final List<ScoreModel> scores = (response['data'] as List)
          .map((json) => ScoreModel.fromJson(json))
          .toList();
      return Right(scores);
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

class GetLeaderboard {
  final ApiService _apiService;

  GetLeaderboard(this._apiService);

  ResultFuture<List<ScoreModel>> call({String? level}) async {
    try {
      final response = await _apiService.getLeaderboard(level: level ?? '');
      
      // Handle different response structures
      List<dynamic> leaderboardData;
      if (response['data'] is List) {
        leaderboardData = response['data'] as List;
      } else if (response['data'] is Map && response['data']['data'] is List) {
        leaderboardData = response['data']['data'] as List;
      } else {
        leaderboardData = [];
      }
      
      final List<ScoreModel> leaderboard = leaderboardData
          .map(
            (json) => ScoreModel(
               id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
               userId: json['user_id']?.toString() ?? 'unknown',
               level: json['level'] ?? 'beginner',
               skor: (json['skor'] ?? json['score'] ?? 0).toInt(),
               totalSoal: json['total_soal'] ?? json['totalQuestions'] ?? 0,
               benar: json['benar'] ?? json['correctAnswers'] ?? 0,
               salah: json['salah'] ?? json['incorrectAnswers'] ?? 0,
               tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
               createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
             ),
          )
          .toList();
      return Right(leaderboard);
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
