import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

typedef ThreadTargetFilterRestore =
    Future<void> Function(String authorId, String subthreadId);

enum ThreadDetailEntryTargetKind { none, post, subthread }

@immutable
class ThreadDetailEntryTarget {
  const ThreadDetailEntryTarget.none()
    : kind = ThreadDetailEntryTargetKind.none,
      id = null;

  const ThreadDetailEntryTarget.post(String postId)
    : kind = ThreadDetailEntryTargetKind.post,
      id = postId;

  const ThreadDetailEntryTarget.subthread(String subthreadId)
    : kind = ThreadDetailEntryTargetKind.subthread,
      id = subthreadId;

  factory ThreadDetailEntryTarget.fromQuery({
    String? postId,
    String? subthreadId,
  }) {
    if (postId != null) return ThreadDetailEntryTarget.post(postId);
    if (subthreadId != null) {
      return ThreadDetailEntryTarget.subthread(subthreadId);
    }
    return const ThreadDetailEntryTarget.none();
  }

  final ThreadDetailEntryTargetKind kind;
  final String? id;

  String? get postId => kind == ThreadDetailEntryTargetKind.post ? id : null;

  String? get subthreadId =>
      kind == ThreadDetailEntryTargetKind.subthread ? id : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThreadDetailEntryTarget && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);
}

@immutable
class ThreadDetailEntrySelection {
  const ThreadDetailEntrySelection({
    required this.subthreadId,
    required this.generation,
  });

  final String subthreadId;
  final int generation;
}

/// Owns the one-shot relationship between a route coordinate and page state.
/// User selection cancels an unresolved coordinate until the route, session,
/// or an explicit retry arms it again.
class ThreadDetailEntryTargetCoordinator {
  String? _threadId;
  ThreadDetailEntryTarget? _target;
  Object? _sessionScope;
  var _generation = 0;
  var _consumed = false;
  var _cancelledByUser = false;

  void synchronize({
    required String threadId,
    required ThreadDetailEntryTarget target,
    required Object sessionScope,
  }) {
    if (_threadId == threadId &&
        _target == target &&
        _sessionScope == sessionScope) {
      return;
    }
    _threadId = threadId;
    _target = target;
    _sessionScope = sessionScope;
    _rearm();
  }

  void cancelForUserSelection() {
    _cancelledByUser = true;
    _generation += 1;
  }

  void rearmForRetry() => _rearm();

  bool isCurrent(int generation) =>
      generation == _generation && !_cancelledByUser;

  bool get allowsTargetEffects => !_cancelledByUser;

  ThreadDetailEntrySelection? resolve({
    required ThreadDetailState state,
    required ThreadPostTargetModel? postTarget,
  }) {
    final target = _target;
    if (target == null ||
        _consumed ||
        _cancelledByUser ||
        state.phase != ThreadDetailPhase.ready) {
      return null;
    }
    switch (target.kind) {
      case ThreadDetailEntryTargetKind.none:
        _consumed = true;
        return null;
      case ThreadDetailEntryTargetKind.subthread:
        final subthreadId = target.subthreadId!;
        _consumed = true;
        if (state.detail?.subthreadById(subthreadId) == null ||
            state.selectedSubthreadId == subthreadId) {
          return null;
        }
        return ThreadDetailEntrySelection(
          subthreadId: subthreadId,
          generation: _generation,
        );
      case ThreadDetailEntryTargetKind.post:
        if (postTarget == null ||
            postTarget.threadId != _threadId ||
            state.detail?.subthreadById(postTarget.subthreadId) == null) {
          return null;
        }
        _consumed = true;
        if (state.selectedSubthreadId == postTarget.subthreadId) return null;
        return ThreadDetailEntrySelection(
          subthreadId: postTarget.subthreadId,
          generation: _generation,
        );
    }
  }

  void _rearm() {
    _consumed = false;
    _cancelledByUser = false;
    _generation += 1;
  }
}

class ThreadTargetFilterRestoreCoordinator {
  String? _lastSignature;

  void reset() => _lastSignature = null;

  bool scheduleIfNeeded({
    required ThreadDetailState state,
    required ThreadPostTargetModel? target,
    required String threadId,
    required ThreadTargetFilterRestore onRestore,
  }) {
    final authorId = state.floorAuthorId;
    final excluded =
        target != null &&
        target.focusedReplyId == null &&
        target.threadId == threadId &&
        state.phase == ThreadDetailPhase.ready &&
        state.selectedSubthreadId == target.subthreadId &&
        authorId != null &&
        target.floor.author.id != authorId;
    if (!excluded) {
      reset();
      return false;
    }
    final signature = '${target.requestedPostId}:$authorId';
    if (_lastSignature == signature) return true;
    _lastSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(onRestore(authorId, target.subthreadId));
    });
    return true;
  }
}

List<ThreadFloorModel> threadFloorsWithTarget(
  List<ThreadFloorModel> floors,
  ThreadPostTargetModel? target,
  ThreadFloorOrder order,
) {
  if (target == null) return floors;
  final index = floors.indexWhere((floor) => floor.id == target.floor.id);
  final merged = index == -1
      ? [...floors, target.floor]
      : [
          for (var floorIndex = 0; floorIndex < floors.length; floorIndex++)
            floorIndex == index ? target.floor : floors[floorIndex],
        ];
  merged.sort((left, right) {
    final leftNumber = left.floorNumber;
    final rightNumber = right.floorNumber;
    if (leftNumber == null && rightNumber == null) return 0;
    if (leftNumber == null) return 1;
    if (rightNumber == null) return -1;
    final comparison = leftNumber.compareTo(rightNumber);
    return order == ThreadFloorOrder.oldest ? comparison : -comparison;
  });
  return merged;
}
