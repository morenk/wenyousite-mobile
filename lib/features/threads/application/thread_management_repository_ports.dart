import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

abstract interface class ThreadManagementRepository {
  Future<ThreadManagementBootstrap> load(String threadId);

  Future<ThreadManagementSnapshot> update({
    required ThreadManagementSnapshot current,
    required ThreadManagementDraft draft,
  });

  Future<void> remove(String threadId);
}

final threadManagementRepositoryProvider = Provider<ThreadManagementRepository>(
  (ref) {
    return const _UnboundThreadManagementRepository();
  },
);

class _UnboundThreadManagementRepository implements ThreadManagementRepository {
  const _UnboundThreadManagementRepository();

  @override
  Future<ThreadManagementBootstrap> load(String threadId) {
    return Future.error(_error());
  }

  @override
  Future<ThreadManagementSnapshot> update({
    required ThreadManagementSnapshot current,
    required ThreadManagementDraft draft,
  }) => Future.error(_error());

  @override
  Future<void> remove(String threadId) => Future.error(_error());
}

StateError _error() => StateError('主题管理仓储尚未在应用组合根绑定。');
