import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/message_center_page.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_conversation_page.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/new_direct_conversation_page.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_feed_page.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/search/presentation/search_page.dart';
import 'package:wenyousite_mobile/features/search/presentation/thread_post_search_page.dart';
import 'package:wenyousite_mobile/features/tags/presentation/tag_threads_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/subthread_editor_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_compose_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_invitation_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_page.dart';

List<RouteBase> buildContentRoutes() => [
  GoRoute(
    path: AppRouteLocations.search,
    name: AppRouteNames.search,
    builder: (context, state) => const SearchPage(),
  ),
  GoRoute(
    path: AppRoutePaths.momentEdit,
    name: AppRouteNames.momentEdit,
    builder: (context, state) =>
        MomentComposePage(momentId: state.pathParameters['momentId']!),
  ),
  GoRoute(
    path: AppRoutePaths.momentDetail,
    name: AppRouteNames.momentDetail,
    builder: (context, state) => MomentDetailPage(
      momentId: state.pathParameters['momentId']!,
      targetCommentId: state.uri.queryParameters['comment'],
    ),
  ),
  GoRoute(
    path: AppRoutePaths.userMoments,
    name: AppRouteNames.userMoments,
    builder: (context, state) => MomentCollectionPage(
      target: MomentFeedTarget.user(state.pathParameters['userId']!),
      title: '用户动态',
      emptyTitle: '还没有公开动态',
      emptyMessage: '这位用户暂时没有发布公开动态。',
    ),
  ),
  GoRoute(
    path: AppRoutePaths.directMessages,
    name: AppRouteNames.directMessages,
    redirect: (context, state) => AppRouteLocations.messageCenter(
      section: MessageCenterSections.directMessages,
    ),
  ),
  GoRoute(
    path: AppRoutePaths.directMessageNew,
    name: AppRouteNames.directMessageNew,
    builder: (context, state) =>
        NewDirectConversationPage(userId: state.pathParameters['userId']!),
  ),
  GoRoute(
    path: AppRoutePaths.directConversation,
    name: AppRouteNames.directConversation,
    builder: (context, state) {
      final conversationId = state.pathParameters['conversationId']!;
      return Consumer(
        builder: (_, ref, _) => DirectConversationPage(
          conversationId: conversationId,
          onReportMessage: (reportContext, messageId) => showWenyouReportFlow(
            context: reportContext,
            ref: ref,
            target: ReportTarget.directMessage(messageId),
            targetLabel: '这条私信',
            returnTo: Uri(
              pathSegments: ['', 'messages', conversationId],
            ).toString(),
          ),
        ),
      );
    },
  ),
  GoRoute(
    path: AppRoutePaths.threadInvitation,
    name: AppRouteNames.threadInvitation,
    builder: (context, state) =>
        ThreadInvitationPage(token: state.pathParameters['token']!),
  ),
  GoRoute(
    path: AppRoutePaths.tagThreads,
    name: AppRouteNames.tagThreads,
    builder: (context, state) =>
        TagThreadsPage(tagId: state.pathParameters['tagId']!),
  ),
  GoRoute(
    path: AppRoutePaths.postReplies,
    name: AppRouteNames.postReplies,
    builder: (context, state) => PostRepliesPage(
      threadId: state.pathParameters['threadId']!,
      rootPostId: state.pathParameters['postId']!,
      focusedReplyId: state.uri.queryParameters['post'],
    ),
  ),
  GoRoute(
    path: AppRoutePaths.threadMemberManagement,
    name: AppRouteNames.threadMemberManagement,
    builder: (context, state) => ThreadManagementPage(
      threadId: state.pathParameters['threadId']!,
      initialSection: ThreadManagementSection.members,
    ),
  ),
  GoRoute(
    path: AppRoutePaths.threadTagManagement,
    name: AppRouteNames.threadTagManagement,
    builder: (context, state) => ThreadManagementPage(
      threadId: state.pathParameters['threadId']!,
      openTagEditor: true,
    ),
  ),
  GoRoute(
    path: AppRoutePaths.subthreadCreate,
    name: AppRouteNames.subthreadCreate,
    builder: (context, state) =>
        SubthreadEditorPage(threadId: state.pathParameters['threadId']!),
  ),
  GoRoute(
    path: AppRoutePaths.subthreadEdit,
    name: AppRouteNames.subthreadEdit,
    builder: (context, state) => SubthreadEditorPage(
      threadId: state.pathParameters['threadId']!,
      subthreadId: state.pathParameters['subthreadId']!,
    ),
  ),
  GoRoute(
    path: AppRoutePaths.subthreadManagement,
    name: AppRouteNames.subthreadManagement,
    builder: (context, state) => ThreadManagementPage(
      threadId: state.pathParameters['threadId']!,
      initialSection: ThreadManagementSection.subthreads,
    ),
  ),
  GoRoute(
    path: AppRoutePaths.threadManagement,
    name: AppRouteNames.threadManagement,
    builder: (context, state) =>
        ThreadManagementPage(threadId: state.pathParameters['threadId']!),
  ),
  GoRoute(
    path: AppRoutePaths.threadPostSearch,
    name: AppRouteNames.threadPostSearch,
    builder: (context, state) =>
        ThreadPostSearchPage(threadId: state.pathParameters['threadId']!),
  ),
  GoRoute(
    path: AppRoutePaths.threadDetail,
    name: AppRouteNames.threadDetail,
    pageBuilder: (context, state) {
      final child = ThreadDetailPage(
        threadId: state.pathParameters['threadId']!,
        entryTarget: ThreadDetailEntryTarget.fromQuery(
          postId: state.uri.queryParameters['post'],
          subthreadId: state.uri.queryParameters['subthread'],
        ),
      );
      if (state.extra == WenyouRouteTransitionIntent.instantFallback) {
        return wenyouInstantPage<void>(key: state.pageKey, child: child);
      }
      return wenyouStandardPage<void>(key: state.pageKey, child: child);
    },
  ),
  GoRoute(
    path: AppRoutePaths.composeMoment,
    name: AppRouteNames.composeMoment,
    builder: (context, state) => const MomentComposePage(),
  ),
  GoRoute(
    path: AppRoutePaths.composeThread,
    name: AppRouteNames.composeThread,
    builder: (context, state) => const ThreadComposePage(),
  ),
];
