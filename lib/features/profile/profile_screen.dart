import 'package:flutter/material.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/models/models.dart';
import 'package:drop_now/core/services/services.dart';
import 'package:drop_now/app/widgets/widgets.dart';
import 'package:drop_now/features/premium/premium_screen.dart';

class ProfileScreen extends StatefulWidget {
  final PreferencesService prefsService;
  final SchedulingService schedulingService;
  final NotificationService notificationService;
  final StatsService statsService;
  final AuthService authService;
  final FirestoreSyncService? syncService;
  final PremiumService premiumService;
  final BillingService billingService;
  final VoidCallback? onSettingsChanged;

  const ProfileScreen({
    super.key,
    required this.prefsService,
    required this.schedulingService,
    required this.notificationService,
    required this.statsService,
    required this.authService,
    this.syncService,
    required this.premiumService,
    required this.billingService,
    this.onSettingsChanged,
  });

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late Personality _personality;
  late Difficulty _difficulty;
  late int _frequency;
  late TimeOfDay _windowStart;
  late TimeOfDay _windowEnd;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() {
    final prefs = widget.prefsService;
    setState(() {
      _personality = prefs.personality;
      _difficulty = prefs.difficulty;
      _frequency = prefs.frequency;
      _windowStart = prefs.windowStart;
      _windowEnd = prefs.windowEnd;
      _isActive = prefs.isSystemActive;
    });
  }

  void refresh() {
    _loadPrefs();
  }

  Future<void> _rescheduleIfActive() async {
    if (_isActive) {
      await widget.schedulingService.scheduleToday();
    }
    widget.onSettingsChanged?.call();
    // Sync preferences to cloud in background
    widget.syncService?.syncPreferences();
  }

  void _showPersonalityPicker() {
    _showOptionPicker<Personality>(
      title: 'Commander Personality',
      options: Personality.values,
      current: _personality,
      labelBuilder: (p) => '${p.emoji}  ${p.label}',
      subtitleBuilder: (p) => p.description,
      onSelected: (p) async {
        await widget.prefsService.setPersonality(p);
        setState(() => _personality = p);
        await _rescheduleIfActive();
      },
    );
  }

  void _showDifficultyPicker() {
    _showOptionPicker<Difficulty>(
      title: 'Difficulty Level',
      options: Difficulty.values,
      current: _difficulty,
      labelBuilder: (d) => '${d.emoji}  ${d.label}',
      subtitleBuilder: (d) => d.description,
      onSelected: (d) async {
        await widget.prefsService.setDifficulty(d);
        setState(() => _difficulty = d);
        await _rescheduleIfActive();
      },
    );
  }

  void _showFrequencyPicker() {
    _showOptionPicker<int>(
      title: 'Daily Frequency',
      options: PreferencesService.frequencyOptions,
      current: _frequency,
      labelBuilder: (f) => '$f commands per day',
      subtitleBuilder: (f) {
        if (f <= 3) return 'Light � easy to keep up.';
        if (f <= 5) return 'Moderate � solid daily rhythm.';
        if (f <= 8) return 'Intense � stay on your toes.';
        return 'Maximum � no breaks, soldier.';
      },
      onSelected: (f) async {
        await widget.prefsService.setFrequency(f);
        setState(() => _frequency = f);
        await _rescheduleIfActive();
      },
    );
  }

  Future<void> _pickWindowStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _windowStart,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      await widget.prefsService.setWindowStart(picked);
      setState(() => _windowStart = picked);
      await _rescheduleIfActive();
    }
  }

  Future<void> _pickWindowEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _windowEnd,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      await widget.prefsService.setWindowEnd(picked);
      setState(() => _windowEnd = picked);
      await _rescheduleIfActive();
    }
  }

  Future<void> _syncNow() async {
    final sync = widget.syncService;
    if (sync == null || !widget.authService.isSignedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cloud sync not available')));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Syncing...')));
    final result = await sync.fullSync();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sync complete — ${result.uploaded} uploaded, ${result.restored} restored',
        ),
      ),
    );
    setState(() {});
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

  void _showOptionPicker<T>({
    required String title,
    required List<T> options,
    required T current,
    required String Function(T) labelBuilder,
    required String Function(T) subtitleBuilder,
    required Future<void> Function(T) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.lg),
              ...options.map((option) {
                final isSelected = option == current;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      onSelected(option);
                    },
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withValues(alpha: 0.12)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadius,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.4)
                              : AppColors.surfaceBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  labelBuilder(option),
                                  style: Theme.of(ctx).textTheme.titleMedium
                                      ?.copyWith(
                                        color: isSelected
                                            ? AppColors.accent
                                            : AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitleBuilder(option),
                                  style: Theme.of(ctx).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.accent,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                AppStrings.profileTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildProfileHeader(context),
              const SizedBox(height: AppSpacing.xl),

              // System toggle
              const SectionHeader(title: 'Command System'),
              _buildSystemToggle(context),
              const SizedBox(height: AppSpacing.lg),

              // Workout settings
              const SectionHeader(title: 'Workout Settings'),
              _buildSettingsGroup(context, [
                SettingsRowTile(
                  icon: Icons.psychology_rounded,
                  title: 'Commander Personality',
                  subtitle: _personality.label,
                  onTap: _showPersonalityPicker,
                ),
                SettingsRowTile(
                  icon: Icons.speed_rounded,
                  title: 'Difficulty',
                  subtitle: _difficulty.label,
                  onTap: _showDifficultyPicker,
                ),
                SettingsRowTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Drop Frequency',
                  subtitle: '$_frequency per day',
                  onTap: _showFrequencyPicker,
                ),
              ]),
              const SizedBox(height: AppSpacing.lg),

              // Time window
              const SectionHeader(title: 'Active Hours'),
              _buildSettingsGroup(context, [
                SettingsRowTile(
                  icon: Icons.wb_sunny_rounded,
                  title: 'Start Time',
                  subtitle: SchedulingService.formatTime(_windowStart),
                  onTap: _pickWindowStart,
                ),
                SettingsRowTile(
                  icon: Icons.bedtime_rounded,
                  title: 'End Time',
                  subtitle: SchedulingService.formatTime(_windowEnd),
                  onTap: _pickWindowEnd,
                ),
              ]),
              if (!widget.prefsService.isWindowValid) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Invalid time window. End time must be at least 1 hour after start.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              // Account
              const SectionHeader(title: 'Account'),
              _buildSettingsGroup(context, [
                SettingsRowTile(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Premium',
                  subtitle: widget.premiumService.isPremium
                      ? 'Active — ads removed'
                      : 'Go ad-free',
                  onTap: () => PremiumScreen.show(
                    context,
                    premiumService: widget.premiumService,
                    billingService: widget.billingService,
                  ),
                ),
                SettingsRowTile(
                  icon: Icons.person_rounded,
                  title: 'Account',
                  subtitle: widget.authService.authProviderLabel,
                  onTap: () {},
                ),
                SettingsRowTile(
                  icon: Icons.cloud_rounded,
                  title: 'Cloud Backup',
                  subtitle: widget.syncService != null
                      ? (widget.authService.isSignedIn ? 'Enabled' : 'Offline')
                      : 'Not configured',
                  onTap: _syncNow,
                ),
                SettingsRowTile(
                  icon: Icons.people_rounded,
                  title: 'Social',
                  subtitle: 'Friends & challenges',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: AppSpacing.lg),

              // App settings
              const SectionHeader(title: 'App'),
              _buildSettingsGroup(context, [
                SettingsRowTile(
                  icon: Icons.color_lens_rounded,
                  title: 'Appearance',
                  subtitle: 'Dark mode',
                  onTap: () {},
                ),
                SettingsRowTile(
                  icon: Icons.info_rounded,
                  title: 'About DropNow',
                  subtitle: 'Version 1.0.0',
                  onTap: () {},
                ),
                SettingsRowTile(
                  icon: Icons.feedback_rounded,
                  title: 'Send Feedback',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Semantics(
      label:
          'Profile: Soldier, Rank Recruit, ${widget.statsService.totalCompleted} commands completed',
      child: DashboardCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.military_tech_rounded,
                color: AppColors.accent,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soldier',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Rank: Recruit \u00b7 ${widget.statsService.totalCompleted} commands completed',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isActive
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.power_settings_new_rounded,
              color: _isActive ? AppColors.success : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Command System',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  _isActive ? 'Armed and active' : 'System is off',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: _toggleSystem,
            activeThumbColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i < tiles.length - 1) const Divider(indent: 72, height: 0),
          ],
        ],
      ),
    );
  }
}
