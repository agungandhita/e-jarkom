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
    // Handle options from database format
    List<String> options = [];
    if (map['options'] != null) {
      options = List<String>.from(map['options']);
    } else {
      // Build options from individual fields
      options = [
        map['pilihan_a'] ?? '',
        map['pilihan_b'] ?? '',
        map['pilihan_c'] ?? '',
        map['pilihan_d'] ?? '',
      ];
    }
    
    // Handle correct answer index
    int correctIndex = 0;
    if (map['correctAnswerIndex'] != null) {
      correctIndex = map['correctAnswerIndex'];
    } else if (map['jawaban_benar'] != null) {
      String correctAnswer = map['jawaban_benar'].toString().toLowerCase();
      switch (correctAnswer) {
        case 'a': correctIndex = 0; break;
        case 'b': correctIndex = 1; break;
        case 'c': correctIndex = 2; break;
        case 'd': correctIndex = 3; break;
        default: correctIndex = 0;
      }
    }
    
    // Handle level mapping
    QuizLevel quizLevel = QuizLevel.easy;
    String levelStr = map['level'] ?? '';
    switch (levelStr.toLowerCase()) {
      case 'mudah': case 'easy': quizLevel = QuizLevel.easy; break;
      case 'sedang': case 'medium': quizLevel = QuizLevel.medium; break;
      case 'sulit': case 'hard': quizLevel = QuizLevel.hard; break;
    }
    
    return QuizQuestion(
      id: map['id']?.toString() ?? '',
      question: map['question'] ?? map['soal'] ?? '',
      options: options,
      correctAnswerIndex: correctIndex,
      level: quizLevel,
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