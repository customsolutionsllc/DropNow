import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drop_now/core/services/billing_service.dart';
import 'package:drop_now/core/services/ad_service.dart';

/// Manages Premium entitlement state, bridging BillingService and AdService.
///
/// Responsibilities:
/// - Persist premium state locally for fast startup
/// - Listen for billing events and update entitlement
/// - Propagate premium flag to AdService
/// - Provide entitlement queries for UI
class PremiumService {
  final SharedPreferences _prefs;
  final BillingService _billingService;
  final AdService _adService;

  // --- Persistence keys ---
  static const _keyIsPremium = 'premium_is_active';
  static const _keyProductId = 'premium_product_id';
  static const _keyLastCheck = 'premium_last_check';

  /// Notifier so UI can rebuild when premium state changes.
  final ValueNotifier<bool> premiumNotifier = ValueNotifier<bool>(false);

  PremiumService({
    required SharedPreferences prefs,
    required BillingService billingService,
    required AdService adService,
  }) : _prefs = prefs,
       _billingService = billingService,
       _adService = adService;

  // ──────────────────────────────────────────
  // State Queries
  // ──────────────────────────────────────────

  /// Whether user is currently Premium (from cache).
  bool get isPremium => _prefs.getBool(_keyIsPremium) ?? false;

  /// Last known product ID for the active subscription.
  String? get activeProductId => _prefs.getString(_keyProductId);

  /// Last time entitlement was checked (epoch ms).
  int get lastCheckTime => _prefs.getInt(_keyLastCheck) ?? 0;

  // ──────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────

  /// Initialize: restore cached state and wire billing callbacks.
  Future<void> init() async {
    // Restore cached premium state immediately for fast UI.
    final cached = isPremium;
    if (cached) {
      _applyPremium(true);
    }

    // Wire billing callbacks.
    _billingService.onPurchaseConfirmed = _onPurchaseConfirmed;
    _billingService.onEntitlementLost = _onEntitlementLost;

    // Initialize billing (connects to store, loads products, listens for updates).
    await _billingService.init();

    debugPrint('[PREMIUM] Initialized — cached premium: $cached');
  }

  // ──────────────────────────────────────────
  // Purchase Actions
  // ──────────────────────────────────────────

  /// Start the premium purchase flow.
  Future<bool> purchasePremium() async {
    return _billingService.purchasePremium();
  }

  /// Restore previous purchases.
  Future<void> restorePurchases() async {
    await _billingService.restorePurchases();
  }

  // ──────────────────────────────────────────
  // Billing Callbacks
  // ──────────────────────────────────────────

  void _onPurchaseConfirmed(PurchaseDetails purchase) {
    debugPrint('[PREMIUM] Purchase confirmed: ${purchase.productID}');
    _savePremiumState(true, purchase.productID);
    _applyPremium(true);
  }

  void _onEntitlementLost() {
    debugPrint('[PREMIUM] Entitlement lost');
    _savePremiumState(false, null);
    _applyPremium(false);
  }

  // ──────────────────────────────────────────
  // State Management
  // ──────────────────────────────────────────

  Future<void> _savePremiumState(bool active, String? productId) async {
    await _prefs.setBool(_keyIsPremium, active);
    if (productId != null) {
      await _prefs.setString(_keyProductId, productId);
    } else {
      await _prefs.remove(_keyProductId);
    }
    await _prefs.setInt(_keyLastCheck, DateTime.now().millisecondsSinceEpoch);
  }

  void _applyPremium(bool active) {
    _adService.setPremium(active);
    premiumNotifier.value = active;
    debugPrint('[PREMIUM] Applied premium: $active');
  }

  // ──────────────────────────────────────────
  // Streak Protection for Premium Users
  // ──────────────────────────────────────────

  /// Premium users can protect their streak without watching an ad.
  /// Still limited to 1 protection per day for anti-abuse.
  Future<bool> protectStreakPremium() async {
    if (!isPremium) return false;
    if (_adService.isStreakProtectionUsedToday) return false;
    // Use the existing streak protection marking, bypassing ad.
    await _adService.markStreakProtectionForPremium();
    return true;
  }

  // ──────────────────────────────────────────
  // Cleanup
  // ──────────────────────────────────────────

  void dispose() {
    premiumNotifier.dispose();
  }
}
