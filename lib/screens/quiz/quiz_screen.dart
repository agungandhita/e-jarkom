import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/quiz_provider.dart';
import '../../core/constants/app_constants.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String level;
  final String title;

  const QuizScreen({Key? key, required this.level, required this.title})
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
      context.read<QuizProvider>().loadQuizQuestions(level: widget.level);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _submitQuiz(QuizProvider quizProvider) async {
    // Prepare answers for submission
    final answers = <Map<String, dynamic>>[];
    final questions = quizProvider.questions;
    
    for (int i = 0; i < questions.length; i++) {
      final selectedAnswer = selectedAnswers[i];
      if (selectedAnswer != null) {
        answers.add({
          'quiz_id': questions[i].id,
          'jawaban': selectedAnswer,
        });
      }
    }

    // Submit quiz
    await quizProvider.submitQuiz(answers);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const QuizResultScreen(),
        ),
      );
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Quiz'),
        content: const Text('Apakah Anda yakin ingin keluar? Progress akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (quizProvider.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${quizProvider.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => quizProvider.loadQuizQuestions(level: widget.level),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final questions = quizProvider.questions;
        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: Text('Tidak ada soal tersedia')),
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
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Soal ${currentQuestionIndex + 1}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${currentQuestionIndex + 1}/${questions.length}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (currentQuestionIndex + 1) / questions.length,
                          backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Question Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Text
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppConstants.spacingL),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              currentQuestion.soal,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          SizedBox(height: AppConstants.spacingXL),

                          // Answer Options
                          ...currentQuestion.pilihan.entries.map((entry) {
                            final optionKey = entry.key;
                            final optionText = entry.value;
                            final isSelected = selectedAnswers[currentQuestionIndex] == optionKey;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedAnswers[currentQuestionIndex] = optionKey;
                                    isAnswered = true;
                                  });
                                },
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppConstants.spacingL),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? theme.colorScheme.primary.withOpacity(0.1)
                                        : theme.cardColor,
                                    border: Border.all(
                                      color: isSelected 
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outline.withOpacity(0.3),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected 
                                              ? theme.colorScheme.primary
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected 
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.outline,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected 
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                      SizedBox(width: AppConstants.spacingM),
                                      Expanded(
                                        child: Text(
                                          '$optionKey. $optionText',
                                          style: theme.textTheme.bodyLarge?.copyWith(
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
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                  // Navigation Buttons
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Row(
                      children: [
                        if (currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  currentQuestionIndex--;
                                  isAnswered = selectedAnswers.containsKey(currentQuestionIndex);
                                });
                              },
                              child: const Text('Sebelumnya'),
                            ),
                          ),
                        if (currentQuestionIndex > 0) SizedBox(width: AppConstants.spacingM),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isAnswered ? () {
                              if (currentQuestionIndex < questions.length - 1) {
                                setState(() {
                                  currentQuestionIndex++;
                                  isAnswered = selectedAnswers.containsKey(currentQuestionIndex);
                                });
                              } else {
                                _submitQuiz(quizProvider);
                              }
                            } : null,
                            child: Text(
                              currentQuestionIndex < questions.length - 1 
                                  ? 'Selanjutnya' 
                                  : 'Selesai',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
