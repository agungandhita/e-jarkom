import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../presentation/providers/quiz_provider.dart';
import 'quiz_level_screen.dart';
import '../main_screen.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({Key? key}) : super(key: key);

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

    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
    _scoreAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  String _getGradeText(double percentage) {
    if (percentage >= 90) return 'Excellent!';
    if (percentage >= 80) return 'Great!';
    if (percentage >= 70) return 'Good!';
    if (percentage >= 60) return 'Fair';
    return 'Keep Trying!';
  }

  Color _getGradeColor(double percentage, ThemeData theme) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.blue;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.amber;
    return Colors.red;
  }

  IconData _getGradeIcon(double percentage) {
    if (percentage >= 90) return Icons.emoji_events;
    if (percentage >= 80) return Icons.star;
    if (percentage >= 70) return Icons.thumb_up;
    if (percentage >= 60) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final results = quizProvider.getQuizResults();

        if (results.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Hasil Quiz'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: Text('Tidak ada hasil quiz tersedia')),
          );
        }

        final percentage = (results['percentage'] ?? 0).toDouble();
        final gradeText = _getGradeText(percentage);
        final gradeColor = _getGradeColor(percentage, theme);
        final gradeIcon = _getGradeIcon(percentage);

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: const Text('Hasil Quiz'),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.spacingXL),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            gradeColor.withOpacity(0.1),
                            gradeColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusXL,
                        ),
                        border: Border.all(
                          color: gradeColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Grade Icon
                          ScaleTransition(
                            scale: _scoreAnimation,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: gradeColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: gradeColor.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                gradeIcon,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),

                          SizedBox(height: AppConstants.spacingL),

                          // Grade Text
                          Text(
                            gradeText,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: gradeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: AppConstants.spacingM),

                          // Score Percentage
                          AnimatedBuilder(
                            animation: _scoreAnimation,
                            builder: (context, child) {
                              return Text(
                                '${(percentage * _scoreAnimation.value).toInt()}%',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: gradeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),

                          SizedBox(height: AppConstants.spacingS),

                          Text(
                            'Skor Anda',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppConstants.spacingXL),

                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            'Total Soal',
                            results['total_soal'].toString(),
                            Icons.quiz,
                            Colors.blue,
                          ),
                        ),
                        SizedBox(width: AppConstants.spacingM),
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            'Benar',
                            results['benar'].toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppConstants.spacingM),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            'Salah',
                            results['salah'].toString(),
                            Icons.cancel,
                            Colors.red,
                          ),
                        ),
                        SizedBox(width: AppConstants.spacingM),
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            'Level',
                            results['level'].toString().toUpperCase(),
                            Icons.trending_up,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppConstants.spacingXL),

                    // Action Buttons
                    Column(
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
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.spacingL,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusM,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Coba Quiz Lain',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: AppConstants.spacingM),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.spacingL,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusM,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Kembali ke Dashboard',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: AppConstants.spacingS),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: AppConstants.spacingS),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
