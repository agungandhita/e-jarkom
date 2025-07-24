import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/quiz_provider.dart';
import '../../core/constants/app_constants.dart';
import 'quiz_screen.dart';

class QuizLevelScreen extends StatefulWidget {
  const QuizLevelScreen({Key? key}) : super(key: key);

  @override
  State<QuizLevelScreen> createState() => _QuizLevelScreenState();
}

class _QuizLevelScreenState extends State<QuizLevelScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    // Load quiz levels
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadQuizLevel();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Quiz Jaringan Komputer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quizProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: AppConstants.spacingM),
                  Text(
                    'Terjadi Kesalahan',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingS),
                  Text(
                    quizProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingL),
                  ElevatedButton(
                    onPressed: () => quizProvider.loadQuizLevel(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeaderSection(theme),

                    SizedBox(height: AppConstants.spacingXL),

                    // Quiz Levels Grid
                    _buildQuizLevelsGrid(theme, quizProvider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusM,
                  ),
                ),
                child: const Icon(Icons.quiz, color: Colors.white, size: 32),
              ),
              SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Pembelajaran',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingS),
                    Text(
                      'Uji pemahaman Anda tentang jaringan komputer',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizLevelsGrid(ThemeData theme, QuizProvider quizProvider) {
    // Mock quiz levels data
    final quizLevels = [
      {
        'id': '1',
        'title': 'Dasar Jaringan',
        'description': 'Konsep dasar jaringan komputer',
        'difficulty': 'Mudah',
        'questionCount': 10,
        'icon': Icons.network_wifi,
        'color': Colors.green,
      },
      {
        'id': '2',
        'title': 'Protokol Jaringan',
        'description': 'TCP/IP, HTTP, FTP dan protokol lainnya',
        'difficulty': 'Sedang',
        'questionCount': 15,
        'icon': Icons.router,
        'color': Colors.orange,
      },
      {
        'id': '3',
        'title': 'Keamanan Jaringan',
        'description': 'Firewall, VPN, dan keamanan jaringan',
        'difficulty': 'Sulit',
        'questionCount': 20,
        'icon': Icons.security,
        'color': Colors.red,
      },
      {
        'id': '4',
        'title': 'Troubleshooting',
        'description': 'Pemecahan masalah jaringan',
        'difficulty': 'Sedang',
        'questionCount': 12,
        'icon': Icons.build,
        'color': Colors.blue,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.spacingM,
        mainAxisSpacing: AppConstants.spacingM,
        childAspectRatio: 0.8,
      ),
      itemCount: quizLevels.length,
      itemBuilder: (context, index) {
        final level = quizLevels[index];
        return _buildQuizLevelCard(theme, level);
      },
    );
  }

  Widget _buildQuizLevelCard(ThemeData theme, Map<String, dynamic> level) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                QuizScreen(quizId: level['id'], title: level['title']),
          ),
        );
      },
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and Difficulty
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingS),
                    decoration: BoxDecoration(
                      color: (level['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusS,
                      ),
                    ),
                    child: Icon(level['icon'], color: level['color'], size: 24),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (level['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusS,
                      ),
                    ),
                    child: Text(
                      level['difficulty'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: level['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppConstants.spacingM),

              // Title
              Text(
                level['title'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: AppConstants.spacingS),

              // Description
              Text(
                level['description'],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Question Count
              Row(
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: AppConstants.spacingS),
                  Text(
                    '${level['questionCount']} Soal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppConstants.spacingS),

              // Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          quizId: level['id'],
                          title: level['title'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: level['color'],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingS,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusS,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Mulai Quiz',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
