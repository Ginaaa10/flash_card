import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_card_app/features/auth/domain/providers/auth_provider.dart';

class GroupsNotifier extends StateNotifier<List<String>> {
  GroupsNotifier() : super([]) {
    _loadGroups();
  }

  StreamSubscription<QuerySnapshot>? _subscription;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

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
      },
      onError: (Object e) => debugPrint('groups load failed: $e'),
    );
  }

  /// Rebinds the listener after the signed-in user changes.
  void reload() {
    state = [];
    _loadGroups();
  }

  Future<void> addGroup(String name) async {
    final uid = _uid;
    if (uid == null) return;
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
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final groupsProvider = StateNotifierProvider<GroupsNotifier, List<String>>(
  (ref) {
    final notifier = GroupsNotifier();
    ref.listen(authStateProvider, (previous, next) {
      if (previous?.valueOrNull?.uid != next.valueOrNull?.uid) {
        notifier.reload();
      }
    });
    return notifier;
  },
);
