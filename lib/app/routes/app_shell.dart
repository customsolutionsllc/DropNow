import 'package:flutter/material.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/services/services.dart';
import 'package:drop_now/features/home/home_screen.dart';
import 'package:drop_now/features/history/history_screen.dart';
import 'package:drop_now/features/challenges/challenges_screen.dart';
import 'package:drop_now/features/profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  final PreferencesService prefsService;
  final CommandGenerationService commandService;
  final SchedulingService schedulingService;
  final NotificationService notificationService;
  final ExecutionStorageService storageService;
  final StatsService statsService;
  final RewardService rewardService;
  final AdService adService;
  final BillingService billingService;
  final PremiumService premiumService;
  final AuthService authService;
  final FirestoreSyncService? syncService;
  final ChallengeService? challengeService;
  final RatingService ratingService;
  final InviteService inviteService;
  final CrashService crashService;
  final DeepLinkService deepLinkService;
  final VoidCallback? onSignOut;

  const AppShell({
    super.key,
    required this.prefsService,
    required this.commandService,
    required this.schedulingService,
    required this.notificationService,
    required this.storageService,
    required this.statsService,
    required this.rewardService,
    required this.ratingService,
    required this.inviteService,
    required this.adService,
    required this.billingService,
    required this.premiumService,
    required this.authService,
    this.syncService,
    this.challengeService,
    required this.crashService,
    required this.deepLinkService,
    this.onSignOut,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<ProfileScreenState> _profileKey =
      GlobalKey<ProfileScreenState>();
  final GlobalKey<HistoryScreenState> _historyKey =
      GlobalKey<HistoryScreenState>();

  @override
  void initState() {
    super.initState();
    widget.deepLinkService.tabNotifier.addListener(_onDeepLink);
  }

  @override
  void dispose() {
    widget.deepLinkService.tabNotifier.removeListener(_onDeepLink);
    super.dispose();
  }

  void _onDeepLink() {
    final target = widget.deepLinkService.tabNotifier.value;
    if (target != null && target >= 0 && target < 4) {
      setState(() => _currentIndex = target);
      widget.deepLinkService.tabNotifier.value = null; // Consume
    }
  }

  void _onHomeSettingsChanged() {
    _profileKey.currentState?.refresh();
    _historyKey.currentState?.refresh();
  }

  void _onProfileSettingsChanged() {
    _homeKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _ErrorBoundary(
        crashService: widget.crashService,
        child: HomeScreen(
          key: _homeKey,
          prefsService: widget.prefsService,
          commandService: widget.commandService,
          schedulingService: widget.schedulingService,
          notificationService: widget.notificationService,
          storageService: widget.storageService,
          statsService: widget.statsService,
          rewardService: widget.rewardService,
          adService: widget.adService,
          premiumService: widget.premiumService,
          syncService: widget.syncService,
          onSettingsChanged: _onHomeSettingsChanged,
        ),
      ),
      _ErrorBoundary(
        crashService: widget.crashService,
        child: HistoryScreen(
          key: _historyKey,
          storageService: widget.storageService,
          statsService: widget.statsService,
          adService: widget.adService,
        ),
      ),
      _ErrorBoundary(
        crashService: widget.crashService,
        child: ChallengesScreen(
          authService: widget.authService,
          challengeService: widget.challengeService,
          storageService: widget.storageService,
          syncService: widget.syncService,
          adService: widget.adService,
          inviteService: widget.inviteService,
        ),
      ),
      _ErrorBoundary(
        crashService: widget.crashService,
        child: ProfileScreen(
          key: _profileKey,
          prefsService: widget.prefsService,
          schedulingService: widget.schedulingService,
          notificationService: widget.notificationService,
          statsService: widget.statsService,
          authService: widget.authService,
          syncService: widget.syncService,
          premiumService: widget.premiumService,
          billingService: widget.billingService,
          adService: widget.adService,
          ratingService: widget.ratingService,
          inviteService: widget.inviteService,
          onSettingsChanged: _onProfileSettingsChanged,
          onSignOut: widget.onSignOut,
        ),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.surfaceBorder, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              activeIcon: Icon(Icons.history_rounded),
              label: AppStrings.navHistory,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flash_on_rounded),
              activeIcon: Icon(Icons.flash_on_rounded),
              label: AppStrings.navChallenges,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

/// Catches build-phase errors in child widgets and shows a recovery UI.
class _ErrorBoundary extends StatefulWidget {
  final CrashService crashService;
  final Widget child;

  const _ErrorBoundary({required this.crashService, required this.child});

  @override
  State<_ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: AppColors.warning,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'This screen encountered an error. Tap below to retry.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _hasError = false),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _ErrorCatcher(
      onError: (error, stack) {
        widget.crashService.log(error, stack, 'ErrorBoundary');
        if (mounted) setState(() => _hasError = true);
      },
      child: widget.child,
    );
  }
}

class _ErrorCatcher extends StatelessWidget {
  final Widget child;
  final void Function(dynamic error, StackTrace? stack) onError;

  const _ErrorCatcher({required this.child, required this.onError});

  @override
  Widget build(BuildContext context) {
    // Override ErrorWidget.builder for this subtree
    return Builder(
      builder: (context) {
        ErrorWidget.builder = (details) {
          onError(details.exception, details.stack);
          return const SizedBox.shrink();
        };
        return child;
      },
    );
  }
}
