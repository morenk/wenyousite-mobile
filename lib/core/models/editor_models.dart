enum EditorContextType { thread, subthread, floor, reply }

class LocalEditorSnapshot {
  const LocalEditorSnapshot({
    required this.id,
    required this.contextType,
    required this.body,
    required this.metadataJson,
    required this.clientRequestId,
    required this.updatedAt,
    this.contextId,
  });

  final String id;
  final EditorContextType contextType;
  final String? contextId;
  final String body;
  final String metadataJson;
  final String clientRequestId;
  final DateTime updatedAt;
}

enum PendingOperationState { pending, sending, awaitingConfirmation, confirmed }

class PendingCreateOperation {
  const PendingCreateOperation({
    required this.clientRequestId,
    required this.operationType,
    required this.normalizedPayload,
    required this.state,
    required this.updatedAt,
  });

  final String clientRequestId;
  final String operationType;
  final String normalizedPayload;
  final PendingOperationState state;
  final DateTime updatedAt;
}
