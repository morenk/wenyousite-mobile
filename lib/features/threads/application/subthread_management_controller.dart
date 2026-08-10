import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/subthread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';

import 'subthread_management_state.dart';
export 'subthread_management_state.dart';

class SubthreadManagementController
    extends StateNotifier<SubthreadManagementState> {
  SubthreadManagementController(
    this._threadId,
    this._repository, {
    String Function()? createRequestId,
  }) : _createRequestId = createRequestId ?? const Uuid().v4,
       super(const SubthreadManagementState.loading()) {
    load();
  }

  final String _threadId;
  final SubthreadManagementRepository _repository;
  final String Function() _createRequestId;
  String? _pendingCreateId;
  String? _pendingCreateFingerprint;
  var _loadEpoch = 0;

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
    );
    try {
      var created = await _repository.create(
        threadId: _threadId,
        draft: draft,
        clientRequestId: _pendingCreateId!,
      );
      if (bootstrap.items.isEmpty) created = created.copyWith(isDefault: true);
      final items = [...bootstrap.items, created]
        ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
      _pendingCreateId = null;
      _pendingCreateFingerprint = null;
      state = state.copyWith(
        bootstrap: bootstrap.copyWith(items: List.unmodifiable(items)),
        pendingAction: null,
        pendingItemId: null,
      );
      return true;
    } on ApiFailure catch (failure) {
      if (failure.businessCode == 40912) {
        _pendingCreateId = null;
      }
      state = state.copyWith(
        failure: failure,
        pendingAction: null,
        pendingItemId: null,
      );
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
    );
    try {
      final updated = await _repository.update(current: current, draft: draft);
      _replaceItem(updated);
      state = state.copyWith(pendingAction: null, pendingItemId: null);
      return true;
    } on ApiFailure catch (failure) {
      if (failure.businessCode == 40002 || failure.httpStatus == 409) {
        await _reloadAfterConflict(failure);
      } else {
        state = state.copyWith(
          failure: failure,
          pendingAction: null,
          pendingItemId: null,
        );
      }
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
    );
    try {
      await _repository.remove(item);
      state = state.copyWith(
        bootstrap: bootstrap.copyWith(
          items: List.unmodifiable(
            bootstrap.items.where((candidate) => candidate.id != item.id),
          ),
        ),
        pendingAction: null,
        pendingItemId: null,
      );
      return true;
    } on ApiFailure catch (failure) {
      state = state.copyWith(
        failure: failure,
        pendingAction: null,
        pendingItemId: null,
      );
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
    );
    try {
      final reordered = await _repository.reorder(
        threadId: _threadId,
        items: items,
      );
      state = state.copyWith(
        bootstrap: bootstrap.copyWith(items: reordered),
        pendingAction: null,
        pendingItemId: null,
      );
      return true;
    } on ApiFailure catch (failure) {
      state = state.copyWith(
        failure: failure,
        pendingAction: null,
        pendingItemId: null,
      );
      return false;
    }
  }

  void clearFailure() {
    if (state.isBusy) return;
    state = state.copyWith(failure: null);
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
      );
    } on ApiFailure catch (reloadFailure) {
      state = state.copyWith(
        failure: reloadFailure,
        pendingAction: null,
        pendingItemId: null,
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
    });
