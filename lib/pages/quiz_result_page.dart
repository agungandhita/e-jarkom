import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../utils/constants.dart';
// import '../utils/helpers.dart';
import '../widgets/custom_app_bar.dart';
import 'quiz_page.dart';

class QuizResultPage extends StatelessWidget {
  final QuizResult result;
  final List<QuizQuestion> questions;
  final List<int> userAnswers;
  final String level;

  const QuizResultPage({
    super.key,
    required this.result,
    required this.questions,
    required this.userAnswers,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Hasil Kuis',
        showBackButton: false,
        maxLines: 1,
      ),
      body: Column(
        children: [
          // Result header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              gradient: _getResultGradient(),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.radiusMedium),
                bottomRight: Radius.circular(AppConstants.radiusMedium),
              ),
            ),
            child: Column(
              children: [
                // Score circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${result.percentage}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(),
                          ),
                        ),
                        Text(
                          _getScoreText(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // Result text
                Text(
                  _getResultTitle(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  _getResultSubtitle(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Statistics
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Benar',
                    result.correctAnswers.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    'Salah',
                    result.wrongAnswers.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    'Level',
                    _getLevelText(level),
                    Icons.star,
                    _getLevelColor(level),
                  ),
                ),
              ],
            ),
          ),

          // Review section
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(AppConstants.paddingMedium),
                    child: Text(
                      'Review Jawaban',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        final userAnswer = userAnswers[index];
                        final isCorrect =
                            userAnswer == question.correctAnswerIndex;

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: AppConstants.paddingMedium,
                          ),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusMedium,
                            ),
                            side: BorderSide(
                              color: isCorrect ? Colors.green : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: isCorrect
                                  ? Colors.green
                                  : Colors.red,
                              child: Icon(
                                isCorrect ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              'Soal ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              question.question,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(
                                  AppConstants.paddingMedium,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pertanyaan:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      question.question,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(
                                      height: AppConstants.paddingMedium,
                                    ),

                                    // Options
                                    ...question.options.asMap().entries.map((
                                      entry,
                                    ) {
                                      final optionIndex = entry.key;
                                      final option = entry.value;
                                      final isUserAnswer =
                                          optionIndex == userAnswer;
                                      final isCorrectAnswer =
                                          optionIndex ==
                                          question.correctAnswerIndex;

                                      Color? backgroundColor;
                                      Color? textColor;
                                      IconData? icon;

                                      if (isCorrectAnswer) {
                                        backgroundColor = Colors.green
                                            .withOpacity(0.1);
                                        textColor = Colors.green;
                                        icon = Icons.check;
                                      } else if (isUserAnswer && !isCorrect) {
                                        backgroundColor = Colors.red
                                            .withOpacity(0.1);
                                        textColor = Colors.red;
                                        icon = Icons.close;
                                      }

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: backgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: backgroundColor != null
                                                ? (textColor ??
                                                      Colors.transparent)
                                                : Colors.grey.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${String.fromCharCode(65 + optionIndex)}. ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    textColor ?? Colors.black87,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: TextStyle(
                                                  color:
                                                      textColor ??
                                                      Colors.black87,
                                                ),
                                              ),
                                            ),
                                            if (icon != null)
                                              Icon(
                                                icon,
                                                size: 16,
                                                color: textColor,
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),

                                    if (question.explanation.isNotEmpty) ...[
                                      const SizedBox(
                                        height: AppConstants.paddingMedium,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.lightbulb,
                                                  size: 16,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Penjelasan:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              question.explanation,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuizPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMedium,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMedium,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Menu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getResultGradient() {
    if (result.percentage >= 80) {
      return const LinearGradient(
        colors: [Colors.green, Colors.lightGreen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (result.percentage >= 60) {
      return const LinearGradient(
        colors: [Colors.orange, Colors.deepOrange],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Colors.red, Colors.redAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Color _getScoreColor() {
    if (result.percentage >= 80) {
      return Colors.green;
    } else if (result.percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getScoreText() {
    if (result.percentage >= 80) {
      return 'EXCELLENT';
    } else if (result.percentage >= 60) {
      return 'GOOD';
    } else {
      return 'NEEDS WORK';
    }
  }

  String _getResultTitle() {
    if (result.percentage >= 80) {
      return 'Luar Biasa!';
    } else if (result.percentage >= 60) {
      return 'Bagus!';
    } else {
      return 'Tetap Semangat!';
    }
  }

  String _getResultSubtitle() {
    if (result.percentage >= 80) {
      return 'Anda menguasai materi dengan sangat baik';
    } else if (result.percentage >= 60) {
      return 'Anda cukup menguasai materi';
    } else {
      return 'Anda perlu belajar lebih giat lagi';
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
}
