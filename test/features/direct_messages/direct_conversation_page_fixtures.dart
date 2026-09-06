import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_repository.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_conversation_page.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/reports/application/report_repository_ports.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';

List<Override> directConversationPageTestOverrides(
  DirectConversationPageTestFakeRepository repository, {
  MediaUploadGateway? mediaUploadGateway,
  bool stickersEnabled = false,
}) {
  return [
    directMessagesEnabledProvider.overrideWithValue(true),
    stickersEnabledProvider.overrideWithValue(stickersEnabled),
    directMessageRepositoryProvider.overrideWithValue(repository),
    directConversationControllerProvider.overrideWith((ref, conversationId) {
      return DirectConversationController(
        conversationId,
        repository,
        mediaUploadGateway: mediaUploadGateway,
        pollInterval: Duration.zero,
      );
    }),
    directUnreadControllerProvider.overrideWith((ref) {
      return DirectUnreadController(repository, autoStart: false);
    }),
  ];
}

GoRouter directConversationPageTestRouter() {
  return GoRouter(
    initialLocation: '/messages/conversation-1',
    routes: [
      GoRoute(
        path: '/messages/:conversationId',
        builder: (_, state) => Consumer(
          builder: (_, ref, _) => DirectConversationPage(
            conversationId: state.pathParameters['conversationId']!,
            onReportMessage: (reportContext, messageId) => showWenyouReportFlow(
              context: reportContext,
              ref: ref,
              target: ReportTarget.directMessage(messageId),
              targetLabel: '这条私信',
              returnTo: '/messages/${state.pathParameters['conversationId']!}',
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/users/:userId',
        name: 'user-profile',
        builder: (_, state) =>
            Scaffold(body: Text('用户=${state.pathParameters['userId']}')),
      ),
      GoRoute(
        path: '/join/:token',
        builder: (_, state) =>
            Scaffold(body: Text('邀请=${state.pathParameters['token']}')),
      ),
    ],
  );
}

class DirectConversationPageTestFakeRepository
    implements DirectMessageRepository {
  DirectConversationPageTestFakeRepository({
    DirectConversation? conversation,
    List<DirectMessage>? messages,
    this.failSendOnce = false,
  }) : conversation =
           conversation ?? directConversationPageTestAcceptedConversation(),
       messages = messages ?? [directConversationPageTestIncomingTextMessage()];

  DirectConversation conversation;
  final List<DirectMessage> messages;
  final List<DirectMessage> pendingAfterMessages = [];
  bool failSendOnce;
  final List<DirectMessageDraft> sentDrafts = [];
  final List<String> recalledIds = [];
  final List<bool> archiveValues = [];
  final List<bool> requestActions = [];

  @override
  Future<DirectConversation> fetchConversation(String conversationId) async {
    return conversation;
  }

  @override
  Future<CursorPage<DirectMessage>> fetchMessages({
    required String conversationId,
    String? cursor,
    String? after,
    int limit = 30,
  }) async {
    if (after != null) {
      final pending = List<DirectMessage>.of(pendingAfterMessages);
      pendingAfterMessages.clear();
      return CursorPage(items: pending, hasMore: false);
    }
    return CursorPage(items: List.unmodifiable(messages), hasMore: false);
  }

  @override
  Future<DirectMessage> sendMessage({
    required String conversationId,
    required DirectMessageDraft draft,
  }) async {
    sentDrafts.add(draft);
    if (failSendOnce) {
      failSendOnce = false;
      throw const ApiFailure(userMessage: '网络暂时不可用。');
    }
    final message = DirectMessage(
      id: 'sent-1',
      conversationId: conversationId,
      senderId: 'user-1',
      recipientId: 'user-2',
      content: draft.content,
      createdAt: DateTime.now(),
    );
    messages.add(message);
    return message;
  }

  @override
  Future<DirectConversation> handleRequest({
    required String conversationId,
    required bool accept,
  }) async {
    requestActions.add(accept);
    conversation = accept
        ? directConversationPageTestAcceptedConversation()
        : directConversationPageTestDeclinedConversation();
    if (!accept) messages.clear();
    return conversation;
  }

  @override
  Future<DirectConversation> setArchived({
    required String conversationId,
    required bool archived,
  }) async {
    archiveValues.add(archived);
    conversation = conversation.copyWith(
      archivedAt: archived ? DateTime.now() : null,
    );
    return conversation;
  }

  @override
  Future<DirectRecallResult> recall(String messageId) async {
    recalledIds.add(messageId);
    return const DirectRecallResult(conversationCanceled: false);
  }

  @override
  Future<DirectUnreadCounts> fetchUnreadCounts() async {
    return const DirectUnreadCounts(unreadMessages: 0, pendingRequests: 0);
  }

  @override
  Future<void> markRead({
    required String conversationId,
    required String throughMessageId,
  }) async {}

  @override
  Future<CursorPage<DirectConversation>> fetchConversations({
    required DirectConversationView view,
    String? cursor,
    int limit = 20,
  }) => throw UnimplementedError();

  @override
  Future<DirectConversationLookup> findByUser(String userId) =>
      throw UnimplementedError();

  @override
  Future<DirectConversationStart> createConversation({
    required String recipientId,
    required DirectMessageDraft draft,
  }) => throw UnimplementedError();
}

class DirectConversationPageTestFakeReportRepository
    implements ReportRepository {
  final inputs = <ReportInput>[];

  @override
  Future<ReportResult> create(ReportInput input) async {
    inputs.add(input);
    return ReportResult(
      id: 'report-${inputs.length}',
      target: input.target,
      reason: input.reason,
      createdAt: DateTime.utc(2026, 8, 21),
    );
  }
}

class DirectConversationPageTestMemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class DirectConversationPageTestFakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw UnimplementedError();
}

SessionTokens directConversationPageTestTokens(String userId) {
  final payload = base64Url
      .encode(utf8.encode('{"sub":"$userId"}'))
      .replaceAll('=', '');
  return SessionTokens(
    accessToken: 'header.$payload.signature',
    refreshToken: 'refresh-token',
  );
}

class DirectConversationPageTestFakeImagePicker implements EditorImagePicker {
  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    return MediaUploadInput(
      filename: 'draft.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ),
      ),
    );
  }
}

class DirectConversationPageTestFailingMediaUploadGateway
    implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: 1,
        totalBytes: input.bytes.length,
      ),
    );
    return DirectConversationPageTestTestMediaUploadOperation(
      Future.error(const ApiFailure(userMessage: '图片上传失败。')),
    );
  }
}

class DirectConversationPageTestRetryingMediaUploadGateway
    implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    if (inputs.length == 1) {
      return DirectConversationPageTestTestMediaUploadOperation(
        Future.error(const ApiFailure(userMessage: '请稍后重试上传。')),
      );
    }
    return DirectConversationPageTestTestMediaUploadOperation(
      Future.value(
        const UploadedEditorImage(
          mediaId: 'media-retried',
          url: 'https://wenyou.site/media/retried.png',
        ),
      ),
    );
  }
}

class DirectConversationPageTestBlockingMediaUploadGateway
    implements MediaUploadGateway {
  final operation = DirectConversationPageTestBlockingMediaUploadOperation();
  var started = false;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    started = true;
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length ~/ 2,
        totalBytes: input.bytes.length,
      ),
    );
    return operation;
  }
}

class DirectConversationPageTestBlockingMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  final Completer<UploadedEditorImage> directConversationPageTestResult =
      Completer<UploadedEditorImage>();
  var cancelled = false;

  @override
  Future<UploadedEditorImage> get result =>
      directConversationPageTestResult.future;

  @override
  void cancel() => cancelled = true;
}

class DirectConversationPageTestTestMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  DirectConversationPageTestTestMediaUploadOperation(this.result);

  @override
  final Future<UploadedEditorImage> result;

  @override
  void cancel() {}
}

DirectMessageUser directConversationPageTestUser() {
  return const DirectMessageUser(
    id: 'user-2',
    username: '小油',
    isDeactivated: false,
  );
}

DirectConversation directConversationPageTestAcceptedConversation() {
  return DirectConversation(
    id: 'conversation-1',
    status: DirectConversationStatus.accepted,
    requestDirection: DirectRequestDirection.none,
    otherUser: directConversationPageTestUser(),
    unreadCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    canSend: true,
    canAccept: false,
    canDecline: false,
    isBlocked: false,
  );
}

DirectConversation directConversationPageTestIncomingRequest() {
  return DirectConversation(
    id: 'conversation-1',
    status: DirectConversationStatus.pending,
    requestDirection: DirectRequestDirection.incoming,
    otherUser: directConversationPageTestUser(),
    unreadCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    canSend: false,
    canAccept: true,
    canDecline: true,
    isBlocked: false,
  );
}

DirectConversation directConversationPageTestDeclinedConversation() {
  return DirectConversation(
    id: 'conversation-1',
    status: DirectConversationStatus.declined,
    requestDirection: DirectRequestDirection.none,
    otherUser: directConversationPageTestUser(),
    unreadCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    canSend: false,
    canAccept: false,
    canDecline: false,
    isBlocked: false,
  );
}

DirectMessage directConversationPageTestIncomingTextMessage() {
  return DirectMessage(
    id: 'incoming-1',
    conversationId: 'conversation-1',
    senderId: 'user-2',
    recipientId: 'user-1',
    content: '你好',
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
  );
}

void directConversationPageTestReplaceAtomicEditor(
  WidgetTester tester,
  Key key,
  String value,
) {
  final editor = tester.widget<QuillEditor>(find.byKey(key));
  final length = editor.controller.document.length - 1;
  editor.controller.replaceText(
    0,
    length,
    value,
    TextSelection.collapsed(offset: value.length),
  );
  editor.focusNode.requestFocus();
}

String directConversationPageTestAtomicEditorPlainText(
  WidgetTester tester,
  Key key,
) {
  final editor = tester.widget<QuillEditor>(find.byKey(key));
  return editor.controller.document.toPlainText().trimRight();
}

DirectMessage directConversationPageTestTextMessage({
  required String id,
  required String senderId,
  required String content,
  required DateTime createdAt,
}) {
  return DirectMessage(
    id: id,
    conversationId: 'conversation-1',
    senderId: senderId,
    recipientId: senderId == 'user-2' ? 'user-1' : 'user-2',
    content: content,
    createdAt: createdAt,
  );
}

DirectMessage directConversationPageTestIncomingImageMessage() {
  return DirectMessage(
    id: 'incoming-image',
    conversationId: 'conversation-1',
    senderId: 'user-2',
    recipientId: 'user-1',
    media: const DirectMessageMedia(
      id: 'media-1',
      url: 'https://cdn.wenyou.site/private-image.png',
      isSticker: false,
    ),
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
  );
}

DirectMessage directConversationPageTestOutgoingImageMessage() {
  return DirectMessage(
    id: 'outgoing-image',
    conversationId: 'conversation-1',
    senderId: 'user-1',
    recipientId: 'user-2',
    media: const DirectMessageMedia(
      id: 'media-outgoing',
      url: 'https://cdn.wenyou.site/outgoing-image.png',
      width: 800,
      height: 1169,
      isSticker: false,
    ),
    createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
  );
}
