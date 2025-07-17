enum QuizLevel { easy, medium, hard }

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final QuizLevel level;
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.level,
    required this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      level: QuizLevel.values.firstWhere(
        (e) => e.toString() == 'QuizLevel.${map['level']}',
        orElse: () => QuizLevel.easy,
      ),
      explanation: map['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'level': level.toString().split('.').last,
      'explanation': explanation,
    };
  }
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double percentage;
  final DateTime completedAt;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.percentage,
    required this.completedAt,
  });
}