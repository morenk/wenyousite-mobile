import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

typedef ThreadTargetFilterRestore =
    Future<void> Function(String authorId, String subthreadId);

String threadDetailLocation(String threadId, [String? targetPostId]) => Uri(
  pathSegments: ['', 'threads', threadId],
  queryParameters: targetPostId == null ? null : {'post': targetPostId},
).toString();

String threadPostLocation(String threadId, String postId) => Uri(
  pathSegments: ['', 'threads', threadId],
  queryParameters: {'post': postId},
).toString();

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
