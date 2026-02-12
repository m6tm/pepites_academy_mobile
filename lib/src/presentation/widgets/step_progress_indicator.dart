import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isEven) {
          int stepIndex = index ~/ 2;
          bool isActive = stepIndex <= currentStep;
          bool isCompleted = stepIndex < currentStep;

          return _buildStepCircle(stepIndex + 1, isActive, isCompleted);
        } else {
          int lineIndex = index ~/ 2;
          bool isCompleted = lineIndex < currentStep;
          return _buildLine(isCompleted);
        }
      }),
    );
  }

  Widget _buildStepCircle(int number, bool isActive, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.primary
            : (isActive
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.transparent),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? AppColors.primary
              : Colors.grey.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                "$number",
                style: TextStyle(
                  color: isActive ? AppColors.primary : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildLine(bool isCompleted) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 2,
        color: isCompleted
            ? AppColors.primary
            : Colors.grey.withValues(alpha: 0.3),
      ),
    );
  }
}
