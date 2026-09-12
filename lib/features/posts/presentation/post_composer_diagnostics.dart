import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

class PostComposerDiagnostics {
  final sessionId = const Uuid().v4();
  String? lastFailureId;

  Future<void> submit({
    required PostComposerKind kind,
    required String content,
    required Future<void> Function() action,
    required ApiFailure? Function() failure,
  }) async {
    final operation = switch (kind) {
      PostComposerKind.editPost => DiagnosticOperation.postEdit,
      PostComposerKind.upsertBody => DiagnosticOperation.bodySave,
      _ => DiagnosticOperation.postCreate,
    };
    final diagnostics = FailureDiagnostics.instance;
    final attempt = diagnostics.attempt(operation, sessionId: sessionId);
    attempt.statistics.addAll({
      'characters': content.length,
      'images': RegExp(r'!\[').allMatches(content).length,
      'blocks': content.split('\n\n').length,
    });
    lastFailureId = null;
    await attempt.run(() async {
      try {
        attempt.mark(DiagnosticStage.encode);
        await action();
        final error = failure();
        if (error != null) diagnostics.capture(error);
        if (attempt.failureId == null) attempt.mark(DiagnosticStage.complete);
      } on Object catch (error, stack) {
        diagnostics.capture(error, stackTrace: stack);
        rethrow;
      } finally {
        lastFailureId = attempt.failureId;
      }
    });
  }

  Future<void> upload(Future<void> Function() action) => FailureDiagnostics
      .instance
      .attempt(DiagnosticOperation.mediaUpload, sessionId: sessionId)
      .run(action);
}
