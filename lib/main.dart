import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:drop_now/app/app.dart';
import 'package:drop_now/core/services/services.dart';

Future<void> main() async {
  // Silence all debugPrint in release builds — prevents log leaks to logcat
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  final crashService = CrashService();

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        crashService.log(
          details.exception,
          details.stack,
          'FlutterError: ${details.library}',
        );
      };

      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF121212),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Initialize Firebase (non-fatal if not configured yet)
      bool firebaseReady = false;
      try {
        await Firebase.initializeApp();
        firebaseReady = true;
        debugPrint('[FIREBASE] initialized OK');
      } catch (e) {
        debugPrint('[FIREBASE] init FAILED: $e');
      }

      // Initialize services
      final prefsService = PreferencesService();
      await prefsService.init();

      final notificationService = NotificationService();
      await notificationService.init();

      final deepLinkService = DeepLinkService();
      notificationService.setDeepLinkService(deepLinkService);

      final commandService = CommandGenerationService();
      final schedulingService = SchedulingService(
        prefsService: prefsService,
        commandService: commandService,
        notificationService: notificationService,
      );

      final storageService = ExecutionStorageService();
      await storageService.init(prefsService.prefs);

      final statsService = StatsService(storageService);

      // Initialize daily reward service
      final rewardService = RewardService(prefsService.prefs);

      // Initialize rating service
      final ratingService = RatingService(prefsService.prefs);

      // Initialize invite service
      final inviteService = InviteService();

      // Initialize AdService (monetization)
      final adService = AdService(prefsService.prefs);
      await adService.init();

      // Wire streak protection into stats so streak counts protected days
      statsService.isDateStreakProtected = adService.isStreakProtectedForDate;

      // Initialize billing + premium service
      final billingService = BillingService();
      final premiumService = PremiumService(
        prefs: prefsService.prefs,
        billingService: billingService,
        adService: adService,
      );
      await premiumService.init();

      // Initialize Firebase auth + sync (non-fatal)
      final authService = AuthService();
      FirestoreSyncService? syncService;
      ChallengeService? challengeService;
      if (firebaseReady) {
        final user = await authService.ensureSignedIn();
        debugPrint(
          '[AUTH] signed in: ${user != null}, isAnonymous: ${authService.isAnonymous}',
        );
        syncService = FirestoreSyncService(
          authService: authService,
          prefsService: prefsService,
          storageService: storageService,
          sharedPrefs: prefsService.prefs,
        );
        await syncService.init();
        challengeService = ChallengeService(authService: authService);
        // Background sync — bootstrap profile + upload local records
        if (authService.isSignedIn) {
          await syncService.bootstrapUserProfile();
          debugPrint('[SYNC] user profile bootstrapped');
          final uploaded = await syncService.syncAllLocal();
          debugPrint('[SYNC] startup sync: $uploaded records uploaded');
        }
      }

      // Wire streak into scheduling for notification messages
      schedulingService.currentStreak = statsService.currentStreak;

      runApp(
        DropNowApp(
          prefsService: prefsService,
          commandService: commandService,
          schedulingService: schedulingService,
          notificationService: notificationService,
          storageService: storageService,
          statsService: statsService,
          rewardService: rewardService,
          ratingService: ratingService,
          inviteService: inviteService,
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
    },
    (error, stack) {
      crashService.log(error, stack, 'runZonedGuarded');
    },
  );
}
