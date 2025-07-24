import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/quiz_provider.dart';
import '../../core/constants/app_constants.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String title;

  const QuizScreen({Key? key, required this.quizId, required this.title})
    : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int currentQuestionIndex = 0;
  Map<int, String> selectedAnswers = {};
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Load quiz questions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadQuizQuestion(widget.quizId);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = answer;
      isAnswered = true;
    });
  }

  void _nextQuestion() {
    final questions = _getMockQuestions();

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = selectedAnswers.containsKey(currentQuestionIndex);
      });

      _animationController.reset();
      _animationController.forward();
    } else {
      _finishQuiz();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        isAnswered = selectedAnswers.containsKey(currentQuestionIndex);
      });

      _animationController.reset();
      _animationController.forward();
    }
  }

  void _finishQuiz() {
    final questions = _getMockQuestions();
    int correctAnswers = 0;

    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]['correctAnswer']) {
        correctAnswers++;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          quizTitle: widget.title,
          totalSoal: questions.length,
          benar: correctAnswers,
          selectedAnswers: selectedAnswers,
          questions: questions,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockQuestions() {
    // Mock questions based on quiz ID
    switch (widget.quizId) {
      case '1': // Dasar Jaringan
        return [
          {
            'question': 'Apa kepanjangan dari LAN?',
            'options': [
              'Local Area Network',
              'Large Area Network',
              'Limited Access Network',
              'Long Area Network',
            ],
            'correctAnswer': 'Local Area Network',
          },
          {
            'question': 'Protokol yang digunakan untuk mengirim email adalah?',
            'options': ['HTTP', 'FTP', 'SMTP', 'TCP'],
            'correctAnswer': 'SMTP',
          },
          {
            'question': 'Port default untuk HTTP adalah?',
            'options': ['21', '25', '80', '443'],
            'correctAnswer': '80',
          },
        ];
      case '2': // Protokol Jaringan
        return [
          {
            'question': 'Lapisan berapa TCP berada dalam model OSI?',
            'options': ['Layer 3', 'Layer 4', 'Layer 5', 'Layer 6'],
            'correctAnswer': 'Layer 4',
          },
          {
            'question': 'Protokol yang bersifat connectionless adalah?',
            'options': ['TCP', 'UDP', 'HTTP', 'FTP'],
            'correctAnswer': 'UDP',
          },
        ];
      default:
        return [
          {
            'question': 'Contoh soal default',
            'options': ['A', 'B', 'C', 'D'],
            'correctAnswer': 'A',
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questions = _getMockQuestions();

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showExitDialog(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Progress Bar
              _buildProgressBar(theme, questions.length),

              // Question Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Number
                      Text(
                        'Soal ${currentQuestionIndex + 1} dari ${questions.length}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: AppConstants.spacingL),

                      // Question Text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppConstants.spacingL),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusL,
                          ),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          currentQuestion['question'],
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: AppConstants.spacingXL),

                      // Answer Options
                      ...List.generate(
                        currentQuestion['options'].length,
                        (index) => _buildAnswerOption(
                          theme,
                          currentQuestion['options'][index],
                          String.fromCharCode(65 + index), // A, B, C, D
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation Buttons
              _buildNavigationButtons(theme, questions.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, int totalQuestions) {
    final progress = (currentQuestionIndex + 1) / totalQuestions;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${((progress * 100).round())}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacingS),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(ThemeData theme, String option, String label) {
    final isSelected = selectedAnswers[currentQuestionIndex] == option;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: GestureDetector(
        onTap: () => _selectAnswer(option),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacingL),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  option,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(ThemeData theme, int totalQuestions) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          if (currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusM,
                    ),
                  ),
                ),
                child: const Text('Sebelumnya'),
              ),
            ),

          if (currentQuestionIndex > 0) SizedBox(width: AppConstants.spacingM),

          // Next/Finish Button
          Expanded(
            flex: currentQuestionIndex == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: isAnswered ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusM,
                  ),
                ),
              ),
              child: Text(
                currentQuestionIndex == totalQuestions - 1
                    ? 'Selesai'
                    : 'Selanjutnya',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Quiz'),
        content: const Text(
          'Apakah Anda yakin ingin keluar? Progress quiz akan hilang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close quiz screen
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
