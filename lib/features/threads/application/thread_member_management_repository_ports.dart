import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_member_management_models.dart';

abstract interface class ThreadMemberManagementRepository {
  Future<ThreadMemberManagementBootstrap> load(String threadId);

  Future<ThreadMemberManagementMember> updateMember({
    required String threadId,
    required String userId,
    ThreadMemberManagementRole? role,
    bool? playerMarked,
  });

  Future<void> exitPlayer(String threadId);
}

final threadMemberManagementRepositoryProvider =
    Provider<ThreadMemberManagementRepository>((ref) {
      return const _UnboundThreadMemberManagementRepository();
    });

class _UnboundThreadMemberManagementRepository
    implements ThreadMemberManagementRepository {
  const _UnboundThreadMemberManagementRepository();

  @override
  Future<ThreadMemberManagementBootstrap> load(String threadId) {
    return Future.error(_error());
  }

  @override
  Future<ThreadMemberManagementMember> updateMember({
    required String threadId,
    required String userId,
    ThreadMemberManagementRole? role,
    bool? playerMarked,
  }) => Future.error(_error());

  @override
  Future<void> exitPlayer(String threadId) => Future.error(_error());
}

StateError _error() => StateError('主题成员管理仓储尚未在应用组合根绑定。');
