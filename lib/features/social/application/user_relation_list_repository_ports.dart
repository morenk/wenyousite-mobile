import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';

abstract interface class UserRelationListRepository {
  Future<List<UserRelationListItem>> fetchFollowing({String? userId});

  Future<List<UserRelationListItem>> fetchFollowers({String? userId});

  Future<List<UserRelationListItem>> fetchBlocks();
}

final userRelationListRepositoryProvider = Provider<UserRelationListRepository>(
  (ref) {
    return const _UnboundUserRelationListRepository();
  },
);

class _UnboundUserRelationListRepository implements UserRelationListRepository {
  const _UnboundUserRelationListRepository();

  @override
  Future<List<UserRelationListItem>> fetchFollowing({String? userId}) {
    return Future.error(_error());
  }

  @override
  Future<List<UserRelationListItem>> fetchFollowers({String? userId}) {
    return Future.error(_error());
  }

  @override
  Future<List<UserRelationListItem>> fetchBlocks() => Future.error(_error());
}

StateError _error() => StateError('用户关系列表仓储尚未在应用组合根绑定。');
