import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';

abstract interface class SubthreadManagementRepository {
  Future<SubthreadManagementBootstrap> load(String threadId);

  Future<SubthreadManagementItem> findById({
    required String threadId,
    required String subthreadId,
    required bool isDefault,
  });

  Future<SubthreadManagementItem> create({
    required String threadId,
    required SubthreadManagementDraft draft,
    required String clientRequestId,
  });

  Future<SubthreadManagementItem> update({
    required SubthreadManagementItem current,
    required SubthreadManagementDraft draft,
  });

  Future<void> remove(SubthreadManagementItem item);

  Future<List<SubthreadManagementItem>> reorder({
    required String threadId,
    required List<SubthreadManagementItem> items,
  });
}

final subthreadManagementRepositoryProvider =
    Provider<SubthreadManagementRepository>((ref) {
      return const _UnboundSubthreadManagementRepository();
    });

class _UnboundSubthreadManagementRepository
    implements SubthreadManagementRepository {
  const _UnboundSubthreadManagementRepository();

  @override
  Future<SubthreadManagementBootstrap> load(String threadId) {
    return Future.error(_error());
  }

  @override
  Future<SubthreadManagementItem> findById({
    required String threadId,
    required String subthreadId,
    required bool isDefault,
  }) => Future.error(_error());

  @override
  Future<SubthreadManagementItem> create({
    required String threadId,
    required SubthreadManagementDraft draft,
    required String clientRequestId,
  }) => Future.error(_error());

  @override
  Future<SubthreadManagementItem> update({
    required SubthreadManagementItem current,
    required SubthreadManagementDraft draft,
  }) => Future.error(_error());

  @override
  Future<void> remove(SubthreadManagementItem item) => Future.error(_error());

  @override
  Future<List<SubthreadManagementItem>> reorder({
    required String threadId,
    required List<SubthreadManagementItem> items,
  }) => Future.error(_error());
}

StateError _error() => StateError('子贴管理仓储尚未在应用组合根绑定。');
