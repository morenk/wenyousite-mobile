import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';

abstract interface class UserRelationRepository {
  Future<void> follow(String userId);

  Future<void> unfollow(String userId);

  Future<void> block(String userId);

  Future<void> unblock(String userId);
}

abstract interface class UserRelationProjectionReader {
  Future<UserRelationProjection> fetchRelation(String userId);
}

final userRelationRepositoryProvider = Provider<UserRelationRepository>((ref) {
  return const _UnboundUserRelationRepository();
});

class _UnboundUserRelationRepository implements UserRelationRepository {
  const _UnboundUserRelationRepository();

  @override
  Future<void> follow(String userId) => Future.error(_error());

  @override
  Future<void> unfollow(String userId) => Future.error(_error());

  @override
  Future<void> block(String userId) => Future.error(_error());

  @override
  Future<void> unblock(String userId) => Future.error(_error());
}

StateError _error() => StateError('用户关系仓储尚未在应用组合根绑定。');
