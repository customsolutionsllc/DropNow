import 'package:flutter/material.dart';
import 'package:drop_now/app/theme/app_theme.dart';
import 'package:drop_now/app/routes/app_shell.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/services/services.dart';
import 'package:drop_now/features/auth/login_screen.dart';

class DropNowApp extends StatefulWidget {
  final PreferencesService prefsService;
  final CommandGenerationService commandService;
  final SchedulingService schedulingService;
  final NotificationService notificationService;
  final ExecutionStorageService storageService;
  final StatsService statsService;
  final RewardService rewardService;
  final RatingService ratingService;
  final InviteService inviteService;
  final AdService adService;
  final BillingService billingService;
  final PremiumService premiumService;
  final AuthService authService;
  final FirestoreSyncService? syncService;
  final ChallengeService? challengeService;
  final CrashService crashService;
  final DeepLinkService deepLinkService;

  const DropNowApp({
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
  });

  @override
  State<DropNowApp> createState() => _DropNowAppState();
}

class _DropNowAppState extends State<DropNowApp> {
  bool _showLogin = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    // Show login if user hasn't seen it and isn't already social-signed-in
    final hasSeenLogin = await widget.authService.hasSeenLogin();
    final isSocial = widget.authService.isSocialSignIn;
    if (!hasSeenLogin && !isSocial) {
      setState(() {
        _showLogin = true;
        _initialized = true;
      });
    } else {
      setState(() {
        _showLogin = false;
        _initialized = true;
      });
    }
  }

  void _onLoginComplete() {
    setState(() => _showLogin = false);
  }

  void _onSignOut() {
    // After sign-out, show login screen again
    setState(() => _showLogin = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: !_initialized
          ? const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          : _showLogin
          ? LoginScreen(
              authService: widget.authService,
              onComplete: _onLoginComplete,
            )
          : AppShell(
              prefsService: widget.prefsService,
              commandService: widget.commandService,
              schedulingService: widget.schedulingService,
              notificationService: widget.notificationService,
              storageService: widget.storageService,
              statsService: widget.statsService,
              rewardService: widget.rewardService,
              ratingService: widget.ratingService,
              inviteService: widget.inviteService,
              adService: widget.adService,
              billingService: widget.billingService,
              premiumService: widget.premiumService,
              authService: widget.authService,
              syncService: widget.syncService,
              challengeService: widget.challengeService,
              crashService: widget.crashService,
              deepLinkService: widget.deepLinkService,
              onSignOut: _onSignOut,
            ),
    );
  }
}
