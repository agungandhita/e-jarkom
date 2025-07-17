import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String? _selectedLevel = 'mudah';
  bool _isQuizStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: 'Kuis Interaktif', maxLines: 1),
      body: _isQuizStarted ? _buildQuizContent() : _buildLevelSelection(),
    );
  }

  Widget _buildLevelSelection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              gradient: AppConstants.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Level Kuis',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'Uji pengetahuan Anda tentang alat-alat teknik',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Level selection
          const Text(
            'Pilih Tingkat Kesulitan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          ...['mudah', 'sedang', 'sulit'].map((level) {
            final color = _getLevelColor(level);
            final isSelected = _selectedLevel == level;

            return Padding(
              padding: const EdgeInsets.only(
                bottom: AppConstants.paddingMedium,
              ),
              child: Card(
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  side: BorderSide(
                    color: isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedLevel = level;
                    });
                  },
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: color.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getLevelIcon(level),
                            color: color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getLevelText(level),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? color : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getLevelDescription(level),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '10 pertanyaan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: color, size: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),

          const Spacer(),

          // Start quiz button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _startQuiz();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                ),
              ),
              child: const Text(
                'Mulai Kuis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz, size: 100, color: AppConstants.primaryColor),
          SizedBox(height: 20),
          Text(
            'Quiz akan segera dimulai!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Fitur quiz sedang dalam pengembangan',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _startQuiz() {
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih level terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isQuizStarted = true;
    });
  }

  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'mudah':
        return Icons.sentiment_satisfied;
      case 'sedang':
        return Icons.sentiment_neutral;
      case 'sulit':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.help;
    }
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'mudah':
        return const Color(0xFF4CAF50);
      case 'sedang':
        return const Color(0xFFFF9800);
      case 'sulit':
        return const Color(0xFFE91E63);
      default:
        return Colors.grey;
    }
  }

  String _getLevelText(String level) {
    switch (level) {
      case 'mudah':
        return 'Mudah';
      case 'sedang':
        return 'Sedang';
      case 'sulit':
        return 'Sulit';
      default:
        return 'Unknown';
    }
  }

  String _getLevelDescription(String level) {
    switch (level) {
      case 'mudah':
        return 'Pertanyaan dasar untuk pemula';
      case 'sedang':
        return 'Pertanyaan menengah untuk yang sudah berpengalaman';
      case 'sulit':
        return 'Pertanyaan sulit untuk ahli';
      default:
        return 'Deskripsi tidak tersedia';
    }
  }
}
