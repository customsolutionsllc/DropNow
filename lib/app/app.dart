import 'package:flutter/material.dart';
import 'package:drop_now/app/theme/app_theme.dart';
import 'package:drop_now/app/routes/app_shell.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/services/services.dart';

class DropNowApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: AppShell(
        prefsService: prefsService,
        commandService: commandService,
        schedulingService: schedulingService,
        notificationService: notificationService,
        storageService: storageService,
        statsService: statsService,
        rewardService: rewardService,
        adService: adService,
        billingService: billingService,
        premiumService: premiumService,
        authService: authService,
        syncService: syncService,
        challengeService: challengeService,
        crashService: crashService,
        deepLinkService: deepLinkService,
      ),
    );
  }
}
