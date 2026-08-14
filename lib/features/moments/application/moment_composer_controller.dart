part of 'moment_controllers.dart';

enum MomentComposerPhase { loading, editing, submitting, succeeded, failed }

class MomentComposerState {
  const MomentComposerState({
    this.phase = MomentComposerPhase.loading,
    this.initialDetail,
    this.savedDetail,
    this.failure,
  });

  final MomentComposerPhase phase;
  final MomentDetail? initialDetail;
  final MomentDetail? savedDetail;
  final ApiFailure? failure;

  bool get isSubmitting => phase == MomentComposerPhase.submitting;
}

class MomentComposerController extends StateNotifier<MomentComposerState> {
  MomentComposerController(
    this._repository, {
    this.momentId,
    bool autoStart = true,
    MomentRequestIdFactory? requestIdFactory,
  }) : _requestIdFactory = requestIdFactory ?? const Uuid().v4,
       _createRequestId = (requestIdFactory ?? const Uuid().v4)(),
       super(
         MomentComposerState(
           phase: momentId == null
               ? MomentComposerPhase.editing
               : MomentComposerPhase.loading,
         ),
       ) {
    if (momentId != null && autoStart) unawaited(load());
  }

  final MomentRepository _repository;
  final String? momentId;
  final MomentRequestIdFactory _requestIdFactory;
  String _createRequestId;

  Future<void> load() async {
    final id = momentId;
    if (id == null) return;
    state = const MomentComposerState(phase: MomentComposerPhase.loading);
    try {
      final detail = await _repository.fetchDetail(id);
      if (!mounted) return;
      if (!detail.canEdit) {
        state = const MomentComposerState(
          phase: MomentComposerPhase.failed,
          failure: ApiFailure(userMessage: '当前账号不能编辑这条动态。'),
        );
        return;
      }
      state = MomentComposerState(
        phase: MomentComposerPhase.editing,
        initialDetail: detail,
      );
    } on Object catch (error) {
      if (!mounted) return;
      state = MomentComposerState(
        phase: MomentComposerPhase.failed,
        failure: _asFailure(error, '动态没有加载完成，请稍后重试。'),
      );
    }
  }

  Future<MomentDetail?> submit(MomentDraftInput input) async {
    if (state.isSubmitting) return null;
    state = MomentComposerState(
      phase: MomentComposerPhase.submitting,
      initialDetail: state.initialDetail,
    );
    try {
      final id = momentId;
      final saved = id == null
          ? await _repository.create(input, clientRequestId: _createRequestId)
          : await _repository.update(
              id,
              input,
              version: state.initialDetail!.version,
            );
      if (!mounted) return null;
      if (id == null) _createRequestId = _requestIdFactory();
      state = MomentComposerState(
        phase: MomentComposerPhase.succeeded,
        initialDetail: saved,
        savedDetail: saved,
      );
      return saved;
    } on Object catch (error) {
      if (!mounted) return null;
      state = MomentComposerState(
        phase: MomentComposerPhase.editing,
        initialDetail: state.initialDetail,
        failure: _asFailure(
          error,
          momentId == null ? '动态没有发布成功，请使用原内容重试。' : '动态没有保存成功，请重试。',
        ),
      );
      return null;
    }
  }

  Future<bool> remove() async {
    final id = momentId;
    if (id == null || state.isSubmitting) return false;
    final initial = state.initialDetail;
    state = MomentComposerState(
      phase: MomentComposerPhase.submitting,
      initialDetail: initial,
    );
    try {
      await _repository.remove(id);
      if (!mounted) return false;
      state = MomentComposerState(
        phase: MomentComposerPhase.succeeded,
        initialDetail: initial,
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = MomentComposerState(
        phase: MomentComposerPhase.editing,
        initialDetail: initial,
        failure: _asFailure(error, '动态没有删除成功，请重试。'),
      );
      return false;
    }
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final momentComposerControllerProvider = StateNotifierProvider.autoDispose
    .family<MomentComposerController, MomentComposerState, String?>(
      (ref, momentId) => MomentComposerController(
        ref.watch(momentRepositoryProvider),
        momentId: momentId,
      ),
      dependencies: [momentRepositoryProvider],
    );
