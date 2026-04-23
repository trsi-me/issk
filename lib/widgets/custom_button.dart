import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_radius.dart';
import '../utils/app_text_styles.dart';
import 'pressable_scale.dart';

/// زر موحّد بلا ظلال وبحدود متساوية عند الحاجة.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primary,
    this.width,
    this.height,
    this.textColor = Colors.white,
    this.enabled = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final double? width;
  final double? height;
  final Color textColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;
    final r = BorderRadius.circular(AppRadius.lg);
    return PressableScale(
      child: SizedBox(
        width: width,
        height: height ?? 52,
        child: Material(
          color: enabled ? color : AppColors.textSecondary,
          borderRadius: r,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: r,
            onTap: effectiveOnPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.buttonText.copyWith(color: textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
