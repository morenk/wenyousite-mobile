import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';

export 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart'
    show MomentDraftStore, MomentLocalDraft, momentDraftStoreProvider;

class SharedPreferencesMomentDraftStore implements MomentDraftStore {
  static const _prefix = 'moment.compose.draft.v1';

  String _key(String? momentId) => '$_prefix:${momentId ?? 'new'}';

  @override
  Future<MomentLocalDraft?> read(String? momentId) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key(momentId));
    if (raw == null) return null;
    try {
      final draft = MomentLocalDraft.fromJson(jsonDecode(raw));
      if (draft != null) return draft;
    } on FormatException {
      // Invalid local data is discarded below.
    }
    await preferences.remove(_key(momentId));
    return null;
  }

  @override
  Future<void> write(String? momentId, MomentLocalDraft draft) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key(momentId), jsonEncode(draft.toJson()));
  }

  @override
  Future<void> delete(String? momentId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key(momentId));
  }
}

final sharedPreferencesMomentDraftStoreProvider = Provider<MomentDraftStore>((
  ref,
) {
  return SharedPreferencesMomentDraftStore();
});
