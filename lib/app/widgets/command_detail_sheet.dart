import 'package:flutter/material.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/models/models.dart';

class CommandDetailSheet extends StatelessWidget {
  final WorkoutCommand command;
  final String? feedbackMessage;

  const CommandDetailSheet({
    super.key,
    required this.command,
    this.feedbackMessage,
  });

  /// Show the sheet and return the user's action (completed/skipped) or null if dismissed.
  static Future<CommandStatus?> show(
    BuildContext context,
    WorkoutCommand command, {
    String? feedbackMessage,
  }) {
    return showModalBottomSheet<CommandStatus>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => CommandDetailSheet(
        command: command,
        feedbackMessage: feedbackMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.xl,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Command icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.accent,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Command text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                command.displayText,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _detailChip(
                  context,
                  label: command.workoutType.label,
                  icon: Icons.fitness_center_rounded,
                ),
                _detailChip(
                  context,
                  label: command.difficulty.label,
                  icon: Icons.speed_rounded,
                ),
                _detailChip(
                  context,
                  label: command.personality.label,
                  icon: Icons.psychology_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Amount + estimated cal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _detailChip(
                  context,
                  label: command.amountLabel,
                  icon: Icons.repeat_rounded,
                ),
                _detailChip(
                  context,
                  label: '~${command.estimatedCalories.toStringAsFixed(0)} cal',
                  icon: Icons.local_fire_department_rounded,
                ),
              ],
            ),

            // Feedback message (shown after action on previous command)
            if (feedbackMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Text(
                  feedbackMessage!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // DONE / SKIPPED buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pop(CommandStatus.skipped),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      label: const Text('Skip'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.buttonRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pop(CommandStatus.completed),
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.buttonRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
