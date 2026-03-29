import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/services/services.dart';
import 'package:drop_now/app/widgets/widgets.dart';

/// Premium subscription screen. Shows benefits, localized store price,
/// subscribe button, and restore purchases action.
class PremiumScreen extends StatefulWidget {
  final PremiumService premiumService;
  final BillingService billingService;

  const PremiumScreen({
    super.key,
    required this.premiumService,
    required this.billingService,
  });

  /// Show as a modal route pushed on top of the current navigator.
  static Future<void> show(
    BuildContext context, {
    required PremiumService premiumService,
    required BillingService billingService,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PremiumScreen(
          premiumService: premiumService,
          billingService: billingService,
        ),
      ),
    );
  }

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    widget.billingService.stateNotifier.addListener(_onBillingChanged);
  }

  @override
  void dispose() {
    widget.billingService.stateNotifier.removeListener(_onBillingChanged);
    super.dispose();
  }

  void _onBillingChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onSubscribe() async {
    await widget.premiumService.purchasePremium();
  }

  Future<void> _onRestore() async {
    await widget.premiumService.restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    final billing = widget.billingService;
    final isPremium = widget.premiumService.isPremium;
    final product = billing.product;
    final status = billing.status;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // Premium icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.warning,
                  size: 44,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                isPremium ? 'You\'re Premium' : 'Go Premium',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              Text(
                isPremium
                    ? 'Enjoy your ad-free experience and unlimited streak protection.'
                    : 'Unlock the full DropNow experience.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Benefits list
              _buildBenefitTile(
                context,
                icon: Icons.block_rounded,
                title: 'Remove All Ads',
                subtitle: 'No banners, no interstitials, no interruptions.',
                active: isPremium,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildBenefitTile(
                context,
                icon: Icons.shield_rounded,
                title: 'Unlimited Streak Protection',
                subtitle: 'Protect your streak without watching ads.',
                active: isPremium,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildBenefitTile(
                context,
                icon: Icons.star_rounded,
                title: 'Support Development',
                subtitle: 'Help keep DropNow growing.',
                active: isPremium,
              ),
              const SizedBox(height: AppSpacing.xl),

              if (isPremium)
                _buildAlreadyPremium(context)
              else ...[
                // Price display
                _buildPriceSection(context, product, status),
                const SizedBox(height: AppSpacing.lg),

                // Subscribe button
                _buildSubscribeButton(context, product, status),
                const SizedBox(height: AppSpacing.md),

                // Restore button
                _buildRestoreButton(context, status),
                const SizedBox(height: AppSpacing.md),

                // Error message
                if (billing.errorMessage != null &&
                    status == BillingStatus.error)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      billing.errorMessage!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool active,
  }) {
    return DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (active ? AppColors.success : AppColors.accent).withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              active ? Icons.check_circle_rounded : icon,
              color: active ? AppColors.success : AppColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(
    BuildContext context,
    ProductDetails? product,
    BillingStatus status,
  ) {
    if (status == BillingStatus.loading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (product == null) {
      return Text(
        'Subscription details not available.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        textAlign: TextAlign.center,
      );
    }

    return Column(
      children: [
        Text(
          '${product.price} / month',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Auto-renewing monthly subscription. Cancel anytime.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(
    BuildContext context,
    ProductDetails? product,
    BillingStatus status,
  ) {
    final isLoading =
        status == BillingStatus.pending || status == BillingStatus.loading;
    final isEnabled = product != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      child: Semantics(
        button: true,
        label: product != null
            ? 'Subscribe for ${product.price} per month'
            : 'Subscribe',
        child: ElevatedButton(
          onPressed: isEnabled ? _onSubscribe : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.surfaceLight,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  product != null
                      ? 'Subscribe for ${product.price}/month'
                      : 'Subscribe',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context, BillingStatus status) {
    return TextButton(
      onPressed: status != BillingStatus.loading ? _onRestore : null,
      child: Text(
        'Restore Purchases',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildAlreadyPremium(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Premium Active',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.success),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'All ads are removed and streak protection is unlimited.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
