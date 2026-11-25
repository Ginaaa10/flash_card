import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_card_app/features/auth/domain/providers/auth_provider.dart';

/// Last error while loading or saving groups, shown in the Groups tab.
final groupsErrorProvider = StateProvider<String?>((ref) => null);

String describeGroupError(Object error, String action) {
  if (error is FirebaseException && error.code == 'permission-denied') {
    return 'Permission denied. Allow the groups collection in your Firestore rules.';
  }
  if (error is FirebaseException) {
    return 'Could not $action: ${error.message ?? error.code}';
  }
  return 'Could not $action: $error';
}

class GroupsNotifier extends StateNotifier<List<String>> {
  GroupsNotifier(this._ref) : super([]) {
    _loadGroups();
  }

  final Ref _ref;

  StreamSubscription<QuerySnapshot>? _subscription;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  void _setError(String? message) {
    _ref.read(groupsErrorProvider.notifier).state = message;
  }

  void _loadGroups() {
    _subscription?.cancel();
    final uid = _uid;
    if (uid == null) {
      state = [];
      return;
    }
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('groups')
        .orderBy('name')
        .snapshots()
        .listen(
      (snapshot) {
        state = snapshot.docs.map((doc) => doc['name'] as String).toList();
        _setError(null);
      },
      onError: (Object e) {
        debugPrint('groups load failed: $e');
        _setError(describeGroupError(e, 'load groups'));
      },
    );
  }

  /// Rebinds the listener after the signed-in user changes.
  void reload() {
    state = [];
    _setError(null);
    _loadGroups();
  }

  Future<void> addGroup(String name) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Not signed in.');
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.contains(trimmed)) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('groups')
        .doc(trimmed)
        .set({
      'name': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _setError(null);
    // Show the group immediately; the stream will confirm it too.
    if (!state.contains(trimmed)) {
      state = [...state, trimmed]..sort();
    }
  }

  Future<void> removeGroup(String name) async {
    final uid = _uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('groups')
        .doc(name)
        .delete();
    state = state.where((g) => g != name).toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final groupsProvider = StateNotifierProvider<GroupsNotifier, List<String>>(
  (ref) {
    final notifier = GroupsNotifier(ref);
    ref.listen(authStateProvider, (previous, next) {
      if (previous?.valueOrNull?.uid != next.valueOrNull?.uid) {
        notifier.reload();
      }
    });
    return notifier;
  },
);
