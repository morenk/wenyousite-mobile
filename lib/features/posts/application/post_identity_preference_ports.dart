import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 仅记住账号在主题内主动选择的角色 ID；null 表示站内身份。
abstract interface class PostIdentityPreferenceStore {
  Future<String?> read(String accountId, String threadId);
  Future<void> write(String accountId, String threadId, String? identityId);
}

class MemoryPostIdentityPreferenceStore implements PostIdentityPreferenceStore {
  final _values = <(String, String), String?>{};

  @override
  Future<String?> read(String accountId, String threadId) async =>
      _values[(accountId, threadId)];

  @override
  Future<void> write(
    String accountId,
    String threadId,
    String? identityId,
  ) async {
    _values[(accountId, threadId)] = identityId;
  }
}

final postIdentityPreferenceStoreProvider =
    Provider<PostIdentityPreferenceStore>(
      (ref) => MemoryPostIdentityPreferenceStore(),
    );
