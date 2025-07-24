import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'quiz_level_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final String quizTitle;
  final int totalSoal;
  final int benar;
  final Map<int, String> selectedAnswers;
  final List<Map<String, dynamic>> questions;

  const QuizResultScreen({
    Key? key,
    required this.quizTitle,
    required this.totalSoal,
    required this.benar,
    required this.selectedAnswers,
    required this.questions,
  }) : super(key: key);

  // Compatibility getters
  int get totalQuestions => totalSoal;
  int get correctAnswers => benar;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scoreAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _scoreAnimation =
        Tween<double>(
          begin: 0.0,
          end: widget.correctAnswers / widget.totalQuestions,
        ).animate(
          CurvedAnimation(
            parent: _scoreAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Delay score animation
    Future.delayed(const Duration(milliseconds: 500), () {
      _scoreAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  double get scorePercentage =>
      (widget.correctAnswers / widget.totalQuestions) * 100;

  String get gradeText {
    if (scorePercentage >= 90) return 'Excellent!';
    if (scorePercentage >= 80) return 'Great!';
    if (scorePercentage >= 70) return 'Good!';
    if (scorePercentage >= 60) return 'Fair';
    return 'Need Improvement';
  }

  Color get gradeColor {
    if (scorePercentage >= 90) return Colors.green;
    if (scorePercentage >= 80) return Colors.lightGreen;
    if (scorePercentage >= 70) return Colors.orange;
    if (scorePercentage >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Hasil Quiz'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              children: [
                // Score Card
                _buildScoreCard(theme),

                SizedBox(height: AppConstants.spacingXL),

                // Statistics
                _buildStatistics(theme),

                SizedBox(height: AppConstants.spacingXL),

                // Review Answers
                _buildReviewSection(theme),

                SizedBox(height: AppConstants.spacingXL),

                // Action Buttons
                _buildActionButtons(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradeColor, gradeColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXL),
        boxShadow: [
          BoxShadow(
            color: gradeColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Trophy Icon
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              scorePercentage >= 70
                  ? Icons.emoji_events
                  : Icons.sentiment_neutral,
              size: 48,
              color: Colors.white,
            ),
          ),

          SizedBox(height: AppConstants.spacingL),

          // Grade Text
          Text(
            gradeText,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: AppConstants.spacingM),

          // Score Circle
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _scoreAnimation.value,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${(_scoreAnimation.value * 100).round()}%',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Score',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          SizedBox(height: AppConstants.spacingL),

          // Quiz Title
          Text(
            widget.quizTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Benar',
            widget.correctAnswers.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildStatCard(
            theme,
            'Salah',
            (widget.totalQuestions - widget.correctAnswers).toString(),
            Icons.cancel,
            Colors.red,
          ),
        ),
        SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildStatCard(
            theme,
            'Total',
            widget.totalQuestions.toString(),
            Icons.quiz,
            theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: AppConstants.spacingS),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rate_review, color: theme.colorScheme.primary),
              SizedBox(width: AppConstants.spacingS),
              Text(
                'Review Jawaban',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: AppConstants.spacingL),

          ...List.generate(
            widget.questions.length,
            (index) => _buildReviewItem(theme, index),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(ThemeData theme, int index) {
    final question = widget.questions[index];
    final selectedAnswer = widget.selectedAnswers[index];
    final correctAnswer = question['correctAnswer'];
    final isCorrect = selectedAnswer == correctAnswer;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 20,
              ),
              SizedBox(width: AppConstants.spacingS),
              Expanded(
                child: Text(
                  'Soal ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppConstants.spacingS),

          Text(question['question'], style: theme.textTheme.bodyMedium),

          SizedBox(height: AppConstants.spacingS),

          if (selectedAnswer != null) ...[
            Text(
              'Jawaban Anda: $selectedAnswer',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          if (!isCorrect) ...[
            Text(
              'Jawaban Benar: $correctAnswer',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizLevelScreen(),
                ),
                (route) => route.isFirst,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingL,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
              ),
            ),
            child: const Text(
              'Kembali ke Quiz',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),

        SizedBox(height: AppConstants.spacingM),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingL,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
              ),
            ),
            child: const Text(
              'Kembali ke Beranda',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// Type alias for backward compatibility
typedef QuizResultPage = QuizResultScreen;
