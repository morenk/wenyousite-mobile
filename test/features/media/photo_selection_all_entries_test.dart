import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_unread_controller.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/photo_selection_page.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/posts/data/post_discussion_author_repository.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_launcher.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/stickers/data/sticker_repository.dart';
import 'package:wenyousite_mobile/features/thread_identity/data/thread_identity_repository.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';

import '../../support/deterministic_test_fonts.dart';
import '../direct_messages/direct_conversation_page_fixtures.dart';
import '../editor/thread_compose_page_fixtures.dart';
import '../moments/moment_pages_content_media_fixtures.dart';
import '../moments/moment_pages_session_wallet_fixtures.dart';
import '../posts/post_replies_page_discussion_fixtures.dart';
import '../threads/thread_detail_page_test_support.dart';
import '../users/me_page_test_support.dart';
import 'photo_selection_app_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadDeterministicTestFonts);
  const photos = MethodChannel('com.fluttercandies/photo_manager');
  final permissionRequests = <MethodCall>[];
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    permissionRequests.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(photos, (call) async {
          if (call.method != 'requestPermissionExtend') {
            throw StateError('Unexpected photo method: ${call.method}');
          }
          permissionRequests.add(call);
          return 1;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(photos, null),
  );

  for (final entry in _entries) {
    testWidgets(
      '生产全入口矩阵：${entry.name}',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final posts = _Posts();
        final fixture = PhotoEntryAppFixture(
          stickers: true,
          profiles: MePageTestFakeMeProfileRepository(
            initialProfile: entry.name == '已有头像二级更换'
                ? mePageTestProfileWithAvatar(
                    'https://cdn.example.com/avatar.webp',
                  )
                : entry.name == '已有背景二级更换'
                ? mePageTestProfileWithCover()
                : mePageTestProfile,
          ),
          overrides: [
            apiMomentRepositoryProvider.overrideWithValue(
              MomentPagesTestPageRepository(
                detail: momentPagesTestEditableDetail(
                  title: '编辑动态',
                  version: 1,
                ),
              ),
            ),
            apiDirectMessageRepositoryProvider.overrideWithValue(
              DirectConversationPageTestFakeRepository(),
            ),
            directMessagesEnabledProvider.overrideWithValue(true),
            apiStickerRepositoryProvider.overrideWithValue(
              ThreadComposePageTestComposeStickerRepository(),
            ),
            apiThreadIdentityRepositoryProvider.overrideWithValue(_Roles()),
            apiThreadDetailRepositoryProvider.overrideWithValue(
              ThreadDetailPageTestFakeThreadDetailRepository(
                detail: threadDetailPageTestCopyThreadDetail(
                  threadDetailPageTestManagerDetail,
                  subthreads: threadDetailPageTestManagerDetail.subthreads,
                  currentUserId: 'user-1',
                  isCurrentUserOwner: true,
                ),
              ),
            ),
            apiThreadSubscriptionRepositoryProvider.overrideWithValue(
              ThreadDetailPageTestFakeThreadSubscriptionRepository(),
            ),
            apiThreadInteractionRepositoryProvider.overrideWithValue(
              ThreadDetailPageTestFakeThreadInteractionRepository(),
            ),
            apiPostDiscussionAuthorDirectoryProvider.overrideWithValue(
              ThreadDetailPageTestFakePostDiscussionAuthorDirectory(),
            ),
            apiPostRepositoryProvider.overrideWithValue(posts),
          ],
        );
        addTearDown(fixture.dispose);
        await fixture.pump(tester, entry.location);
        await photoEntryKeyboardTarget(tester, 0);
        if (entry.open != null) await entry.open!(tester, fixture);
        await tester.pumpAndSettle();
        expect(permissionRequests, isEmpty, reason: '进入页面／二级表单不请求照片权限');
        await tester.ensureVisible(entry.button());
        await tester.tap(entry.button());
        await tester.pumpAndSettle();
        expect(
          find.byType(PhotoSelectionPage),
          findsOneWidget,
          reason: find
              .byType(Text)
              .evaluate()
              .map((element) => (element.widget as Text).data)
              .whereType<String>()
              .join(' | '),
        );
        expect(permissionRequests, hasLength(1));
        final (purpose, limit) = switch (entry.name) {
          '动态新建' || '动态编辑' => (MediaUploadPurpose.moment, 9),
          '动态评论' => (MediaUploadPurpose.momentComment, 1),
          '私聊图片' => (MediaUploadPurpose.directMessage, 1),
          '收藏表情相册上传' => (MediaUploadPurpose.stickerSource, 1),
          '添加头像' ||
          '已有头像二级更换' ||
          '帖内身份新建头像表单' ||
          '帖内身份编辑头像表单' => (MediaUploadPurpose.avatar, 1),
          '添加主页背景' || '已有背景二级更换' => (MediaUploadPurpose.profileCover, 1),
          _ => (MediaUploadPurpose.richContent, 1),
        };
        final request = tester
            .widget<PhotoSelectionPage>(find.byType(PhotoSelectionPage))
            .request;
        expect(request.purpose, purpose);
        expect(request.limit, limit);
        expect(
          (permissionRequests.single.arguments as Map)['androidPermission'],
          {'type': 1, 'mediaLocation': false},
        );
        await tester.tap(find.byTooltip('取消选择'));
        await tester.pumpAndSettle();
        expect(find.byType(PhotoSelectionPage), findsNothing);
        fixture.expectNoWrites();
        expect(posts.replySource.createInputs, isEmpty);
        expect(posts.replySource.updateRequests, isEmpty);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        fixture.dispose();
        await tester.pumpAndSettle();
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }
}

typedef _Entry = ({
  String name,
  String location,
  Future<void> Function(WidgetTester, PhotoEntryAppFixture)? open,
  Finder Function() button,
});
Finder _key(String key) => find.byKey(Key(key));
Finder _image() => find.byTooltip('图片');
final _entries = <_Entry>[
  (name: '主题新建正文', location: '/compose/thread', open: null, button: _image),
  (
    name: '主题已有正文编辑',
    location: '/threads/thread-1',
    open: (tester, _) async {
      await tester.tap(_key('thread-detail-more'));
      await tester.pumpAndSettle();
      await tester.tap(_key('thread-detail-edit-body'));
    },
    button: _image,
  ),
  (
    name: '新发楼层',
    location: '/threads/thread-1',
    open: (tester, _) async {
      await tester.tap(_key('thread-floor-compose'));
    },
    button: _image,
  ),
  (
    name: '新发楼中楼回复',
    location: '/threads/thread/posts/root/replies',
    open: (tester, _) async {
      await tester.tap(_key('post-reply-compose'));
    },
    button: _image,
  ),
  (
    name: '动态新建',
    location: '/compose/moment',
    open: null,
    button: () => _key('moment-compose-add-image'),
  ),
  (
    name: '动态编辑',
    location: '/moments/moment-1/edit',
    open: null,
    button: () => _key('moment-compose-add-image'),
  ),
  (
    name: '动态评论',
    location: '/moments/moment-1',
    open: (tester, _) async {
      await tester.tap(_key('moment-comment-dock'));
    },
    button: () => _key('moment-comment-image'),
  ),
  (
    name: '私聊图片',
    location: '/messages/conversation-1',
    open: null,
    button: () => _key('direct-message-composer-image'),
  ),
  (
    name: '收藏表情相册上传',
    location: '/me/stickers',
    open: null,
    button: () => _key('stickers-add-gallery'),
  ),
  (
    name: '添加头像',
    location: '/me/edit',
    open: null,
    button: () => _key('me-avatar-change'),
  ),
  (
    name: '已有头像二级更换',
    location: '/me/edit',
    open: (tester, _) async {
      await tester.tap(_key('me-avatar-change'));
    },
    button: () => _key('me-avatar-sheet-change'),
  ),
  (
    name: '添加主页背景',
    location: '/me/edit',
    open: null,
    button: () => _key('me-profile-cover-change'),
  ),
  (
    name: '已有背景二级更换',
    location: '/me/edit',
    open: (tester, _) async {
      await tester.tap(_key('me-profile-cover-change'));
    },
    button: () => _key('me-profile-cover-sheet-change'),
  ),
  for (final editing in [false, true])
    (
      name: '帖内身份${editing ? '编辑' : '新建'}头像表单',
      location: '/',
      open: (tester, fixture) async {
        // 真实应用宿主和生产端口；这里直接挂载共享表单，不覆盖身份菜单的导航／授权。
        unawaited(
          showThreadIdentityEditor(
            fixture.routeContext,
            'thread',
            identityId: editing ? 'role' : null,
          ),
        );
      },
      button: () => _key('thread-identity-pick-avatar'),
    ),
  for (final sample in [
    (
      name: '正文新建共享表单',
      kind: PostComposerKind.upsertBody,
      postId: null,
      parent: null,
    ),
    (
      name: '楼层编辑共享表单',
      kind: PostComposerKind.editPost,
      postId: 'root',
      parent: null,
    ),
    (
      name: '回复编辑共享表单',
      kind: PostComposerKind.editPost,
      postId: 'reply-own',
      parent: 'root',
    ),
  ])
    (
      name: sample.name,
      location: '/',
      open: (tester, fixture) async {
        // 补足共享编辑器模式；菜单入口另由既有页面／权限回归覆盖。
        unawaited(
          showPostComposerSheet(
            context: fixture.routeContext,
            target: (
              kind: sample.kind,
              threadId: 'thread',
              subthreadId: 'subthread',
              postId: sample.postId,
              parentPostId: sample.parent,
              replyToPostId: null,
              version: sample.postId == 'root' ? 2 : 1,
              initialContent: '',
              label: sample.name,
            ),
          ),
        );
      },
      button: _image,
    ),
];

class _Posts extends ThreadDetailPageTestFakePostRepository {
  final replySource = PostRepliesPageTestFakePostRepository();
  @override
  Future<PostItem> fetchPost(String postId) =>
      postId == 'root' || postId.startsWith('reply-')
      ? replySource.fetchPost(postId)
      : super.fetchPost(postId);
  @override
  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) => replySource.fetchReplies(
    rootPostId: rootPostId,
    cursor: cursor,
    limit: limit,
    order: order,
    authorId: authorId,
  );
}

class _Roles extends Fake implements ThreadIdentityRepository {
  final account = const ThreadIdentityState(
    threadId: 'thread',
    userId: 'user-1',
    enabled: true,
    eligible: true,
    canEdit: true,
    accountName: '测试账号',
  );
  final role = const ThreadIdentityState(
    threadId: 'thread',
    userId: 'user-1',
    enabled: true,
    eligible: true,
    canEdit: true,
    accountName: '测试账号',
    identityId: 'role',
    nickname: '角色',
    version: 1,
  );
  @override
  Future<ThreadIdentityCollection> list(String threadId) async =>
      ThreadIdentityCollection(account: account, identities: [role]);
  @override
  Future<ThreadIdentityState> find(String threadId, String identityId) async =>
      role;
}
