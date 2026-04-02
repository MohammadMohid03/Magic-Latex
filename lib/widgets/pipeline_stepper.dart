import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class PipelineStepper extends StatelessWidget {
  final int currentStep;

  const PipelineStepper({super.key, required this.currentStep});

  static const List<_StepData> _steps = [
    _StepData(icon: Icons.camera_alt_rounded, label: 'Image Captured', emoji: '📸'),
    _StepData(icon: Icons.search_rounded, label: 'Extracting Text...', emoji: '🔍'),
    _StepData(icon: Icons.edit_note_rounded, label: 'Generating LaTeX...', emoji: '📝'),
    _StepData(icon: Icons.picture_as_pdf_rounded, label: 'Building PDF...', emoji: '📄'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isCompleted = currentStep > index + 1;
        final isActive = currentStep == index + 1;
        final isPending = currentStep < index + 1;

        return Column(
          children: [
            _buildStepRow(context, step, isCompleted, isActive, isPending, index),
            if (index < _steps.length - 1) _buildConnector(isCompleted),
          ],
        );
      }),
    );
  }

  Widget _buildStepRow(
    BuildContext context,
    _StepData step,
    bool isCompleted,
    bool isActive,
    bool isPending,
    int index,
  ) {
    return Animate(
      effects: [
        FadeEffect(
          delay: Duration(milliseconds: index * 150),
          duration: const Duration(milliseconds: 400),
        ),
        SlideEffect(
          begin: const Offset(-0.1, 0),
          end: Offset.zero,
          delay: Duration(milliseconds: index * 150),
          duration: const Duration(milliseconds: 400),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent.withValues(alpha: 0.1)
              : isCompleted
                  ? AppColors.success.withValues(alpha: 0.05)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? AppColors.accent.withValues(alpha: 0.3)
                : isCompleted
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.success.withValues(alpha: 0.15)
                    : isActive
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.darkCard,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success
                      : isActive
                          ? AppColors.accent
                          : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: AppColors.success, size: 22)
                    : isActive
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.accent,
                            ),
                          )
                        : Icon(step.icon, color: AppColors.textTertiary, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${step.emoji}  ${step.label}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isPending
                              ? AppColors.textTertiary
                              : isCompleted
                                  ? AppColors.success
                                  : AppColors.textPrimary,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                  ),
                  if (isCompleted)
                    Text(
                      'Completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success.withValues(alpha: 0.7),
                          ),
                    ),
                ],
              ),
            ),
            // Checkmark badge
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✅',
                  style: TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector(bool isCompleted) {
    return Container(
      width: 2,
      height: 24,
      margin: const EdgeInsets.only(left: 41),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.success.withValues(alpha: 0.5) : AppColors.divider,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

class _StepData {
  final IconData icon;
  final String label;
  final String emoji;

  const _StepData({required this.icon, required this.label, required this.emoji});
}
