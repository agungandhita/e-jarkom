import 'lib/models/quiz_model.dart';
import 'lib/services/quiz_service.dart';
import 'lib/services/api_service.dart';

void main() {
  print('=== Testing Score Calculation ===');

  // Create test quiz data for "sedang" level
  final testQuizzes = [
    Quiz(
      id: '1',
      soal: 'Test Question 1',
      pilihan: {
        'a': 'Option A',
        'b': 'Option B',
        'c': 'Option C',
        'd': 'Option D',
      },
      jawabanBenar: 'a', // Correct answer is A (index 0)
      level: 'sedang',
      createdAt: DateTime.now(),
    ),
    Quiz(
      id: '2',
      soal: 'Test Question 2',
      pilihan: {
        'a': 'Option A',
        'b': 'Option B',
        'c': 'Option C',
        'd': 'Option D',
      },
      jawabanBenar: 'b', // Correct answer is B (index 1)
      level: 'sedang',
      createdAt: DateTime.now(),
    ),
  ];

  // Test case 1: Both answers correct
  print('\n--- Test Case 1: Both answers correct ---');
  final userAnswers1 = [0, 1]; // A, B (both correct)
  final apiService = ApiService();
  final quizService = QuizService(apiService);
  final result1 = quizService.calculateScore(
    questions: testQuizzes,
    userAnswers: userAnswers1,
  );
  print('Expected: 2 correct, 2 total, 100% score');
  print('Result: $result1');

  // Test case 2: One answer correct
  print('\n--- Test Case 2: One answer correct ---');
  final userAnswers2 = [0, 2]; // A (correct), C (wrong)
  final result2 = quizService.calculateScore(
    questions: testQuizzes,
    userAnswers: userAnswers2,
  );
  print('Expected: 1 correct, 2 total, 50% score');
  print('Result: $result2');

  // Test case 3: No answers correct
  print('\n--- Test Case 3: No answers correct ---');
  final userAnswers3 = [2, 3]; // C (wrong), D (wrong)
  final result3 = quizService.calculateScore(
    questions: testQuizzes,
    userAnswers: userAnswers3,
  );
  print('Expected: 0 correct, 2 total, 0% score');
  print('Result: $result3');

  // Test formatting
  print('\n--- Test Answer Formatting ---');
  final formatted = quizService.formatAnswersForSubmission(
    questions: testQuizzes,
    userAnswers: [0, 1], // A, B
  );
  print('Expected: [{quiz_id: 1, jawaban: a}, {quiz_id: 2, jawaban: b}]');
  print('Result: $formatted');

  print('\n=== Test Complete ===');
}
