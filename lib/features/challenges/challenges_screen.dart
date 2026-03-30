import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/models/models.dart';
import 'package:drop_now/core/services/auth_service.dart';
import 'package:drop_now/core/services/challenge_service.dart';
import 'package:drop_now/core/services/ad_service.dart';
import 'package:drop_now/core/services/execution_storage_service.dart';
import 'package:drop_now/core/services/firestore_sync_service.dart';
import 'package:drop_now/app/widgets/widgets.dart';

class ChallengesScreen extends StatefulWidget {
  final AuthService authService;
  final ChallengeService? challengeService;
  final ExecutionStorageService storageService;
  final FirestoreSyncService? syncService;
  final AdService adService;

  const ChallengesScreen({
    super.key,
    required this.authService,
    this.challengeService,
    required this.storageService,
    this.syncService,
    required this.adService,
  });

  @override
  State<ChallengesScreen> createState() => ChallengesScreenState();
}

class ChallengesScreenState extends State<ChallengesScreen> {
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isOnline = widget.challengeService != null;

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
                AppStrings.challengesTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Prove who\'s tougher.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Send challenge button
              PrimaryButton(
                label: AppStrings.challengesFriend,
                icon: Icons.flash_on_rounded,
                onPressed: isOnline ? _showSendChallengeSheet : null,
              ),

              // Your UID for sharing
              if (widget.authService.uid != null) ...[
                const SizedBox(height: AppSpacing.md),
                _buildUidCard(context),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Incoming challenges
              const SectionHeader(title: 'INCOMING'),
              const SizedBox(height: AppSpacing.sm),
              if (isOnline)
                _ChallengeStreamList(
                  stream: widget.challengeService!.incomingChallenges(),
                  emptyIcon: Icons.download_rounded,
                  emptyTitle: 'No incoming challenges',
                  emptySubtitle: 'When someone dares you, it shows up here.',
                  currentUid: widget.authService.uid!,
                  challengeService: widget.challengeService!,
                  onComplete: _onCompleteChallenge,
                )
              else
                _buildOfflineCard(context),
              const SizedBox(height: AppSpacing.lg),

              // Sent challenges
              const SectionHeader(title: 'SENT'),
              const SizedBox(height: AppSpacing.sm),
              if (isOnline)
                _ChallengeStreamList(
                  stream: widget.challengeService!.sentChallenges(),
                  emptyIcon: Icons.upload_rounded,
                  emptyTitle: 'No challenges sent',
                  emptySubtitle:
                      'Challenge a friend and see if they can keep up.',
                  currentUid: widget.authService.uid!,
                  challengeService: widget.challengeService!,
                  onComplete: _onCompleteChallenge,
                )
              else
                _buildOfflineCard(context),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUidCard(BuildContext context) {
    final uid = widget.authService.uid ?? '';
    final short = uid.length > 8 ? '${uid.substring(0, 8)}…' : uid;
    return DashboardCard(
      onTap: () => _copyUid(uid),
      child: Row(
        children: [
          const Icon(Icons.badge_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Your ID: $short',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const Icon(Icons.copy_rounded, color: AppColors.textMuted, size: 16),
        ],
      ),
    );
  }

  void _copyUid(String uid) {
    Clipboard.setData(ClipboardData(text: uid));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your ID copied: $uid'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildOfflineCard(BuildContext context) {
    return DashboardCard(
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Sign in to use challenges',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEND CHALLENGE
  // ---------------------------------------------------------------------------

  void _showSendChallengeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SendChallengeSheet(onSend: _sendChallenge),
    );
  }

  Future<void> _sendChallenge(
    String targetUid,
    WorkoutType type,
    int amount,
  ) async {
    final challenge = await widget.challengeService?.createChallenge(
      toUserId: targetUid,
      workoutType: type,
      amount: amount,
    );

    if (!mounted) return;

    if (challenge != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Challenge sent! 💪')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send challenge.')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // COMPLETE CHALLENGE
  // ---------------------------------------------------------------------------

  Future<void> _onCompleteChallenge(Challenge challenge) async {
    final ok = await widget.challengeService?.completeChallenge(challenge.id);
    if (ok != true) return;

    // Also record execution locally + sync (reuse Phase 3+4 system)
    final now = DateTime.now();
    final record = ExecutionRecord(
      id: 'challenge_${challenge.id}',
      timestamp: now,
      date: ExecutionStorageService.dateKey(now),
      workoutType: challenge.workoutType,
      amount: challenge.amount,
      difficulty: Difficulty.medium,
      personality: Personality.commander,
      status: CommandStatus.completed,
      calories: challenge.workoutType.caloriesPerUnit * challenge.amount,
      displayText:
          '${challenge.workoutType.label} × ${challenge.amount} (Challenge)',
    );
    await widget.storageService.addRecord(record);
    widget.syncService?.syncRecord(record);

    // Show interstitial ad after challenge completion
    if (widget.adService.onCommandCompleted()) {
      await widget.adService.showInterstitialAd();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Challenge completed! 🏆')));
  }
}

// =============================================================================
// SEND CHALLENGE BOTTOM SHEET
// =============================================================================

class _SendChallengeSheet extends StatefulWidget {
  final Future<void> Function(String targetUid, WorkoutType type, int amount)
  onSend;

  const _SendChallengeSheet({required this.onSend});

  @override
  State<_SendChallengeSheet> createState() => _SendChallengeSheetState();
}

class _SendChallengeSheetState extends State<_SendChallengeSheet> {
  final _uidController = TextEditingController();
  WorkoutType _selectedType = WorkoutType.pushups;
  int _amount = 20;
  bool _sending = false;

  static const _amounts = [10, 15, 20, 25, 30, 40, 50];

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Send Challenge',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Pick a workout and dare someone.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Target UID
            Text('Opponent ID', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _uidController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Paste their User ID',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Workout type
            Text('Workout', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: WorkoutType.values.length,
                separatorBuilder: (context2, index2) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final type = WorkoutType.values[i];
                  final selected = type == _selectedType;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.chipRadius,
                        ),
                      ),
                      child: Text(
                        type.label,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Amount
            Text('Amount', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _amounts.map((a) {
                final selected = a == _amount;
                return GestureDetector(
                  onTap: () => setState(() => _amount = a),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accent
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.chipRadius,
                      ),
                    ),
                    child: Text(
                      _selectedType.isTimeBased ? '${a}s' : '$a',
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Send button
            PrimaryButton(
              label: _sending ? 'Sending…' : 'Send Challenge ⚡',
              icon: Icons.flash_on_rounded,
              onPressed: _sending ? null : _onSend,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _onSend() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the opponent\'s User ID.')),
      );
      return;
    }

    setState(() => _sending = true);
    await widget.onSend(uid, _selectedType, _amount);
    if (mounted) Navigator.of(context).pop();
  }
}

// =============================================================================
// CHALLENGE STREAM LIST (real-time from Firestore)
// =============================================================================

class _ChallengeStreamList extends StatelessWidget {
  final Stream<List<Challenge>> stream;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final String currentUid;
  final ChallengeService challengeService;
  final Future<void> Function(Challenge) onComplete;

  const _ChallengeStreamList({
    required this.stream,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.currentUid,
    required this.challengeService,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Challenge>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final challenges = snap.data ?? [];
        if (challenges.isEmpty) {
          return _buildEmpty(context);
        }

        return Column(
          children: challenges
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ChallengeCard(
                    challenge: c,
                    currentUid: currentUid,
                    challengeService: challengeService,
                    onComplete: onComplete,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return DashboardCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(emptyIcon, color: AppColors.textMuted, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emptyTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  emptySubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// INDIVIDUAL CHALLENGE CARD
// =============================================================================

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final String currentUid;
  final ChallengeService challengeService;
  final Future<void> Function(Challenge) onComplete;

  const _ChallengeCard({
    required this.challenge,
    required this.currentUid,
    required this.challengeService,
    required this.onComplete,
  });

  bool get _isIncoming => challenge.toUserId == currentUid;

  @override
  Widget build(BuildContext context) {
    final status = challenge.isExpired
        ? ChallengeStatus.expired
        : challenge.status;

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              _statusIcon(status),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.workoutLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitleText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(context, status),
            ],
          ),

          // Action buttons for incoming pending
          if (_isIncoming && status == ChallengeStatus.pending) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Accept',
                    color: AppColors.success,
                    onTap: () => challengeService.acceptChallenge(challenge.id),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionButton(
                    label: 'Decline',
                    color: AppColors.textMuted,
                    onTap: () =>
                        challengeService.declineChallenge(challenge.id),
                  ),
                ),
              ],
            ),
          ],

          // Complete button for accepted incoming challenges
          if (_isIncoming && status == ChallengeStatus.accepted) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                label: 'Complete Challenge 💪',
                color: AppColors.accent,
                onTap: () => onComplete(challenge),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _subtitleText {
    if (_isIncoming) {
      final from = _shortUid(challenge.fromUserId);
      return 'From $from • ${challenge.timeLeft}';
    }
    final to = _shortUid(challenge.toUserId);
    return 'To $to • ${challenge.timeLeft}';
  }

  String _shortUid(String uid) =>
      uid.length > 6 ? '${uid.substring(0, 6)}…' : uid;

  Widget _statusIcon(ChallengeStatus status) {
    final (IconData icon, Color color) = switch (status) {
      ChallengeStatus.pending => (
        Icons.hourglass_top_rounded,
        AppColors.warning,
      ),
      ChallengeStatus.accepted => (
        Icons.local_fire_department_rounded,
        AppColors.accent,
      ),
      ChallengeStatus.completed => (
        Icons.check_circle_rounded,
        AppColors.success,
      ),
      ChallengeStatus.declined => (Icons.cancel_rounded, AppColors.textMuted),
      ChallengeStatus.expired => (Icons.timer_off_rounded, AppColors.textMuted),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _statusBadge(BuildContext context, ChallengeStatus status) {
    final color = switch (status) {
      ChallengeStatus.pending => AppColors.warning,
      ChallengeStatus.accepted => AppColors.accent,
      ChallengeStatus.completed => AppColors.success,
      ChallengeStatus.declined => AppColors.textMuted,
      ChallengeStatus.expired => AppColors.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Small reusable action button for challenge cards
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
