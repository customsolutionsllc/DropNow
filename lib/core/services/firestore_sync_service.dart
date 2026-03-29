import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drop_now/core/models/models.dart';
import 'package:drop_now/core/services/auth_service.dart';
import 'package:drop_now/core/services/preferences_service.dart';
import 'package:drop_now/core/services/execution_storage_service.dart';

/// Syncs local data to/from Firestore. Local-first: cloud is backup + restore.
/// Includes offline queue with persistent retry.
class FirestoreSyncService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth;
  final PreferencesService _prefs;
  final ExecutionStorageService _storage;
  final SharedPreferences _sharedPrefs;

  bool _isSyncing = false;
  bool _isOnline = true;
  Timer? _connectivityTimer;

  static const _offlineQueueKey = 'firestore_offline_queue';

  /// Queue of records waiting to be synced (persisted in SharedPreferences).
  final List<Map<String, dynamic>> _offlineQueue = [];

  FirestoreSyncService({
    required AuthService authService,
    required PreferencesService prefsService,
    required ExecutionStorageService storageService,
    required SharedPreferences sharedPrefs,
  }) : _auth = authService,
       _prefs = prefsService,
       _storage = storageService,
       _sharedPrefs = sharedPrefs;

  /// Initialize offline support: enable persistence, load queue, start monitoring.
  Future<void> init() async {
    try {
      _db.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: 10485760, // 10 MB
      );
    } catch (_) {
      // Settings already applied or not supported
    }
    _loadQueueFromPrefs();
    _startConnectivityMonitor();
    debugPrint(
      '[SYNC] Offline-first initialized, queue: ${_offlineQueue.length} items',
    );
  }

  void dispose() {
    _connectivityTimer?.cancel();
  }

  /// Whether cloud sync is available (user is authenticated).
  bool get isSyncAvailable => _auth.isSignedIn;

  // ---------------------------------------------------------------------------
  // USER PROFILE
  // ---------------------------------------------------------------------------

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_auth.uid);

  CollectionReference<Map<String, dynamic>> get _executionsCol =>
      _userDoc.collection('executions');

  /// Bootstrap user profile in Firestore. Merge-safe (won't overwrite existing).
  Future<void> bootstrapUserProfile() async {
    if (!isSyncAvailable) return;
    try {
      final doc = await _userDoc.get();
      if (!doc.exists) {
        await _userDoc.set(_buildUserProfile());
        debugPrint('[SYNC] Created user profile doc at users/${_auth.uid}');
      } else {
        debugPrint('[SYNC] User profile already exists at users/${_auth.uid}');
      }
    } catch (e) {
      debugPrint('[SYNC] bootstrapUserProfile error: $e');
    }
  }

  Map<String, dynamic> _buildUserProfile() {
    return {
      'uid': _auth.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
      'authProvider': _auth.isAnonymous ? 'anonymous' : 'linked',
      'displayName': null,
      'personality': _prefs.personality.name,
      'difficulty': _prefs.difficulty.name,
      'frequencyPerDay': _prefs.frequency,
      'activeStartHour': _prefs.windowStart.hour,
      'activeStartMinute': _prefs.windowStart.minute,
      'activeEndHour': _prefs.windowEnd.hour,
      'activeEndMinute': _prefs.windowEnd.minute,
      'systemEnabled': _prefs.isSystemActive,
    };
  }

  /// Sync user preferences to Firestore (call after any settings change).
  Future<void> syncPreferences() async {
    if (!isSyncAvailable) return;
    try {
      await _userDoc.set({
        'lastSeenAt': FieldValue.serverTimestamp(),
        'personality': _prefs.personality.name,
        'difficulty': _prefs.difficulty.name,
        'frequencyPerDay': _prefs.frequency,
        'activeStartHour': _prefs.windowStart.hour,
        'activeStartMinute': _prefs.windowStart.minute,
        'activeEndHour': _prefs.windowEnd.hour,
        'activeEndMinute': _prefs.windowEnd.minute,
        'systemEnabled': _prefs.isSystemActive,
      }, SetOptions(merge: true));
      debugPrint('[SYNC] Preferences synced to Firestore');
    } catch (e) {
      debugPrint('[SYNC] syncPreferences error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // EXECUTION RECORD SYNC
  // ---------------------------------------------------------------------------

  /// Upload a single execution record to Firestore.
  /// Falls back to offline queue if the write fails.
  Future<bool> syncRecord(ExecutionRecord record) async {
    if (!isSyncAvailable) return false;
    try {
      await _executionsCol
          .doc(record.id)
          .set(_recordToFirestore(record), SetOptions(merge: true));
      debugPrint(
        '[SYNC] Uploaded execution: ${record.id} (${record.workoutType.name} x${record.amount})',
      );
      return true;
    } catch (e) {
      debugPrint('[SYNC] syncRecord failed, queuing offline: $e');
      _enqueueOffline(_recordToFirestore(record), record.id);
      return false;
    }
  }

  /// Upload all unsynced local records to Firestore.
  /// Safe to call repeatedly — uses record ID as doc ID.
  Future<int> syncAllLocal() async {
    if (!isSyncAvailable || _isSyncing) return 0;
    _isSyncing = true;
    int synced = 0;
    try {
      for (final date in _storage.allDates) {
        final records = _storage.getRecordsForDate(date);
        for (final record in records) {
          if (record.status == CommandStatus.generated) continue;
          final ok = await syncRecord(record);
          if (ok) synced++;
        }
      }
    } catch (_) {
      // Partial sync is fine
    } finally {
      _isSyncing = false;
    }
    return synced;
  }

  /// Restore cloud executions to local storage.
  /// Only adds records that don't already exist locally.
  Future<int> restoreFromCloud() async {
    if (!isSyncAvailable) return 0;
    int restored = 0;
    try {
      final snapshot = await _executionsCol
          .orderBy('timestamp', descending: true)
          .limit(500)
          .get();

      debugPrint('[SYNC] Cloud has ${snapshot.docs.length} execution docs');
      for (final doc in snapshot.docs) {
        final record = _recordFromFirestore(doc.data());
        if (record == null) continue;
        // Only add if not already local
        if (!_storage.isRecorded(record.id, date: record.date)) {
          await _storage.addRecord(record);
          restored++;
          debugPrint('[SYNC] Restored: ${record.id} (${record.date})');
        }
      }
    } catch (e) {
      debugPrint('[SYNC] restoreFromCloud error: $e');
    }
    return restored;
  }

  /// Full sync: upload local → download cloud missing records.
  Future<({int uploaded, int restored})> fullSync() async {
    final uploaded = await syncAllLocal();
    final restored = await restoreFromCloud();
    // Update lastSeenAt
    if (isSyncAvailable) {
      try {
        await _userDoc.set({
          'lastSeenAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
    return (uploaded: uploaded, restored: restored);
  }

  // ---------------------------------------------------------------------------
  // FIRESTORE ↔ LOCAL CONVERSION
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _recordToFirestore(ExecutionRecord r) {
    return {
      'id': r.id,
      'timestamp': Timestamp.fromDate(r.timestamp),
      'dateKey': r.date,
      'workoutType': r.workoutType.name,
      'amount': r.amount,
      'difficulty': r.difficulty.name,
      'personality': r.personality.name,
      'status': r.status == CommandStatus.completed ? 'done' : 'skipped',
      'calories': r.calories,
      'displayText': r.displayText,
      'source': 'local_sync',
    };
  }

  ExecutionRecord? _recordFromFirestore(Map<String, dynamic> data) {
    try {
      final statusStr = data['status'] as String? ?? '';
      final status = statusStr == 'done'
          ? CommandStatus.completed
          : CommandStatus.skipped;

      final timestamp = data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(data['timestamp']?.toString() ?? '') ??
                DateTime.now();

      return ExecutionRecord(
        id: data['id'] as String? ?? '',
        timestamp: timestamp,
        date: data['dateKey'] as String? ?? '',
        workoutType: _parseEnum(
          WorkoutType.values,
          data['workoutType'],
          WorkoutType.pushups,
        ),
        amount: (data['amount'] as num?)?.toInt() ?? 0,
        difficulty: _parseEnum(
          Difficulty.values,
          data['difficulty'],
          Difficulty.medium,
        ),
        personality: _parseEnum(
          Personality.values,
          data['personality'],
          Personality.commander,
        ),
        status: status,
        calories: (data['calories'] as num?)?.toDouble() ?? 0,
        displayText: data['displayText'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  T _parseEnum<T extends Enum>(List<T> values, dynamic name, T fallback) {
    if (name == null) return fallback;
    final str = name.toString();
    for (final v in values) {
      if (v.name == str) return v;
    }
    return fallback;
  }

  // ---------------------------------------------------------------------------
  // OFFLINE QUEUE
  // ---------------------------------------------------------------------------

  void _enqueueOffline(Map<String, dynamic> data, String docId) {
    data['_docId'] = docId;
    _offlineQueue.add(data);
    _saveQueueToPrefs();
    debugPrint('[SYNC] Offline queue size: ${_offlineQueue.length}');
  }

  /// Flush all queued writes to Firestore.
  Future<void> syncOfflineQueue() async {
    if (!isSyncAvailable || _offlineQueue.isEmpty) return;
    debugPrint('[SYNC] Flushing ${_offlineQueue.length} queued writes...');

    final pending = List<Map<String, dynamic>>.from(_offlineQueue);
    int synced = 0;

    for (final item in pending) {
      try {
        final docId = item['_docId'] as String? ?? item['id'] as String? ?? '';
        if (docId.isEmpty) continue;
        final data = Map<String, dynamic>.from(item)..remove('_docId');
        await _executionsCol.doc(docId).set(data, SetOptions(merge: true));
        _offlineQueue.remove(item);
        synced++;
      } catch (e) {
        debugPrint('[SYNC] Queue flush failed for item: $e');
        break; // Stop on first failure — will retry next cycle
      }
    }

    _saveQueueToPrefs();
    debugPrint('[SYNC] Flushed $synced/${pending.length} queued writes');
  }

  void _saveQueueToPrefs() {
    try {
      final encoded = jsonEncode(_offlineQueue);
      _sharedPrefs.setString(_offlineQueueKey, encoded);
    } catch (e) {
      debugPrint('[SYNC] Failed to save offline queue: $e');
    }
  }

  void _loadQueueFromPrefs() {
    try {
      final raw = _sharedPrefs.getString(_offlineQueueKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _offlineQueue.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _offlineQueue.add(item);
          }
        }
      }
    } catch (e) {
      debugPrint('[SYNC] Failed to load offline queue: $e');
    }
  }

  void _startConnectivityMonitor() {
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup(
        'firestore.googleapis.com',
      ).timeout(const Duration(seconds: 5));
      final wasOffline = !_isOnline;
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (_isOnline && wasOffline) {
        debugPrint('[SYNC] Back online — syncing offline queue');
        await syncOfflineQueue();
      }
    } catch (_) {
      _isOnline = false;
    }
  }
}
