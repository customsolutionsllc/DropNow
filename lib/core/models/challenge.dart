import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop_now/core/models/workout_type.dart';

enum ChallengeStatus { pending, accepted, completed, declined, expired }

extension ChallengeStatusExtension on ChallengeStatus {
  String get label {
    switch (this) {
      case ChallengeStatus.pending:
        return 'Pending';
      case ChallengeStatus.accepted:
        return 'Accepted';
      case ChallengeStatus.completed:
        return 'Completed';
      case ChallengeStatus.declined:
        return 'Declined';
      case ChallengeStatus.expired:
        return 'Expired';
    }
  }

  String get emoji {
    switch (this) {
      case ChallengeStatus.pending:
        return '⏳';
      case ChallengeStatus.accepted:
        return '🔥';
      case ChallengeStatus.completed:
        return '✅';
      case ChallengeStatus.declined:
        return '❌';
      case ChallengeStatus.expired:
        return '⏰';
    }
  }
}

class Challenge {
  final String id;
  final String fromUserId;
  final String toUserId;
  final WorkoutType workoutType;
  final int amount;
  final ChallengeStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? completedAt;

  const Challenge({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.workoutType,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.completedAt,
  });

  bool get isExpired =>
      status == ChallengeStatus.pending && DateTime.now().isAfter(expiresAt);

  String get workoutLabel =>
      '${workoutType.label} × $amount${workoutType.isTimeBased ? 's' : ''}';

  String get timeLeft {
    if (isExpired) return 'Expired';
    final diff = expiresAt.difference(DateTime.now());
    if (diff.inHours >= 1) return '${diff.inHours}h left';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m left';
    return 'Expiring';
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'workoutType': workoutType.name,
      'amount': amount,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  factory Challenge.fromFirestore(Map<String, dynamic> data) {
    return Challenge(
      id: data['id'] as String? ?? '',
      fromUserId: data['fromUserId'] as String? ?? '',
      toUserId: data['toUserId'] as String? ?? '',
      workoutType: _parseWorkoutType(data['workoutType']),
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      status: _parseStatus(data['status']),
      createdAt: _parseTimestamp(data['createdAt']),
      expiresAt: _parseTimestamp(data['expiresAt']),
      completedAt: data['completedAt'] != null
          ? _parseTimestamp(data['completedAt'])
          : null,
    );
  }

  Challenge copyWith({ChallengeStatus? status, DateTime? completedAt}) {
    return Challenge(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      workoutType: workoutType,
      amount: amount,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  static WorkoutType _parseWorkoutType(dynamic value) {
    if (value == null) return WorkoutType.pushups;
    final str = value.toString();
    for (final v in WorkoutType.values) {
      if (v.name == str) return v;
    }
    return WorkoutType.pushups;
  }

  static ChallengeStatus _parseStatus(dynamic value) {
    if (value == null) return ChallengeStatus.pending;
    final str = value.toString();
    for (final v in ChallengeStatus.values) {
      if (v.name == str) return v;
    }
    return ChallengeStatus.pending;
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
