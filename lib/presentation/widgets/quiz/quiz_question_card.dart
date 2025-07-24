import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/quiz_model.dart';

class QuizQuestionCard extends StatelessWidget {
  final Quiz question;
  final int questionNumber;
  final int totalQuestions;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;
  final bool showCorrectAnswer;
  
  const QuizQuestionCard({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    this.selectedAnswer,
    required this.onAnswerSelected,
    this.showCorrectAnswer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = [
      {'key': 'A', 'value': question.pilihanA},
      {'key': 'B', 'value': question.pilihanB},
      {'key': 'C', 'value': question.pilihanC},
      {'key': 'D', 'value': question.pilihanD},
    ];

    return Card(
      margin: AppConstants.paddingMedium,
      child: Padding(
        padding: AppConstants.paddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soal $questionNumber dari $totalQuestions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
                    question.level.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            
            // Question text
            Text(
              question.soal,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            
            // Answer options
            ...options.map((option) {
              final isSelected = selectedAnswer == option['key'];
              final isCorrect = showCorrectAnswer && question.jawabanBenar == option['key'];
              final isWrong = showCorrectAnswer && isSelected && !isCorrect;
              
              Color? backgroundColor;
              Color? borderColor;
              Color? textColor;
              
              if (showCorrectAnswer) {
                if (isCorrect) {
                  backgroundColor = AppConstants.successColor.withOpacity(0.1);
                  borderColor = AppConstants.successColor;
                  textColor = AppConstants.successColor;
                } else if (isWrong) {
                  backgroundColor = AppConstants.errorColor.withOpacity(0.1);
                  borderColor = AppConstants.errorColor;
                  textColor = AppConstants.errorColor;
                }
              } else if (isSelected) {
                backgroundColor = AppConstants.primaryColor.withOpacity(0.1);
                borderColor = AppConstants.primaryColor;
                textColor = AppConstants.primaryColor;
              }
              
              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
                child: InkWell(
                  onTap: showCorrectAnswer ? null : () => onAnswerSelected(option['key']!),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  child: Container(
                    padding: AppConstants.paddingMedium,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(
                        color: borderColor ?? Colors.grey.withOpacity(0.3),
                        width: borderColor != null ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: textColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              option['key']!,
                              style: TextStyle(
                                color: textColor ?? Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMedium),
                        Expanded(
                          child: Text(
                            option['value']!,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: isSelected || isCorrect ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (showCorrectAnswer && isCorrect)
                          Icon(
                            Icons.check_circle,
                            color: AppConstants.successColor,
                          ),
                        if (showCorrectAnswer && isWrong)
                          Icon(
                            Icons.cancel,
                            color: AppConstants.errorColor,
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
    );
  }
}