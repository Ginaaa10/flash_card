import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupsNotifier extends StateNotifier<List<String>> {
  GroupsNotifier() : super([]) {
    _loadGroups();
  }

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  void _loadGroups() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('groups')
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> addGroup(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.contains(trimmed)) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('groups')
        .doc(trimmed)
        .set({
      'name': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeGroup(String name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('groups')
        .doc(name)
        .delete();
  }
}

final groupsProvider = StateNotifierProvider<GroupsNotifier, List<String>>(
  (ref) => GroupsNotifier(),
);
