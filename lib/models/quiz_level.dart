enum QuizLevel {
  mudah('mudah'),
  sedang('sedang'),
  sulit('sulit');

  const QuizLevel(this.value);
  final String value;

  static QuizLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mudah':
        return QuizLevel.mudah;
      case 'sedang':
        return QuizLevel.sedang;
      case 'sulit':
        return QuizLevel.sulit;
      default:
        return QuizLevel.mudah;
    }
  }

  String get displayName {
    switch (this) {
      case QuizLevel.mudah:
        return 'Mudah';
      case QuizLevel.sedang:
        return 'Sedang';
      case QuizLevel.sulit:
        return 'Sulit';
    }
  }

  @override
  String toString() => value;
}