import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_states.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

bool isDirectConversationInaccessible(ApiFailure failure) =>
    failure.httpStatus == 404 ||
    failure.httpStatus == 403 ||
    failure.reason == FailureReason.notFound ||
    failure.reason == FailureReason.permissionDenied;

DirectConversationState directConversationReadFailure(
  DirectConversationState current,
  ApiFailure failure,
) => isDirectConversationInaccessible(failure)
    ? DirectConversationState(
        phase: DirectConversationPhase.failed,
        failure: failure,
      )
    : current.copyWith(
        isRefreshing: false,
        isLoadingOlder: false,
        transientFailure: failure,
      );

List<DirectMessage> mergeDirectMessages(
  Iterable<DirectMessage> current,
  Iterable<DirectMessage> incoming,
) {
  final byId = <String, DirectMessage>{};
  for (final message in current) {
    byId[message.id] = message;
  }
  for (final message in incoming) {
    byId[message.id] = message;
  }
  final merged = byId.values.toList()..sort(_compareMessages);
  return List.unmodifiable(merged);
}

int _compareMessages(DirectMessage left, DirectMessage right) {
  final byTime = left.createdAt.compareTo(right.createdAt);
  return byTime != 0 ? byTime : left.id.compareTo(right.id);
}
