import 'package:dio/dio.dart';
import '../models/quiz_model.dart';
import '../models/score_model.dart';
import 'api_service.dart';

class QuizService {
  final ApiService _apiService;

  QuizService(this._apiService);

  /// Get quiz questions by level
  Future<List<Quiz>> getQuizzesByLevel(String level, {int? limit}) async {
    try {
      final response = await _apiService.getQuizzes(
        level: level,
        limit: limit,
      );

      // Debug logging
      print('Quiz API Response for level $level:');
      print('Full response: $response');
      print('Response type: ${response.runtimeType}');
      print('Success: ${response['success']}');
      print('Data: ${response['data']}');
      print('Data type: ${response['data']?.runtimeType}');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> quizzesData = response['data'] is List
            ? response['data']
            : response['data']['quizzes'] ?? [];
        
        print('Quizzes data length: ${quizzesData.length}');
        print('First quiz data: ${quizzesData.isNotEmpty ? quizzesData.first : 'No data'}');
        
        return quizzesData.map((json) => Quiz.fromJson(json)).toList();
      } else {
        print('API Error - Success: ${response['success']}, Message: ${response['message']}');
        throw Exception(response['message'] ?? 'Failed to fetch quizzes');
      }
    } catch (e) {
      print('Exception in getQuizzesByLevel: $e');
      throw Exception('Error fetching quizzes: $e');
    }
  }

  /// Submit quiz answers
  Future<Map<String, dynamic>> submitQuizAnswers({
    required String level,
    required List<Map<String, dynamic>> answers,
    String? sessionId,
    int? timeSpent,
  }) async {
    try {
      final response = await _apiService.submitQuizAnswers(
        level,
        {
          'answers': answers,
          'level': level,
          if (sessionId != null) 'session_id': sessionId,
          if (timeSpent != null) 'time_spent': timeSpent,
        },
      );

      if (response['success'] == true) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to submit quiz');
      }
    } catch (e) {
      throw Exception('Error submitting quiz: $e');
    }
  }

  /// Get user quiz history
  Future<List<ScoreModel>> getQuizHistory() async {
    try {
      final response = await _apiService.getQuizHistory();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> historyData = response['data'] is List
            ? response['data']
            : response['data']['data'] ?? [];
        
        return historyData.map((json) => ScoreModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch quiz history');
      }
    } catch (e) {
      throw Exception('Error fetching quiz history: $e');
    }
  }

  /// Get user quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics() async {
    try {
      final response = await _apiService.getQuizStats();

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch quiz statistics');
      }
    } catch (e) {
      throw Exception('Error fetching quiz statistics: $e');
    }
  }

  /// Get leaderboard
  Future<List<ScoreModel>> getLeaderboard({String? level, int limit = 10}) async {
    try {
      final response = await _apiService.getLeaderboardByLevel(
        level: level,
        limit: limit,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> leaderboardData = response['data'] is List
            ? response['data']
            : response['data']['data'] ?? [];
        
        return leaderboardData.map((json) => ScoreModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch leaderboard');
      }
    } catch (e) {
      throw Exception('Error fetching leaderboard: $e');
    }
  }

  /// Get user scores
  Future<List<ScoreModel>> getUserScores({int? page, int? limit, String? level}) async {
    try {
      final response = await _apiService.getScores(
        page: page,
        limit: limit,
        level: level,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> scoresData = response['data'] is List
            ? response['data']
            : response['data']['data'] ?? [];
        
        return scoresData.map((json) => ScoreModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch user scores');
      }
    } catch (e) {
      throw Exception('Error fetching user scores: $e');
    }
  }

  /// Calculate quiz score
  Map<String, dynamic> calculateScore({
    required List<Quiz> questions,
    required List<int?> userAnswers,
  }) {
    int correctAnswers = 0;
    int totalQuestions = questions.length;

    for (int i = 0; i < questions.length; i++) {
      final userAnswer = userAnswers[i];
      if (userAnswer != null) {
        final question = questions[i];
        final correctAnswer = question.jawabanBenar;
        final options = [
          question.pilihanA,
          question.pilihanB,
          question.pilihanC,
          question.pilihanD,
        ];
        
        if (userAnswer < options.length && options[userAnswer] == correctAnswer) {
          correctAnswers++;
        }
      }
    }

    final score = totalQuestions > 0 ? (correctAnswers * 100) ~/ totalQuestions : 0;
    final percentage = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

    return {
      'correct_answers': correctAnswers,
      'total_questions': totalQuestions,
      'incorrect_answers': totalQuestions - correctAnswers,
      'score': score,
      'percentage': percentage,
    };
  }

  /// Format answers for backend submission
  List<Map<String, dynamic>> formatAnswersForSubmission({
    required List<Quiz> questions,
    required List<int?> userAnswers,
  }) {
    List<Map<String, dynamic>> formattedAnswers = [];

    for (int i = 0; i < questions.length; i++) {
      final userAnswer = userAnswers[i];
      if (userAnswer != null) {
        final question = questions[i];
        String answerLetter = '';
        
        switch (userAnswer) {
          case 0:
            answerLetter = 'a';
            break;
          case 1:
            answerLetter = 'b';
            break;
          case 2:
            answerLetter = 'c';
            break;
          case 3:
            answerLetter = 'd';
            break;
        }
        
        formattedAnswers.add({
          'quiz_id': int.parse(question.id),
          'jawaban': answerLetter,
        });
      }
    }

    return formattedAnswers;
  }
}