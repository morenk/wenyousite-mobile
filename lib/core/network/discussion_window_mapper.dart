import 'package:wenyousite_mobile/core/models/discussion_window.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

DiscussionWindow<T> mapDiscussionWindow<T>({
  required List<T> items,
  required List<T> pinnedItems,
  required num total,
  required num? maxNumber,
  required String? targetId,
  required num? targetNumber,
  required String? beforeCursor,
  required String? afterCursor,
  required bool hasBefore,
  required bool hasAfter,
  required int limit,
  required int? requestedNumber,
  required String? requestedId,
  required String Function(T) idOf,
  required int? Function(T) numberOf,
}) {
  bool integer(num value) => value.isFinite && value == value.toInt();
  final numbers = [...items, ...pinnedItems].map(numberOf).toList();
  final exact = requestedNumber != null || requestedId != null;
  if (!integer(total) ||
      total < items.length ||
      (maxNumber != null && (!integer(maxNumber) || maxNumber < 1)) ||
      items.length > limit ||
      pinnedItems.length > 10 ||
      items.map(idOf).toSet().length != items.length ||
      pinnedItems.map(idOf).toSet().length != pinnedItems.length ||
      numbers.any(
        (number) => number == null || number < 1 || number > (maxNumber ?? 0),
      ) ||
      hasBefore != (beforeCursor != null && beforeCursor.trim().isNotEmpty) ||
      hasAfter != (afterCursor != null && afterCursor.trim().isNotEmpty) ||
      (targetId == null) != (targetNumber == null) ||
      exact != (targetId != null && targetNumber != null) ||
      (exact &&
          (!items.any(
                (item) =>
                    idOf(item) == targetId && numberOf(item) == targetNumber,
              ) ||
              (requestedNumber != null && requestedNumber != targetNumber) ||
              (requestedId != null && requestedId != targetId)))) {
    throw const ApiFailure.invalidResponse(
      diagnosticCode: 'discussion.window.invalid_shape',
    );
  }
  return DiscussionWindow(
    items: List.unmodifiable(items),
    pinnedItems: List.unmodifiable(pinnedItems),
    total: total.toInt(),
    maxNumber: maxNumber?.toInt() ?? 0,
    targetId: targetId,
    targetNumber: targetNumber?.toInt(),
    beforeCursor: beforeCursor,
    afterCursor: afterCursor,
  );
}
