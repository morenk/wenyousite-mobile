import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

enum ThreadArchiveFormat { text, markdown, both }

class ThreadArchiveOptions {
  const ThreadArchiveOptions({
    this.format = ThreadArchiveFormat.both,
    this.includeAuthors = true,
    this.includeTimestamps = true,
    this.includeFloorNumbers = true,
    this.includeReplyTargets = true,
    this.includeSourceLinks = false,
    this.includeMedia = true,
  });

  final ThreadArchiveFormat format;
  final bool includeAuthors;
  final bool includeTimestamps;
  final bool includeFloorNumbers;
  final bool includeReplyTargets;
  final bool includeSourceLinks;
  final bool includeMedia;
}

typedef ThreadArchive = ({Uint8List bytes, String fileName});

abstract interface class ThreadManagementRepository {
  Future<ThreadManagementBootstrap> load(String threadId);

  Future<ThreadManagementSnapshot> update({
    required ThreadManagementSnapshot current,
    required ThreadManagementDraft draft,
  });

  Future<void> remove(String threadId);

  Future<ThreadArchive> exportArchive(
    String threadId,
    ThreadArchiveOptions options,
  );
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

  @override
  Future<ThreadArchive> exportArchive(
    String threadId,
    ThreadArchiveOptions options,
  ) => Future.error(_error());
}

StateError _error() => StateError('主题管理仓储尚未在应用组合根绑定。');
