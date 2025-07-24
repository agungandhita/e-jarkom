import 'package:dartz/dartz.dart';
import '../../screens/quiz/quiz_result_screen.dart';
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
      final response = await _apiService.getQuizQuestions(level ?? 'beginner');
      final List<Quiz> questions = (response['data'] as List)
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

  ResultFuture<QuizResultPage> call({
    required int id,
    required int score,
    required int totalQuestions,
    required String level,
    required int timeSpent,
    required String result,
    required List<Quiz> questions,
  }) async {
    try {
      final scoreResult = QuizResultPage(
        quizTitle: 'Quiz $level',
        totalSoal: totalQuestions,
        benar: score,
        selectedAnswers: {},
        questions: questions.map((q) => q.toJson()).toList(),
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
          .map((json) => ScoreModel.fromMap(json))
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

  ResultFuture<List<QuizResultPage>> call({String? level}) async {
    try {
      final response = await _apiService.getLeaderboard(level: level ?? '');
      final List<QuizResultPage> leaderboard = (response['data'] as List)
          .map(
            (json) => QuizResultPage(
              quizTitle: json['quiz_title'] ?? 'Quiz',
              totalSoal: json['total_soal'] ?? json['totalQuestions'] ?? 0,
              benar: json['benar'] ?? json['correctAnswers'] ?? 0,
              selectedAnswers: {},
              questions: [],
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
