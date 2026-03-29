import 'package:flutter/foundation.dart';

/// Handles notification tap routing by mapping payloads to target tabs.
class DeepLinkService {
  /// Notifies listeners with target tab index when a notification is tapped.
  /// null = no pending navigation.
  final ValueNotifier<int?> tabNotifier = ValueNotifier<int?>(null);

  /// Process a notification tap payload and route accordingly.
  /// Supported payloads: check_in, history, challenges, profile.
  void handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;

    final tabIndex = switch (payload) {
      'check_in' => 0,
      'history' => 1,
      'challenges' => 2,
      'profile' => 3,
      _ => null,
    };

    if (tabIndex != null) {
      tabNotifier.value = tabIndex;
      debugPrint(
        '[DEEPLINK] Navigating to tab $tabIndex from payload: $payload',
      );
    }
  }

  void dispose() {
    tabNotifier.dispose();
  }
}
