import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Handles invite sharing and friend ID sharing.
class InviteService {
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.dropnow.drop_now';

  /// Share an invite message with the app download link.
  Future<void> shareInvite() async {
    const message =
        'DropNow just told me to do 20 pushups \u{1F602}\n'
        'Think you can beat me?\n'
        'Download and try it: $_playStoreUrl';

    await Share.share(message);
  }

  /// Share the user's challenge ID so friends can send challenges.
  Future<void> shareMyId(String uid) async {
    final message = 'Challenge me on DropNow! My ID: $uid\n$_playStoreUrl';
    await Share.share(message);
  }

  /// Copy the user's ID to clipboard. Returns true on success.
  Future<bool> copyId(String uid) async {
    try {
      await Clipboard.setData(ClipboardData(text: uid));
      return true;
    } catch (_) {
      return false;
    }
  }
}
