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
  ThreadIdentityState? identity;
  PostIdentityMode? mode;
  String? acceptedToken;
  ApiFailure? failure;
  bool loading = false;
  bool _disposed = false;
  int _epoch = 0;

  bool get changed =>
      mode == PostIdentityMode.rp &&
      (identity?.hasRp != true || acceptedToken != identity?.identityToken);
  String get displayName => mode == PostIdentityMode.rp
      ? identity?.displayName ?? '帖内身份'
      : identity?.accountName ?? '站内身份';

  Future<bool> refresh() async {
    final epoch = ++_epoch;
    loading = true;
    failure = null;
    notifyListeners();
    try {
      final value = await repository.mine(threadId);
      if (_disposed || epoch != _epoch) return false;
      identity = value;
      if (mode == null) {
        mode = value.hasRp ? PostIdentityMode.rp : PostIdentityMode.account;
        acceptedToken = value.identityToken;
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

  void select(PostIdentityMode next) {
    if (next == PostIdentityMode.rp && identity?.hasRp != true) return;
    mode = next;
    acceptedToken = identity?.identityToken;
    notifyListeners();
  }

  void confirmCurrent() {
    if (identity?.hasRp != true) mode = PostIdentityMode.account;
    acceptedToken = identity?.identityToken;
    notifyListeners();
  }

  void restore({required PostIdentityMode? selected, String? token}) {
    if (selected == null) return;
    mode = selected;
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
