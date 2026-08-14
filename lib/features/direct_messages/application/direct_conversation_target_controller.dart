part of 'direct_message_controllers.dart';

class DirectConversationTargetController
    extends StateNotifier<DirectConversationTargetState> {
  DirectConversationTargetController(
    this._userId,
    this._repository,
    this._userRepository, {
    bool autoStart = true,
    DirectMessageRequestIdFactory? requestIdFactory,
  }) : _requestIdFactory = requestIdFactory ?? const Uuid().v4,
       super(const DirectConversationTargetState.loading()) {
    if (autoStart) unawaited(load());
  }

  final String _userId;
  final DirectMessageRepository _repository;
  final PublicUserRepository _userRepository;
  final DirectMessageRequestIdFactory _requestIdFactory;
  var _epoch = 0;

  Future<void> load() async {
    final epoch = ++_epoch;
    state = const DirectConversationTargetState.loading();
    try {
      final results = await Future.wait<Object>([
        _repository.findByUser(_userId),
        _userRepository.fetchUser(_userId),
      ]);
      if (!mounted || epoch != _epoch) return;
      final lookup = results[0] as DirectConversationLookup;
      final profile = results[1] as PublicUserProfileModel;
      if (profile.id != _userId) {
        throw const ApiFailure(userMessage: '服务端返回了不匹配的用户资料，请重新打开。');
      }
      state = DirectConversationTargetState(
        phase: DirectConversationTargetPhase.ready,
        user: DirectMessageUser(
          id: profile.id,
          username: profile.username,
          avatarUrl: profile.avatarUrl,
          isDeactivated: profile.isDeactivated,
        ),
        lookup: lookup,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = DirectConversationTargetState(
        phase: DirectConversationTargetPhase.failed,
        failure: _asFailure(error, '私聊对象没有加载完成。'),
      );
    }
  }

  Future<DirectConversationStart?> start({
    String? content,
    String? mediaId,
    String? stickerAssetId,
  }) async {
    final user = state.user;
    final lookup = state.lookup;
    if (state.phase != DirectConversationTargetPhase.ready ||
        state.isSending ||
        user == null ||
        user.isDeactivated ||
        lookup == null ||
        !lookup.canInitiate) {
      return null;
    }
    final previous = state.failedDraft;
    final requestId =
        previous?.samePayload(
              content: content,
              mediaId: mediaId,
              stickerAssetId: stickerAssetId,
            ) ??
            false
        ? previous!.clientRequestId
        : _requestIdFactory();
    late final DirectMessageDraft draft;
    try {
      draft = DirectMessageDraft.normalized(
        clientRequestId: requestId,
        content: content,
        mediaId: mediaId,
        stickerAssetId: stickerAssetId,
      );
    } on Object catch (error) {
      state = state.copyWith(failure: _asFailure(error, '消息内容不符合要求。'));
      return null;
    }
    final before = state;
    state = before.copyWith(isSending: true, failure: null);
    try {
      final result = await _repository.createConversation(
        recipientId: _userId,
        draft: draft,
      );
      if (!mounted) return null;
      state = before.copyWith(
        lookup: DirectConversationLookup(
          contactState:
              result.conversation.status == DirectConversationStatus.accepted
              ? DirectContactState.accepted
              : DirectContactState.pending,
          canInitiate: false,
          conversation: result.conversation,
        ),
        isSending: false,
        failure: null,
        failedDraft: null,
      );
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      state = before.copyWith(
        isSending: false,
        failure: _asFailure(error, '首条消息发送失败，请使用原请求重试。'),
        failedDraft: draft,
      );
      return null;
    }
  }

  Future<DirectConversationStart?> retryStart() {
    final draft = state.failedDraft;
    if (draft == null) return Future.value();
    return start(
      content: draft.content,
      mediaId: draft.mediaId,
      stickerAssetId: draft.stickerAssetId,
    );
  }

  void abandonFailedDraft() {
    if (state.isSending || state.failedDraft == null) return;
    state = state.copyWith(failedDraft: null, failure: null);
  }
}

final directConversationTargetControllerProvider = StateNotifierProvider
    .autoDispose
    .family<
      DirectConversationTargetController,
      DirectConversationTargetState,
      String
    >(
      (ref, userId) {
        return DirectConversationTargetController(
          userId,
          ref.watch(directMessageRepositoryProvider),
          ref.watch(publicUserRepositoryProvider),
        );
      },
      dependencies: [
        directMessageRepositoryProvider,
        publicUserRepositoryProvider,
      ],
    );

ApiFailure _asFailure(Object error, String fallback) {
  return mapApplicationFailure(error, fallback);
}
