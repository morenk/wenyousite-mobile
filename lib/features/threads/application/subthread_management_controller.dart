import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/subthread_management_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';

import 'subthread_management_state.dart';
export 'subthread_management_state.dart';

class SubthreadManagementController
    extends StateNotifier<SubthreadManagementState> {
  SubthreadManagementController(
    this._threadId,
    this._repository, {
    String Function()? createRequestId,
    this._reconciler = const WriteReconciler(),
  }) : _createRequestId = createRequestId ?? const Uuid().v4,
       super(const SubthreadManagementState.loading()) {
    load();
  }

  final String _threadId;
  final SubthreadManagementRepository _repository;
  final String Function() _createRequestId;
  final WriteReconciler _reconciler;
  String? _pendingCreateId;
  String? _pendingCreateFingerprint;
  var _loadEpoch = 0;
  var _actionEpoch = 0;

  Future<void> load() async {
    if (state.isBusy) return;
    final epoch = ++_loadEpoch;
    state = const SubthreadManagementState.loading();
    try {
      final bootstrap = await _repository.load(_threadId);
      if (epoch != _loadEpoch) return;
      state = SubthreadManagementState(
        phase: SubthreadManagementPhase.ready,
        bootstrap: bootstrap,
      );
    } on ApiFailure catch (failure) {
      if (epoch != _loadEpoch) return;
      state = SubthreadManagementState(
        phase: SubthreadManagementPhase.failed,
        failure: failure,
      );
    }
  }

  Future<SubthreadManagementItem?> prepareEdit(
    SubthreadManagementItem item,
  ) async {
    if (state.isBusy || item.isDefault) return null;
    state = state.copyWith(
      failure: null,
      pendingAction: SubthreadManagementAction.loadingDetail,
      pendingItemId: item.id,
    );
    try {
      final latest = await _repository.findById(
        threadId: _threadId,
        subthreadId: item.id,
        isDefault: false,
      );
      _replaceItem(latest);
      state = state.copyWith(pendingAction: null, pendingItemId: null);
      return latest;
    } on ApiFailure catch (failure) {
      state = state.copyWith(
        failure: failure,
        pendingAction: null,
        pendingItemId: null,
      );
      return null;
    }
  }

  Future<bool> create(SubthreadManagementDraft draft) async {
    final bootstrap = state.bootstrap;
    if (bootstrap == null || state.isBusy) return false;
    final fingerprint =
        '${draft.normalizedTitle}\u0000${draft.postingPolicy.name}';
    if (_pendingCreateFingerprint != fingerprint || _pendingCreateId == null) {
      _pendingCreateFingerprint = fingerprint;
      _pendingCreateId = _createRequestId();
    }
    state = state.copyWith(
      failure: null,
      pendingAction: SubthreadManagementAction.creating,
      pendingItemId: null,
      actionOutcome: null,
      actionRequestId: null,
    );
    final beforeIds = bootstrap.items.map((item) => item.id).toSet();
    final outcome = await _runMutation<SubthreadManagementItem>(
      write: () => _repository.create(
        threadId: _threadId,
        draft: draft,
        clientRequestId: _pendingCreateId!,
      ),
      targetReached: (latest) => latest.items.any(
        (item) =>
            !beforeIds.contains(item.id) &&
            item.title == draft.normalizedTitle &&
            item.postingPolicy == draft.postingPolicy,
      ),
      failureMessage: '子贴创建失败，请稍后刷新查看。',
    );
    if (outcome.isDiscarded || !mounted) return false;
    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        var created = outcome.writeValue;
        if (outcome.projection == null && created != null) {
          if (bootstrap.items.isEmpty) {
            created = created.copyWith(isDefault: true);
          }
          final items = [...bootstrap.items, created]
            ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
          state = state.copyWith(
            bootstrap: bootstrap.copyWith(items: List.unmodifiable(items)),
            pendingAction: null,
            pendingItemId: null,
            actionOutcome: null,
            actionRequestId: null,
          );
        } else {
          _completeFromProjection(outcome.projection!);
        }
        _pendingCreateId = null;
        _pendingCreateFingerprint = null;
        return true;
      case WriteOutcomeStatus.failed:
        final failure = outcome.failure!;
        if (failure.businessCode == 40912) _pendingCreateId = null;
        _failMutation(failure);
        return false;
      case WriteOutcomeStatus.indeterminate:
        _indeterminateMutation(outcome, bootstrap);
        return false;
      case WriteOutcomeStatus.confirming:
        return false;
    }
  }

  Future<bool> update(
    SubthreadManagementItem current,
    SubthreadManagementDraft draft,
  ) async {
    if (state.isBusy || current.isDefault) return false;
    if (!draft.differsFrom(current)) return true;
    state = state.copyWith(
      failure: null,
      pendingAction: SubthreadManagementAction.updating,
      pendingItemId: current.id,
      actionOutcome: null,
      actionRequestId: null,
    );
    final bootstrap = state.bootstrap!;
    final outcome = await _runMutation<SubthreadManagementItem>(
      write: () => _repository.update(current: current, draft: draft),
      targetReached: (latest) => latest.items.any(
        (item) =>
            item.id == current.id &&
            item.title == draft.normalizedTitle &&
            item.postingPolicy == draft.postingPolicy,
      ),
      failureMessage: '子贴保存失败，请稍后刷新查看。',
    );
    if (outcome.isDiscarded || !mounted) return false;
    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        if (outcome.projection != null) {
          _completeFromProjection(outcome.projection!);
        } else {
          _replaceItem(outcome.writeValue!);
          _completePending();
        }
        return true;
      case WriteOutcomeStatus.failed:
        final failure = outcome.failure!;
        if (failure.businessCode == 40002 || failure.httpStatus == 409) {
          await _reloadAfterConflict(failure);
        } else {
          _failMutation(failure);
        }
        return false;
      case WriteOutcomeStatus.indeterminate:
        _indeterminateMutation(outcome, bootstrap);
        return false;
      case WriteOutcomeStatus.confirming:
        return false;
    }
  }

  Future<bool> remove(SubthreadManagementItem item) async {
    final bootstrap = state.bootstrap;
    if (bootstrap == null || state.isBusy || item.isDefault) return false;
    state = state.copyWith(
      failure: null,
      pendingAction: SubthreadManagementAction.deleting,
      pendingItemId: item.id,
      actionOutcome: null,
      actionRequestId: null,
    );
    final outcome = await _runMutation<void>(
      write: () => _repository.remove(item),
      targetReached: (latest) =>
          !latest.items.any((candidate) => candidate.id == item.id),
      failureMessage: '子贴删除失败，请稍后刷新查看。',
      convergentBusinessCodes: const {40400},
    );
    if (outcome.isDiscarded || !mounted) return false;
    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        if (outcome.projection != null) {
          _completeFromProjection(outcome.projection!);
        } else {
          state = state.copyWith(
            bootstrap: bootstrap.copyWith(
              items: List.unmodifiable(
                bootstrap.items.where((candidate) => candidate.id != item.id),
              ),
            ),
            pendingAction: null,
            pendingItemId: null,
            actionOutcome: null,
            actionRequestId: null,
          );
        }
        return true;
      case WriteOutcomeStatus.failed:
        _failMutation(outcome.failure!);
        return false;
      case WriteOutcomeStatus.indeterminate:
        _indeterminateMutation(outcome, bootstrap);
        return false;
      case WriteOutcomeStatus.confirming:
        return false;
    }
  }

  Future<bool> move(String itemId, int delta) async {
    final bootstrap = state.bootstrap;
    if (bootstrap == null || state.isBusy || delta.abs() != 1) return false;
    final items = [...bootstrap.items];
    final currentIndex = items.indexWhere((item) => item.id == itemId);
    final targetIndex = currentIndex + delta;
    if (currentIndex <= 0 || targetIndex <= 0 || targetIndex >= items.length) {
      return false;
    }
    final moved = items.removeAt(currentIndex);
    items.insert(targetIndex, moved);
    state = state.copyWith(
      failure: null,
      pendingAction: SubthreadManagementAction.reordering,
      pendingItemId: itemId,
      actionOutcome: null,
      actionRequestId: null,
    );
    final desiredIds = items.map((item) => item.id).toList(growable: false);
    final outcome = await _runMutation<List<SubthreadManagementItem>>(
      write: () => _repository.reorder(threadId: _threadId, items: items),
      targetReached: (latest) {
        final latestIds = latest.items.map((item) => item.id).toList();
        if (latestIds.length != desiredIds.length) return false;
        for (var index = 0; index < desiredIds.length; index++) {
          if (latestIds[index] != desiredIds[index]) return false;
        }
        return true;
      },
      failureMessage: '子贴顺序保存失败，请稍后刷新查看。',
    );
    if (outcome.isDiscarded || !mounted) return false;
    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        state = state.copyWith(
          bootstrap:
              outcome.projection ??
              bootstrap.copyWith(items: outcome.writeValue!),
          pendingAction: null,
          pendingItemId: null,
          actionOutcome: null,
          actionRequestId: null,
        );
        return true;
      case WriteOutcomeStatus.failed:
        _failMutation(outcome.failure!);
        return false;
      case WriteOutcomeStatus.indeterminate:
        _indeterminateMutation(outcome, bootstrap);
        return false;
      case WriteOutcomeStatus.confirming:
        return false;
    }
  }

  Future<WriteOutcome<Value, SubthreadManagementBootstrap>>
  _runMutation<Value>({
    required Future<Value> Function() write,
    required bool Function(SubthreadManagementBootstrap latest) targetReached,
    required String failureMessage,
    Set<int> convergentBusinessCodes = const {},
  }) {
    final epoch = ++_actionEpoch;
    return _reconciler.run<Value, SubthreadManagementBootstrap>(
      write: write,
      read: () => _repository.load(_threadId),
      targetReached: targetReached,
      failureMessage: failureMessage,
      convergentBusinessCodes: convergentBusinessCodes,
      isCurrent: () => mounted && epoch == _actionEpoch,
      onProgress: (progress) {
        if (!mounted || epoch != _actionEpoch) return;
        state = state.copyWith(
          actionOutcome: WriteOutcomeStatus.confirming,
          actionRequestId: progress.requestId,
        );
      },
    );
  }

  void _completeFromProjection(SubthreadManagementBootstrap latest) {
    state = state.copyWith(
      bootstrap: latest,
      pendingAction: null,
      pendingItemId: null,
      failure: null,
      actionOutcome: null,
      actionRequestId: null,
    );
  }

  void _completePending() {
    state = state.copyWith(
      pendingAction: null,
      pendingItemId: null,
      failure: null,
      actionOutcome: null,
      actionRequestId: null,
    );
  }

  void _failMutation(ApiFailure failure) {
    state = state.copyWith(
      failure: failure,
      pendingAction: null,
      pendingItemId: null,
      actionOutcome: null,
      actionRequestId: null,
    );
  }

  void _indeterminateMutation(
    WriteOutcome<Object?, SubthreadManagementBootstrap> outcome,
    SubthreadManagementBootstrap fallback,
  ) {
    state = state.copyWith(
      bootstrap: outcome.projection ?? fallback,
      failure: null,
      pendingAction: null,
      pendingItemId: null,
      actionOutcome: WriteOutcomeStatus.indeterminate,
      actionRequestId: outcome.requestId,
    );
  }

  void clearFailure() {
    if (state.isBusy) return;
    state = state.copyWith(
      failure: null,
      actionOutcome: null,
      actionRequestId: null,
    );
  }

  void _replaceItem(SubthreadManagementItem replacement) {
    final bootstrap = state.bootstrap;
    if (bootstrap == null) return;
    final items =
        bootstrap.items
            .map((item) => item.id == replacement.id ? replacement : item)
            .toList()
          ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    state = state.copyWith(
      bootstrap: bootstrap.copyWith(items: List.unmodifiable(items)),
    );
  }

  Future<void> _reloadAfterConflict(ApiFailure conflict) async {
    try {
      final latest = await _repository.load(_threadId);
      state = state.copyWith(
        bootstrap: latest,
        failure: conflict,
        pendingAction: null,
        pendingItemId: null,
        actionOutcome: null,
        actionRequestId: null,
      );
    } on ApiFailure catch (reloadFailure) {
      state = state.copyWith(
        failure: reloadFailure,
        pendingAction: null,
        pendingItemId: null,
        actionOutcome: null,
        actionRequestId: null,
      );
    }
  }
}

final subthreadManagementControllerProvider = StateNotifierProvider.autoDispose
    .family<SubthreadManagementController, SubthreadManagementState, String>((
      ref,
      threadId,
    ) {
      return SubthreadManagementController(
        threadId,
        ref.watch(subthreadManagementRepositoryProvider),
      );
    }, dependencies: [subthreadManagementRepositoryProvider]);
