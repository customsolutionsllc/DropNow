import 'package:flutter/material.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/models/models.dart';
import 'package:drop_now/core/services/services.dart';
import 'package:drop_now/app/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  final PreferencesService prefsService;
  final CommandGenerationService commandService;
  final SchedulingService schedulingService;
  final NotificationService notificationService;
  final ExecutionStorageService storageService;
  final StatsService statsService;
  final AdService adService;
  final PremiumService premiumService;
  final FirestoreSyncService? syncService;
  final VoidCallback? onSettingsChanged;

  const HomeScreen({
    super.key,
    required this.prefsService,
    required this.commandService,
    required this.schedulingService,
    required this.notificationService,
    required this.storageService,
    required this.statsService,
    required this.adService,
    required this.premiumService,
    this.syncService,
    this.onSettingsChanged,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  WorkoutCommand? _latestCommand;
  bool _isActive = false;
  String? _lastFeedback;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    setState(() {
      _isActive = widget.prefsService.isSystemActive;
    });
  }

  void refresh() {
    _loadState();
  }

  Future<void> _toggleSystem(bool value) async {
    await widget.prefsService.setSystemActive(value);
    setState(() => _isActive = value);
    if (value) {
      await widget.notificationService.requestPermission();
      await widget.schedulingService.scheduleToday();
    } else {
      await widget.notificationService.cancelAll();
    }
    widget.onSettingsChanged?.call();
  }

  Future<void> _dropMeOne() async {
    final command = widget.commandService.generate(
      difficulty: widget.prefsService.difficulty,
      personality: widget.prefsService.personality,
    );
    setState(() => _latestCommand = command);

    if (!mounted) return;
    final result = await CommandDetailSheet.show(context, command);

    if (result != null && mounted) {
      await _recordAction(command, result);
    }
  }

  Future<void> _recordAction(
    WorkoutCommand command,
    CommandStatus status,
  ) async {
    // Prevent duplicate recording
    if (widget.storageService.isRecorded(command.id)) return;

    final calories = status == CommandStatus.completed
        ? command.estimatedCalories
        : 0.0;

    final record = ExecutionRecord(
      id: command.id,
      timestamp: DateTime.now(),
      date: ExecutionStorageService.dateKey(DateTime.now()),
      workoutType: command.workoutType,
      amount: command.amount,
      difficulty: command.difficulty,
      personality: command.personality,
      status: status,
      calories: calories,
      displayText: command.displayText,
    );

    await widget.storageService.addRecord(record);

    // Sync to cloud in background
    widget.syncService?.syncRecord(record);

    // Check if interstitial ad should trigger (after completed commands)
    if (status == CommandStatus.completed) {
      final shouldShowAd = widget.adService.onCommandCompleted();
      if (shouldShowAd) {
        await widget.adService.showInterstitialAd();
      }
    }

    final feedback = status == CommandStatus.completed
        ? FeedbackService.onDone(command.personality)
        : FeedbackService.onSkipped(command.personality);

    setState(() {
      _lastFeedback = feedback;
    });

    if (mounted) {
      _showFeedbackSnackbar(feedback, status);
    }
  }

  void _showFeedbackSnackbar(String message, CommandStatus status) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: status == CommandStatus.completed
            ? AppColors.success
            : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onLatestCommandTap() async {
    if (_latestCommand == null) return;

    // If already recorded, just show the detail without action buttons
    if (widget.storageService.isRecorded(_latestCommand!.id)) {
      // Show read-only detail — open with feedbackMessage only
      await CommandDetailSheet.show(
        context,
        _latestCommand!,
        feedbackMessage: _lastFeedback,
      );
      return;
    }

    final result = await CommandDetailSheet.show(context, _latestCommand!);
    if (result != null && mounted) {
      await _recordAction(_latestCommand!, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = widget.prefsService;
    final scheduler = widget.schedulingService;
    final stats = widget.statsService;
    final todayStats = stats.todayStats;
    final streak = stats.currentStreak;

    // Check streak protection eligibility
    final streakProtectionEligible = widget.adService
        .isStreakProtectionEligible(
          currentStreak: streak,
          completedToday: todayStats.completed,
          skippedToday: todayStats.skipped,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _isActive
                    ? 'System armed. Stay ready.'
                    : AppStrings.homeGreeting,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildSystemToggleCard(context),
              const SizedBox(height: AppSpacing.lg),

              if (_latestCommand != null) ...[
                const SectionHeader(title: 'Latest Command'),
                _buildLatestCommandCard(context, _latestCommand!),
                const SizedBox(height: AppSpacing.lg),
              ],

              const SectionHeader(title: 'Your Stats'),
              Semantics(
                label:
                    'Current streak: $streak days. Total completed: ${stats.totalCompleted}',
                child: RepaintBoundary(
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: AppStrings.homeStreak,
                          value: '$streak',
                          icon: Icons.local_fire_department_rounded,
                          accentColor: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatCard(
                          label: 'Completed',
                          value: '${stats.totalCompleted}',
                          icon: Icons.check_circle_rounded,
                          accentColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Streak protection card (shown when eligible)
              if (streakProtectionEligible) ...[
                RepaintBoundary(
                  child: _buildStreakProtectionCard(context, streak),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              const SectionHeader(title: "Today's Progress"),
              RepaintBoundary(child: _buildTodayProgress(context, todayStats)),
              const SizedBox(height: AppSpacing.lg),

              const SectionHeader(title: 'Quick Actions'),
              _buildQuickActions(context),
              const SizedBox(height: AppSpacing.lg),

              const SectionHeader(title: 'Next Command'),
              _buildUpcomingCard(context, scheduler),
              const SizedBox(height: AppSpacing.md),

              const SectionHeader(title: 'Current Settings'),
              _buildSettingsSummary(context, prefs),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakProtectionCard(BuildContext context, int streak) {
    final isPremium = widget.premiumService.isPremium;

    return DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak in Danger!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPremium
                          ? 'Your $streak-day streak is at risk. Tap to protect it.'
                          : 'Your $streak-day streak is at risk. Watch an ad to protect it.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              button: true,
              label: 'Protect your streak',
              child: ElevatedButton.icon(
                onPressed: _onStreakProtectionTap,
                icon: Icon(
                  isPremium
                      ? Icons.shield_rounded
                      : Icons.play_circle_filled_rounded,
                  size: 20,
                ),
                label: const Text('Save My Streak'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onStreakProtectionTap() async {
    // Premium users protect streak directly (no ad).
    if (widget.premiumService.isPremium) {
      final protected = await widget.premiumService.protectStreakPremium();
      if (protected && mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Streak protected! 🛡️ Keep it going tomorrow.',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }

    // Free users watch a rewarded ad.
    if (!widget.adService.isRewardedAdReady) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ad not ready yet. Try again in a moment.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }

    final rewarded = await widget.adService.showRewardedAd();
    if (rewarded && mounted) {
      setState(() {}); // Refresh UI — streak protection is now active
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Streak protected! 🛡️ Keep it going tomorrow.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildSystemToggleCard(BuildContext context) {
    return Semantics(
      toggled: _isActive,
      label: _isActive
          ? 'Command system is active'
          : 'Command system is inactive',
      child: DashboardCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _isActive ? AppColors.success : AppColors.textMuted,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: _isActive
                        ? [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _isActive ? 'SYSTEM ACTIVE' : 'SYSTEM INACTIVE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 2.0,
                      color: _isActive
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                Switch(
                  value: _isActive,
                  onChanged: _toggleSystem,
                  activeThumbColor: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _isActive
                  ? 'Commands will drop throughout the day. Stay ready, soldier.'
                  : 'Turn on the system to start receiving commands.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestCommandCard(BuildContext context, WorkoutCommand command) {
    final isRecorded = widget.storageService.isRecorded(command.id);

    return DashboardCard(
      onTap: _onLatestCommandTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isRecorded
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isRecorded
                      ? Icons.check_circle_rounded
                      : Icons.fitness_center_rounded,
                  color: isRecorded ? AppColors.success : AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      command.workoutType.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isRecorded
                            ? AppColors.success
                            : AppColors.accent,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      command.displayText,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isRecorded)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DONE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgress(BuildContext context, DailyStats todayStats) {
    final total = todayStats.totalCommands;
    final done = todayStats.completed;
    final skipped = todayStats.skipped;
    final cals = todayStats.totalCalories;
    final progress = total > 0 ? done / total : 0.0;

    return DashboardCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commands Obeyed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '$done / $total',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceLight,
              color: AppColors.accent,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _progressStat(context, '$done', 'Done', AppColors.success),
              _progressStat(context, '$skipped', 'Skipped', AppColors.error),
              _progressStat(
                context,
                '${cals.toStringAsFixed(0)} cal',
                'Burned',
                AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressStat(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DashboardCard(
            onTap: _dropMeOne,
            child: Column(
              children: [
                const Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.accent,
                  size: 28,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Drop Me One',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: DashboardCard(
            onTap: () {},
            child: Column(
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: AppColors.info,
                  size: 28,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'View History',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingCard(BuildContext context, SchedulingService scheduler) {
    final next = scheduler.nextUpcoming;
    final remaining = scheduler.remainingCount;

    if (!_isActive) {
      return DashboardCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.power_settings_new_rounded,
                color: AppColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System is off',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Activate the system above to start receiving commands.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (next == null) {
      return DashboardCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No more commands today',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'All commands have been delivered. See you tomorrow.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return DashboardCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.timer_rounded,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next drop at ${SchedulingService.formatDateTime(next.scheduledTime)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '$remaining command${remaining == 1 ? '' : 's'} remaining today.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSummary(BuildContext context, PreferencesService prefs) {
    return DashboardCard(
      child: Column(
        children: [
          _settingsRow(context, 'Personality', prefs.personality.label),
          const Divider(height: 1, indent: 0),
          _settingsRow(context, 'Difficulty', prefs.difficulty.label),
          const Divider(height: 1, indent: 0),
          _settingsRow(context, 'Frequency', '${prefs.frequency}x / day'),
          const Divider(height: 1, indent: 0),
          _settingsRow(
            context,
            'Active Window',
            '${SchedulingService.formatTime(prefs.windowStart)} - ${SchedulingService.formatTime(prefs.windowEnd)}',
          ),
        ],
      ),
    );
  }

  Widget _settingsRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
