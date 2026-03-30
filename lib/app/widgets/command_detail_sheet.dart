import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/models/models.dart';

class CommandDetailSheet extends StatefulWidget {
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
  State<CommandDetailSheet> createState() => _CommandDetailSheetState();
}

class _CommandDetailSheetState extends State<CommandDetailSheet>
    with SingleTickerProviderStateMixin {
  static const _countdownSeconds = 60;
  int _remaining = _countdownSeconds;
  Timer? _timer;
  late AnimationController _doneAnimController;
  late Animation<double> _doneScaleAnim;
  bool _showDoneEffect = false;

  @override
  void initState() {
    super.initState();
    _doneAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _doneScaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _doneAnimController, curve: Curves.elasticOut),
    );

    // Only start timer if this is a new (actionable) command, not read-only
    if (widget.feedbackMessage == null) {
      // Vibrate on command appearance
      HapticFeedback.mediumImpact();
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _remaining--);
      if (_remaining <= 0) {
        timer.cancel();
        // Auto-skip when time runs out
        Navigator.of(context).pop(CommandStatus.skipped);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _doneAnimController.dispose();
    super.dispose();
  }

  void _onDone() async {
    HapticFeedback.heavyImpact();
    setState(() => _showDoneEffect = true);
    _doneAnimController.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) {
      Navigator.of(context).pop(CommandStatus.completed);
    }
  }

  void _onSkip() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(CommandStatus.skipped);
  }

  @override
  Widget build(BuildContext context) {
    final isActionable = widget.feedbackMessage == null;

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

            // Countdown timer (only for actionable commands)
            if (isActionable) ...[
              _buildCountdownBar(context),
              const SizedBox(height: AppSpacing.md),
            ],

            // Command icon with done animation
            ScaleTransition(
              scale: _doneScaleAnim,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _showDoneEffect
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  _showDoneEffect
                      ? Icons.check_circle_rounded
                      : Icons.fitness_center_rounded,
                  color: _showDoneEffect ? AppColors.success : AppColors.accent,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Command text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                widget.command.displayText,
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
                  label: widget.command.workoutType.label,
                  icon: Icons.fitness_center_rounded,
                ),
                _detailChip(
                  context,
                  label: widget.command.difficulty.label,
                  icon: Icons.speed_rounded,
                ),
                _detailChip(
                  context,
                  label: widget.command.personality.label,
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
                  label: widget.command.amountLabel,
                  icon: Icons.repeat_rounded,
                ),
                _detailChip(
                  context,
                  label:
                      '~${widget.command.estimatedCalories.toStringAsFixed(0)} cal',
                  icon: Icons.local_fire_department_rounded,
                ),
              ],
            ),

            // Feedback message (shown after action on previous command)
            if (widget.feedbackMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Text(
                  widget.feedbackMessage!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // DONE / SKIPPED buttons (only if actionable)
            if (isActionable)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _onSkip,
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
                        onPressed: _onDone,
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
              )
            else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(
                      color: AppColors.surfaceBorder,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.buttonRadius,
                      ),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownBar(BuildContext context) {
    final progress = _remaining / _countdownSeconds;
    final isUrgent = _remaining <= 15;
    final color = isUrgent ? AppColors.error : AppColors.accent;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_rounded, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              '${_remaining}s remaining',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceLight,
            color: color,
            minHeight: 4,
          ),
        ),
      ],
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
