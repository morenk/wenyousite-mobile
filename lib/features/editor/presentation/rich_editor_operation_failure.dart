enum RichEditorOperationFailureKind {
  clipboardBusy,
  clipboardEmpty,
  clipboardRead,
  clipboardWrite,
  pasteFailed,
  documentChanged,
  contentTooLong,
}

class RichEditorOperationFailure {
  const RichEditorOperationFailure(this.kind, this.message);

  final RichEditorOperationFailureKind kind;
  final String message;
}
