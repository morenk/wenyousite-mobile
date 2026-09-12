import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_management_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/data/subthread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_invitation_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_page.dart';

Future<void> pumpThreadManagementTestPage(
  WidgetTester tester,
  ThreadManagementRepository repository, {
  ThreadInvitationRepository? invitationRepository,
  SubthreadManagementRepository? subthreadRepository,
}) async {
  final container = ProviderContainer(
    overrides: [
      threadManagementRepositoryProvider.overrideWithValue(repository),
      if (invitationRepository != null)
        threadInvitationRepositoryProvider.overrideWithValue(
          invitationRepository,
        ),
      if (subthreadRepository != null)
        subthreadManagementRepositoryProvider.overrideWithValue(
          subthreadRepository,
        ),
    ],
  );
  final router = GoRouter(
    initialLocation: '/thread',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('首页占位')),
      ),
      GoRoute(
        path: '/thread',
        builder: (_, _) => Scaffold(
          body: Center(
            child: FilledButton(onPressed: () {}, child: const Text('主题详情占位')),
          ),
        ),
      ),
      GoRoute(
        path: '/threads/:threadId/manage',
        builder: (_, state) =>
            ThreadManagementPage(threadId: state.pathParameters['threadId']!),
      ),
      GoRoute(
        path: '/threads/:threadId/manage/tags',
        builder: (_, _) => const Scaffold(body: Text('标签工作台占位')),
      ),
      GoRoute(
        path: '/threads/:threadId/manage/subthreads',
        builder: (_, _) => const Scaffold(body: Text('子贴工作台占位')),
      ),
    ],
  );
  addTearDown(router.dispose);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  unawaited(router.push('/threads/thread-1/manage'));
  await tester.pumpAndSettle();
}

class ThreadManagementTestRepository implements ThreadManagementRepository {
  ThreadManagementTestRepository({
    required this.initial,
    ThreadManagementBootstrap? latest,
    this.conflictOnce = false,
    this.loadFailure,
    this.failLoadOnce = false,
    this.updateFailure,
    this.removeFailure,
  }) : latest = latest ?? initial;

  final ThreadManagementBootstrap initial;
  final ThreadManagementBootstrap latest;
  final bool conflictOnce;
  ApiFailure? loadFailure;
  final bool failLoadOnce;
  final ApiFailure? updateFailure;
  final ApiFailure? removeFailure;
  int loadCalls = 0;
  int removeCalls = 0;
  int updateCalls = 0;
  bool _didConflict = false;
  ThreadManagementDraft? lastDraft;

  @override
  Future<ThreadManagementBootstrap> load(String threadId) async {
    loadCalls += 1;
    final failure = loadFailure;
    if (failure != null) {
      if (failLoadOnce) loadFailure = null;
      throw failure;
    }
    return loadCalls == 1 ? initial : latest;
  }

  @override
  Future<void> remove(String threadId) async {
    removeCalls += 1;
    if (removeFailure != null) throw removeFailure!;
  }

  @override
  Future<ThreadManagementSnapshot> update({
    required ThreadManagementSnapshot current,
    required ThreadManagementDraft draft,
  }) async {
    lastDraft = draft;
    updateCalls += 1;
    if (updateFailure != null) throw updateFailure!;
    if (conflictOnce && !_didConflict) {
      _didConflict = true;
      throw const ApiFailure(
        userMessage: '内容已在其他位置修改',
        businessCode: 40002,
        httpStatus: 409,
      );
    }
    return ThreadManagementSnapshot(
      id: current.id,
      title: draft.title.trim(),
      categorySlug: draft.categorySlug,
      status: draft.status,
      visibility: draft.visibility,
      defaultSubthreadPostingPolicy:
          draft.defaultSubthreadPostingPolicy ??
          current.defaultSubthreadPostingPolicy,
      version: current.version + 1,
      published: current.published,
      canManage: true,
      isOwner: current.isOwner,
      defaultSubthreadId: current.defaultSubthreadId,
      defaultSubthreadVersion: current.defaultSubthreadVersion,
      bodyPostId: current.bodyPostId,
      bodyVersion: current.bodyVersion,
      body: current.body,
      tagNames: draft.normalizedTagNames,
    );
  }

  @override
  Future<ThreadArchive> exportArchive(
    String threadId,
    ThreadArchiveOptions options,
  ) => throw UnsupportedError('unused');
}

ThreadManagementBootstrap threadManagementTestBootstrap({
  int version = 1,
  String title = '原主题',
  bool isOwner = true,
  bool canManage = true,
  bool published = true,
  SubthreadPostingPolicy postingPolicy = SubthreadPostingPolicy.participants,
  ThreadManagementVisibility visibility = ThreadManagementVisibility.public,
  List<String> tagNames = const [],
}) {
  return ThreadManagementBootstrap(
    thread: ThreadManagementSnapshot(
      id: 'thread-1',
      title: title,
      categorySlug: 'RPG',
      status: ThreadManagementStatus.recruiting,
      visibility: visibility,
      version: version,
      published: published,
      defaultSubthreadPostingPolicy: postingPolicy,
      canManage: canManage,
      isOwner: isOwner,
      tagNames: tagNames,
    ),
    categories: const [
      ThreadManagementCategory(
        slug: 'RPG',
        name: '角色扮演',
        sortOrder: 1,
        description: '适合角色扮演主题',
      ),
      ThreadManagementCategory(
        slug: 'BOARD',
        name: '综合讨论',
        sortOrder: 2,
        description: '适合综合讨论主题',
      ),
    ],
  );
}

class ThreadManagementTestInvitationRepository
    implements ThreadInvitationRepository {
  @override
  Future<ThreadInvitationLink> generateLink(String threadId) {
    throw UnimplementedError();
  }

  @override
  Future<ThreadInvitationJoinResult> join(String token) {
    throw UnimplementedError();
  }

  @override
  Future<ThreadInvitationPreview> preview(String token) {
    throw UnimplementedError();
  }
}

class ThreadManagementTestSubthreadRepository
    implements SubthreadManagementRepository {
  @override
  Future<SubthreadManagementBootstrap> load(String threadId) async {
    return SubthreadManagementBootstrap(
      threadId: threadId,
      threadTitle: '原主题',
      items: const [],
    );
  }

  @override
  Future<SubthreadManagementItem> create({
    required String threadId,
    required SubthreadManagementDraft draft,
    required String clientRequestId,
  }) => throw UnimplementedError();

  @override
  Future<SubthreadManagementItem> findById({
    required String threadId,
    required String subthreadId,
    required bool isDefault,
  }) => throw UnimplementedError();

  @override
  Future<void> remove(SubthreadManagementItem item) =>
      throw UnimplementedError();

  @override
  Future<List<SubthreadManagementItem>> reorder({
    required String threadId,
    required List<SubthreadManagementItem> items,
  }) => throw UnimplementedError();

  @override
  Future<SubthreadManagementItem> update({
    required SubthreadManagementItem current,
    required SubthreadManagementDraft draft,
  }) => throw UnimplementedError();
}
