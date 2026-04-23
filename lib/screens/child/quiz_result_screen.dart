import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.childId,
    required this.quizIndex,
    required this.correct,
    required this.total,
    required this.stars,
  });

  final int childId;
  final int quizIndex;
  final int correct;
  final int total;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('نتيجة الاختبار')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$correct من $total',
              style: AppTextStyles.heading1.copyWith(fontSize: 36),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              List.filled(stars, '⭐').join(),
              style: const TextStyle(fontSize: 40),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$stars من 3 نجوم',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'إعادة الاختبار',
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => QuizScreen(
                      childId: childId,
                      quizIndex: quizIndex,
                    ),
                  ),
                );
              },
              width: double.infinity,
              color: AppColors.warning,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'العودة',
              onPressed: () {
                Navigator.of(context).pop();
              },
              width: double.infinity,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
