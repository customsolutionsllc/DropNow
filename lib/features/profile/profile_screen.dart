import 'package:flutter/material.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/models/models.dart';
import 'package:drop_now/core/services/services.dart';
import 'package:drop_now/app/widgets/widgets.dart';
import 'package:drop_now/features/premium/premium_screen.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatefulWidget {
  final PreferencesService prefsService;
  final SchedulingService schedulingService;
  final NotificationService notificationService;
  final StatsService statsService;
  final AuthService authService;
  final FirestoreSyncService? syncService;
  final PremiumService premiumService;
  final BillingService billingService;
  final AdService adService;
  final InviteService inviteService;
  final RatingService ratingService;
  final VoidCallback? onSettingsChanged;
  final VoidCallback? onSignOut;

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
    required this.adService,
    required this.inviteService,
    required this.ratingService,
    this.onSettingsChanged,
    this.onSignOut,
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
  bool _showRatingPrompt = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _checkRatingEligibility();
  }

  void _checkRatingEligibility() {
    final stats = widget.statsService;
    final totalCompleted = stats.totalCompleted;
    // Approximate distinct days from execution records
    final distinctDays = stats.currentStreak > 0 ? stats.currentStreak : 1;
    if (widget.ratingService.isEligible(
      totalCompleted: totalCompleted,
      distinctDaysUsed: distinctDays,
    )) {
      setState(() => _showRatingPrompt = true);
    }
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

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out?'),
        content: const Text(
          'Your local data is kept, but cloud sync and challenges '
          'will stop until you sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.authService.signOut();
    // Re-establish anonymous auth and trigger login flow
    await widget.authService.ensureSignedIn();
    if (!mounted) return;
    widget.onSignOut?.call();
  }

  void _showAccountDetails() {
    final auth = widget.authService;
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
              Text('Account', style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.lg),
              _accountRow(
                ctx,
                Icons.person_rounded,
                'Name',
                auth.displayName ?? 'Guest',
              ),
              _accountRow(
                ctx,
                Icons.email_rounded,
                'Email',
                auth.email ?? 'Not linked',
              ),
              _accountRow(
                ctx,
                Icons.login_rounded,
                'Sign-in Method',
                auth.authProviderLabel,
              ),
              if (auth.uid != null)
                _accountRow(ctx, Icons.fingerprint_rounded, 'UID', auth.uid!),
              const SizedBox(height: AppSpacing.lg),
              if (!auth.isSocialSignIn)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onSignOut?.call();
                    },
                    icon: const Icon(Icons.link_rounded, size: 20),
                    label: const Text('Link Google or Facebook'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountRow(
    BuildContext ctx,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(ctx).textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(ctx).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'DropNow',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.military_tech_rounded,
          color: AppColors.accent,
          size: 28,
        ),
      ),
      applicationLegalese:
          '\u00a9 2026 Custom Solutions LLC\nAll rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Your personal drill sergeant that delivers random '
          'exercise commands throughout the day to keep you active.',
        ),
      ],
    );
  }

  void _showAppearanceSheet() {
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
              Text('Appearance', style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.dark_mode_rounded,
                      color: AppColors.accent,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dark Mode',
                            style: Theme.of(ctx).textTheme.titleMedium
                                ?.copyWith(color: AppColors.accent),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Active \u2014 the only way to operate',
                            style: Theme.of(ctx).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'More themes coming soon.',
                style: Theme.of(
                  ctx,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendFeedback() async {
    const subject = 'DropNow Feedback';
    const body =
        'Hi DropNow team,\n\n'
        '[Describe your feedback, bug report, or feature request here]\n\n'
        'Device: Android\n'
        'App Version: 1.0.0';
    await Share.share(body, subject: subject);
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
              const SizedBox(height: AppSpacing.lg),

              // Analytics
              const SectionHeader(title: 'Your Analytics'),
              _buildAnalyticsCards(context),
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
                  onTap: _showAccountDetails,
                ),
                SettingsRowTile(
                  icon: Icons.cloud_rounded,
                  title: 'Cloud Backup',
                  subtitle: widget.syncService != null
                      ? (widget.authService.isSignedIn ? 'Enabled' : 'Offline')
                      : 'Not configured',
                  onTap: _syncNow,
                ),
              ]),
              const SizedBox(height: AppSpacing.lg),

              // Social & Sharing
              const SectionHeader(title: 'Social'),
              _buildSettingsGroup(context, [
                SettingsRowTile(
                  icon: Icons.share_rounded,
                  title: 'Invite Friends',
                  subtitle: 'Share DropNow with your squad',
                  onTap: () => widget.inviteService.shareInvite(),
                ),
                if (widget.authService.uid != null)
                  SettingsRowTile(
                    icon: Icons.copy_rounded,
                    title: 'Copy My ID',
                    subtitle: widget.authService.uid ?? '',
                    onTap: () async {
                      final uid = widget.authService.uid;
                      if (uid == null) return;
                      final ok = await widget.inviteService.copyId(uid);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok ? 'ID copied to clipboard!' : 'Failed to copy',
                          ),
                        ),
                      );
                    },
                  ),
                if (widget.authService.uid != null)
                  SettingsRowTile(
                    icon: Icons.send_rounded,
                    title: 'Share My ID',
                    subtitle: 'Let friends challenge you',
                    onTap: () {
                      final uid = widget.authService.uid;
                      if (uid != null) widget.inviteService.shareMyId(uid);
                    },
                  ),
              ]),
              const SizedBox(height: AppSpacing.lg),

              // Rating prompt
              if (_showRatingPrompt) ...[
                RatingPromptCard(
                  onYes: () async {
                    setState(() => _showRatingPrompt = false);
                    await widget.ratingService.requestReview();
                  },
                  onDismiss: () {
                    setState(() => _showRatingPrompt = false);
                    widget.ratingService.markPromptShown();
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // App settings
              const SectionHeader(title: 'App'),
              _buildSettingsGroup(context, [
                SettingsRowTile(
                  icon: Icons.palette_rounded,
                  title: 'Appearance',
                  subtitle: 'Dark mode',
                  onTap: _showAppearanceSheet,
                ),
                SettingsRowTile(
                  icon: Icons.star_rounded,
                  title: 'Rate DropNow',
                  subtitle: 'Leave us a review',
                  onTap: () => widget.ratingService.requestReview(),
                ),
                SettingsRowTile(
                  icon: Icons.feedback_rounded,
                  title: 'Send Feedback',
                  subtitle: 'Report bugs or request features',
                  onTap: _sendFeedback,
                ),
                SettingsRowTile(
                  icon: Icons.info_rounded,
                  title: 'About DropNow',
                  subtitle: 'Version 1.0.0',
                  onTap: _showAboutDialog,
                ),
                if (widget.authService.isSocialSignIn)
                  SettingsRowTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: widget.authService.displayName ?? '',
                    onTap: _handleSignOut,
                  )
                else if (!widget.authService.isSocialSignIn)
                  SettingsRowTile(
                    icon: Icons.login_rounded,
                    title: 'Sign In',
                    subtitle: 'Link Google or Facebook',
                    onTap: () => widget.onSignOut?.call(),
                  ),
              ]),
              const SizedBox(height: AppSpacing.xl),

              // Banner ad (free users)
              if (!widget.adService.isPremium) const BannerAdWidget(),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final name = widget.authService.displayName ?? 'Soldier';
    final photoUrl = widget.authService.photoUrl;

    return Semantics(
      label:
          'Profile: $name, Rank Recruit, ${widget.statsService.totalCompleted} commands completed',
      child: DashboardCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            if (photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  photoUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _defaultAvatar(),
                ),
              )
            else
              _defaultAvatar(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.headlineSmall),
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

  Widget _defaultAvatar() {
    return Container(
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

  Widget _buildAnalyticsCards(BuildContext context) {
    final stats = widget.statsService;
    final today = stats.todayStats;
    final completionRate = today.totalCommands > 0
        ? (today.completionRate * 100).toStringAsFixed(0)
        : '—';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Completion Rate',
                value: today.totalCommands > 0 ? '$completionRate%' : '—',
                icon: Icons.pie_chart_rounded,
                accentColor: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                label: 'Longest Streak',
                value: '${stats.longestStreak}',
                icon: Icons.emoji_events_rounded,
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
                label: 'Today\'s Commands',
                value: '${today.completed}/${today.totalCommands}',
                icon: Icons.today_rounded,
                accentColor: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                label: 'Total Calories',
                value: '${stats.totalCalories.toStringAsFixed(0)}',
                icon: Icons.local_fire_department_rounded,
                accentColor: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
