import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Product ID configured in Google Play Console.
const String kPremiumMonthlyId = 'dropnow_premium_monthly';

/// Billing flow state for UI consumption.
/// Named BillingStatus to avoid conflict with in_app_purchase's PurchaseStatus.
enum BillingStatus {
  idle,
  loading,
  available,
  pending,
  purchased,
  restored,
  error,
  unavailable,
}

/// Handles all Google Play billing communication via in_app_purchase.
class BillingService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Whether the Play Store billing connection is available.
  bool _storeAvailable = false;
  bool get isStoreAvailable => _storeAvailable;

  /// Loaded product details from the store.
  ProductDetails? _product;
  ProductDetails? get product => _product;

  /// Current purchase flow state.
  BillingStatus _status = BillingStatus.idle;
  BillingStatus get status => _status;

  /// Last error message for UI display.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Callback invoked when a purchase is confirmed (grant entitlement).
  void Function(PurchaseDetails purchase)? onPurchaseConfirmed;

  /// Callback invoked when entitlement should be revoked.
  void Function()? onEntitlementLost;

  /// Notifier so UI can rebuild on state changes.
  final ValueNotifier<int> stateNotifier = ValueNotifier<int>(0);

  void _notifyListeners() {
    stateNotifier.value++;
  }

  // ──────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────

  Future<void> init() async {
    try {
      _storeAvailable = await _iap.isAvailable();
      debugPrint('[BILLING] Store available: $_storeAvailable');

      if (!_storeAvailable) {
        _status = BillingStatus.unavailable;
        _notifyListeners();
        return;
      }

      // Listen for purchase updates (required by the plugin).
      final purchaseStream = _iap.purchaseStream;
      _subscription = purchaseStream.listen(
        _onPurchaseUpdated,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          debugPrint('[BILLING] Purchase stream error: $error');
        },
      );

      // Load product details.
      await loadProducts();
    } catch (e) {
      debugPrint('[BILLING] Init failed: $e');
      _storeAvailable = false;
      _status = BillingStatus.unavailable;
      _notifyListeners();
    }
  }

  // ──────────────────────────────────────────
  // Product Loading
  // ──────────────────────────────────────────

  Future<void> loadProducts() async {
    if (!_storeAvailable) return;

    _status = BillingStatus.loading;
    _notifyListeners();

    try {
      final response = await _iap.queryProductDetails({kPremiumMonthlyId});

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[BILLING] Product not found: ${response.notFoundIDs}');
      }

      if (response.productDetails.isNotEmpty) {
        _product = response.productDetails.first;
        _status = BillingStatus.available;
        debugPrint(
          '[BILLING] Product loaded: ${_product!.id} — ${_product!.price}',
        );
      } else {
        _status = BillingStatus.unavailable;
        debugPrint('[BILLING] No products available');
      }
    } catch (e) {
      debugPrint('[BILLING] Product query failed: $e');
      _status = BillingStatus.error;
      _errorMessage = 'Could not load subscription details.';
    }

    _notifyListeners();
  }

  // ──────────────────────────────────────────
  // Purchase Flow
  // ──────────────────────────────────────────

  Future<bool> purchasePremium() async {
    if (_product == null) {
      _errorMessage = 'Product not available.';
      _status = BillingStatus.error;
      _notifyListeners();
      return false;
    }

    try {
      final purchaseParam = PurchaseParam(productDetails: _product!);
      final started = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (started) {
        _status = BillingStatus.pending;
        _notifyListeners();
      }
      return started;
    } catch (e) {
      debugPrint('[BILLING] Purchase failed: $e');
      _errorMessage = 'Purchase could not be started.';
      _status = BillingStatus.error;
      _notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────
  // Restore Purchases
  // ──────────────────────────────────────────

  Future<void> restorePurchases() async {
    if (!_storeAvailable) return;

    _status = BillingStatus.loading;
    _notifyListeners();

    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('[BILLING] Restore failed: $e');
      _errorMessage = 'Could not restore purchases.';
      _status = BillingStatus.error;
      _notifyListeners();
    }
  }

  // ──────────────────────────────────────────
  // Purchase Stream Handler
  // ──────────────────────────────────────────

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      debugPrint(
        '[BILLING] Purchase update: ${purchase.productID} — '
        'status=${purchase.status}',
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _status = BillingStatus.pending;
          _notifyListeners();

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          _status = purchase.status == PurchaseStatus.restored
              ? BillingStatus.restored
              : BillingStatus.purchased;
          _errorMessage = null;
          onPurchaseConfirmed?.call(purchase);
          _notifyListeners();

        case PurchaseStatus.error:
          _status = BillingStatus.error;
          _errorMessage = purchase.error?.message ?? 'Purchase failed.';
          debugPrint('[BILLING] Purchase error: ${purchase.error?.message}');
          _notifyListeners();

        case PurchaseStatus.canceled:
          _status = _product != null
              ? BillingStatus.available
              : BillingStatus.idle;
          _errorMessage = null;
          debugPrint('[BILLING] Purchase cancelled');
          _notifyListeners();
      }
    }
  }

  // ──────────────────────────────────────────
  // Cleanup
  // ──────────────────────────────────────────

  void dispose() {
    _subscription?.cancel();
    stateNotifier.dispose();
  }
}
