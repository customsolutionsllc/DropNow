import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:drop_now/core/models/models.dart';
import 'package:drop_now/core/services/auth_service.dart';

/// Manages challenge lifecycle: create, accept, decline, complete.
/// All data lives in Firestore `challenges` collection.
class ChallengeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth;

  ChallengeService({required AuthService authService}) : _auth = authService;

  CollectionReference<Map<String, dynamic>> get _challengesCol =>
      _db.collection('challenges');

  bool get _isAvailable => _auth.isSignedIn;
  String? get _uid => _auth.uid;

  // ---------------------------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------------------------

  /// Create and send a challenge to another user.
  Future<Challenge?> createChallenge({
    required String toUserId,
    required WorkoutType workoutType,
    required int amount,
  }) async {
    if (!_isAvailable || _uid == null) return null;
    if (toUserId == _uid) return null; // Can't challenge yourself

    try {
      final docRef = _challengesCol.doc();
      final now = DateTime.now();
      final challenge = Challenge(
        id: docRef.id,
        fromUserId: _uid!,
        toUserId: toUserId,
        workoutType: workoutType,
        amount: amount,
        status: ChallengeStatus.pending,
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );

      await docRef.set(challenge.toFirestore());
      debugPrint(
        '[CHALLENGE] Created: ${challenge.id} → $toUserId '
        '(${workoutType.name} x$amount)',
      );
      return challenge;
    } catch (e) {
      debugPrint('[CHALLENGE] createChallenge error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // QUERIES
  // ---------------------------------------------------------------------------

  /// Stream of incoming challenges (where current user is the receiver).
  Stream<List<Challenge>> incomingChallenges() {
    if (!_isAvailable || _uid == null) return Stream.value([]);
    return _challengesCol
        .where('toUserId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Challenge.fromFirestore(d.data())).toList(),
        );
  }

  /// Stream of sent challenges (where current user is the sender).
  Stream<List<Challenge>> sentChallenges() {
    if (!_isAvailable || _uid == null) return Stream.value([]);
    return _challengesCol
        .where('fromUserId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Challenge.fromFirestore(d.data())).toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // STATUS UPDATES
  // ---------------------------------------------------------------------------

  /// Accept an incoming challenge.
  Future<bool> acceptChallenge(String challengeId) async {
    if (!_isAvailable) return false;
    try {
      await _challengesCol.doc(challengeId).update({
        'status': ChallengeStatus.accepted.name,
      });
      debugPrint('[CHALLENGE] Accepted: $challengeId');
      return true;
    } catch (e) {
      debugPrint('[CHALLENGE] acceptChallenge error: $e');
      return false;
    }
  }

  /// Decline an incoming challenge.
  Future<bool> declineChallenge(String challengeId) async {
    if (!_isAvailable) return false;
    try {
      await _challengesCol.doc(challengeId).update({
        'status': ChallengeStatus.declined.name,
      });
      debugPrint('[CHALLENGE] Declined: $challengeId');
      return true;
    } catch (e) {
      debugPrint('[CHALLENGE] declineChallenge error: $e');
      return false;
    }
  }

  /// Complete a challenge (mark as done with timestamp).
  Future<bool> completeChallenge(String challengeId) async {
    if (!_isAvailable) return false;
    try {
      await _challengesCol.doc(challengeId).update({
        'status': ChallengeStatus.completed.name,
        'completedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[CHALLENGE] Completed: $challengeId');
      return true;
    } catch (e) {
      debugPrint('[CHALLENGE] completeChallenge error: $e');
      return false;
    }
  }
}
