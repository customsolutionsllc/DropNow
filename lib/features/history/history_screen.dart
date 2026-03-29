import 'package:flutter/material.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/models/models.dart';
import 'package:drop_now/core/services/services.dart';
import 'package:drop_now/app/widgets/widgets.dart';

class HistoryScreen extends StatefulWidget {
  final ExecutionStorageService storageService;
  final StatsService statsService;
  final AdService adService;

  const HistoryScreen({
    super.key,
    required this.storageService,
    required this.statsService,
    required this.adService,
  });

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  late String _selectedDate;
  late List<String> _allDates;

  @override
  void initState() {
    super.initState();
    _selectedDate = ExecutionStorageService.dateKey(DateTime.now());
    _allDates = widget.storageService.allDates;
  }

  void refresh() {
    setState(() {
      _allDates = widget.storageService.allDates;
    });
  }

  void _navigateDate(int direction) {
    final currentIndex = _allDates.indexOf(_selectedDate);
    if (direction < 0) {
      // Go to older date
      if (currentIndex < _allDates.length - 1 && currentIndex >= 0) {
        setState(() => _selectedDate = _allDates[currentIndex + 1]);
      } else if (currentIndex == -1 && _allDates.isNotEmpty) {
        // Current date has no data, jump to most recent date with data
        setState(() => _selectedDate = _allDates.first);
      }
    } else {
      // Go to newer date
      if (currentIndex > 0) {
        setState(() => _selectedDate = _allDates[currentIndex - 1]);
      } else if (currentIndex == 0) {
        // Already at most recent, go to today
        setState(() {
          _selectedDate = ExecutionStorageService.dateKey(DateTime.now());
        });
      }
    }
  }

  String _formatDateLabel(String dateStr) {
    final today = ExecutionStorageService.dateKey(DateTime.now());
    final yesterday = ExecutionStorageService.dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    if (dateStr == today) return 'Today';
    if (dateStr == yesterday) return 'Yesterday';
    // Parse and format
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      final months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = int.tryParse(parts[1]) ?? 1;
      return '${months[month]} ${int.tryParse(parts[2]) ?? parts[2]}, ${parts[0]}';
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final dayStats = widget.statsService.statsForDate(_selectedDate);
    final records = widget.storageService.getRecordsForDate(_selectedDate);
    final allTimeStats = widget.statsService;

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
                AppStrings.historyTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your exercise command log.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),

              // All-time summary
              const SectionHeader(title: 'All Time'),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Completed',
                      value: '${allTimeStats.totalCompleted}',
                      icon: Icons.check_circle_rounded,
                      accentColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      label: 'Calories',
                      value: allTimeStats.totalCalories.toStringAsFixed(0),
                      icon: Icons.local_fire_department_rounded,
                      accentColor: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Streak',
                      value: '${allTimeStats.currentStreak}',
                      icon: Icons.bolt_rounded,
                      accentColor: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      label: 'Days Logged',
                      value: '${_allDates.length}',
                      icon: Icons.calendar_today_rounded,
                      accentColor: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Date navigation
              const SectionHeader(title: 'Daily Log'),
              _buildDateNavigator(context),
              const SizedBox(height: AppSpacing.md),

              // Daily summary
              if (dayStats.totalCommands > 0) ...[
                _buildDaySummary(context, dayStats),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Records list
              const SectionHeader(title: 'Commands'),
              if (records.isEmpty)
                EmptyStateCard(
                  icon: Icons.history_rounded,
                  title: AppStrings.historyEmpty,
                  subtitle: AppStrings.historyEmptySub,
                )
              else
                ...records.map(
                  (r) => RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _buildRecordTile(context, r),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),

              // Banner ad (only for non-premium users)
              if (!widget.adService.isPremium) const BannerAdWidget(),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateNavigator(BuildContext context) {
    return DashboardCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.textSecondary,
            onPressed: () => _navigateDate(-1),
          ),
          Text(
            _formatDateLabel(_selectedDate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.textSecondary,
            onPressed: () => _navigateDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummary(BuildContext context, DailyStats stats) {
    return DashboardCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(
            context,
            '${stats.completed}',
            'Done',
            AppColors.success,
          ),
          _summaryItem(context, '${stats.skipped}', 'Skipped', AppColors.error),
          _summaryItem(
            context,
            stats.totalCalories.toStringAsFixed(0),
            'Calories',
            AppColors.warning,
          ),
          _summaryItem(
            context,
            '${(stats.completionRate * 100).toStringAsFixed(0)}%',
            'Rate',
            AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
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

  Widget _buildRecordTile(BuildContext context, ExecutionRecord record) {
    final isDone = record.status == CommandStatus.completed;

    return Semantics(
      label:
          '${record.displayText}, ${isDone ? "completed" : "skipped"}${isDone && record.calories > 0 ? ", ${record.calories.toStringAsFixed(0)} calories" : ""}',
      child: DashboardCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.close_rounded,
                color: isDone ? AppColors.success : AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.displayText,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.workoutType.label} · ${record.difficulty.label}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.status.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDone ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isDone && record.calories > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${record.calories.toStringAsFixed(0)} cal',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
