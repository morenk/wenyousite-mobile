import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/thread_identity/domain/identity_profile_link.dart';

typedef IdentityProfilePostLookup =
    Future<IdentityProfilePostTarget?> Function(String postId);

/// 组合根绑定已授权的楼层详情读取；身份模块不反向依赖楼层模块。
final identityProfilePostLookupProvider = Provider<IdentityProfilePostLookup>(
  (ref) => throw StateError('身份资料楼层查询尚未绑定。'),
);
