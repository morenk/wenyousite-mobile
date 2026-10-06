import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_preference_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

/// 一个编辑会话持有自己的选择，不跟随阅读缓存失效或另一个编辑器的选择。
class PostIdentitySelection extends ChangeNotifier {
  PostIdentitySelection(
    this.repository,
    this.threadId, {
    this.preferences,
    this.accountId,
  });
  final ThreadIdentityRepository repository;
  final String threadId;
  final PostIdentityPreferenceStore? preferences;
  final String? accountId;
  ThreadIdentityCollection? collection;
  String? identityId;
  ThreadIdentityState? get identity =>
      collection?.find(identityId) ?? collection?.account;
  PostIdentityMode? mode;
  String? acceptedToken;
  ApiFailure? failure;
  bool loading = false;
  bool _disposed = false;
  int _epoch = 0;
  bool _resolveLegacy = false;

  bool get changed =>
      mode == PostIdentityMode.rp &&
      (collection?.find(identityId)?.hasRp != true ||
          acceptedToken != identity?.identityToken);
  String get displayName => mode == PostIdentityMode.rp
      ? identity?.displayName ?? '帖内身份'
      : identity?.accountName ?? '站内身份';

  Future<bool> refresh({bool useRecentChoice = false}) async {
    if (useRecentChoice) {
      mode = null;
      identityId = null;
      acceptedToken = null;
      _resolveLegacy = false;
    }
    final epoch = ++_epoch;
    loading = true;
    failure = null;
    notifyListeners();
    try {
      final value = await repository.list(threadId);
      if (_disposed || epoch != _epoch) return false;
      collection = value;
      if (mode == null) {
        String? remembered;
        if (accountId case final account?
            when account == value.account.userId) {
          try {
            remembered = await preferences?.read(account, threadId);
          } on Object {
            // 非必要偏好读取失败不影响加载当前可用身份。
          }
        }
        if (_disposed || epoch != _epoch) return false;
        // 恢复草稿或主动切换可能发生在等待偏好期间，不能被覆盖。
        if (mode == null) {
          final previous = value.find(remembered);
          final usable =
              value.account.enabled &&
              value.account.eligible &&
              previous?.hasRp == true;
          identityId = usable ? remembered : null;
          mode = usable ? PostIdentityMode.rp : PostIdentityMode.account;
          acceptedToken = usable ? previous!.identityToken : null;
        }
      }
      // 旧 RP 草稿只迁移到明确的兼容身份，绝不猜另一个角色。
      if (_resolveLegacy) {
        _resolveLegacy = false;
        identityId = value.compatibilityIdentityId;
      }
      return true;
    } on Object catch (error) {
      if (!_disposed && epoch == _epoch) {
        failure = mapApplicationFailure(error, '发表身份加载失败，请重试。');
      }
      return false;
    } finally {
      if (!_disposed && epoch == _epoch) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void select(PostIdentityMode next, {String? id}) {
    if (_disposed) return;
    final candidate = id ?? identityId;
    if (next == PostIdentityMode.rp &&
        collection?.find(candidate)?.hasRp != true) {
      return;
    }
    identityId = next == PostIdentityMode.rp ? candidate : null;
    mode = next;
    acceptedToken = mode == PostIdentityMode.rp
        ? identity?.identityToken
        : null;
    _remember();
    notifyListeners();
  }

  void confirmCurrent() {
    if (_disposed) return;
    if (collection?.find(identityId)?.hasRp != true) {
      mode = PostIdentityMode.account;
      identityId = null;
    }
    acceptedToken = mode == PostIdentityMode.rp
        ? identity?.identityToken
        : null;
    _remember();
    notifyListeners();
  }

  /// 保存结果已明确角色 ID；后续列表读取失败也不能丢失用户的新选择。
  void acceptSaved(ThreadIdentityState saved, {required bool created}) {
    if (!saved.hasRp || saved.identityId == null) return;
    if (created ||
        (mode == PostIdentityMode.rp && identityId == saved.identityId)) {
      restore(
        selected: PostIdentityMode.rp,
        id: saved.identityId,
        token: saved.identityToken,
      );
      _remember();
    }
  }

  void _remember() {
    final account = accountId;
    if (_disposed ||
        mode == null ||
        account == null ||
        collection?.account.userId != account) {
      return;
    }
    unawaited(
      _savePreference(account, mode == PostIdentityMode.rp ? identityId : null),
    );
  }

  /// 未知结果重试必须以实际返回的发言身份为准，不能记录另一个菜单选择。
  void rememberPublishedIdentity(String? publishedIdentityId) {
    final account = accountId;
    if (_disposed || account == null || collection?.account.userId != account) {
      return;
    }
    unawaited(_savePreference(account, publishedIdentityId));
  }

  Future<void> _savePreference(String account, String? chosenId) async {
    try {
      await preferences?.write(account, threadId, chosenId);
    } on Object {
      // 选择已经生效，偏好失败不能改变正文或阻止发表。
    }
  }

  void restore({
    required PostIdentityMode? selected,
    String? token,
    String? id,
  }) {
    if (selected == null) return;
    mode = selected;
    identityId = selected == PostIdentityMode.rp ? id : null;
    _resolveLegacy = selected == PostIdentityMode.rp && id == null;
    acceptedToken = token;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    super.dispose();
  }
}
