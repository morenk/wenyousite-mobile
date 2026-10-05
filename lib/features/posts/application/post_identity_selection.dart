import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

/// 一个编辑会话持有自己的选择，不跟随阅读缓存失效或另一个编辑器的选择。
class PostIdentitySelection extends ChangeNotifier {
  PostIdentitySelection(this.repository, this.threadId);
  final ThreadIdentityRepository repository;
  final String threadId;
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

  Future<bool> refresh() async {
    final epoch = ++_epoch;
    loading = true;
    failure = null;
    notifyListeners();
    try {
      final value = await repository.list(threadId);
      if (_disposed || epoch != _epoch) return false;
      collection = value;
      if (mode == null) {
        identityId = null;
        mode = PostIdentityMode.account;
        acceptedToken = null;
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
    notifyListeners();
  }

  void confirmCurrent() {
    if (collection?.find(identityId)?.hasRp != true) {
      mode = PostIdentityMode.account;
      identityId = null;
    }
    acceptedToken = mode == PostIdentityMode.rp
        ? identity?.identityToken
        : null;
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
