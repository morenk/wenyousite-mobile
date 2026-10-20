import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';

/// 单个编辑会话的打开拦截去重；源码仅驻留内存，不进入诊断字段。
final class EditorOpeningDiagnostics {
  ({String source, String reason, MarkdownEditingBlockedException error})?
  _lastFailure;

  String? capture(String source, String reason) {
    if (_lastFailure?.source != source || _lastFailure?.reason != reason) {
      _lastFailure = (
        source: source,
        reason: reason,
        error: MarkdownEditingBlockedException(reason),
      );
    }
    // 主动拦截没有抛出栈，不能把当前栈伪装成异常位置。
    return FailureDiagnostics.instance.capture(
      _lastFailure!.error,
      operation: DiagnosticOperation.editorOpen,
      stage: DiagnosticStage.decode,
    );
  }
}
