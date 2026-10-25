import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_clipboard_text.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';

/// 动态、评论及私聊只接受文字和传送门。跨应用剪贴板仍走纯文本；
/// 只有同账号、未过期且 marker/正文匹配的进程内载体保留原子身份。
final editorAtomicClipboardReaderProvider =
    Provider<Future<Delta?> Function(String)>((ref) {
      return (text) async {
        final scope = ref.read(sessionScopeProvider);
        final projected = await readAtomicEditorClipboard(text, scope: scope);
        return ref.read(sessionScopeProvider) == scope ? projected : null;
      };
    });

Future<Delta?> readAtomicEditorClipboard(
  String visibleText, {
  required Object? scope,
  EditorClipboardGateway gateway = const PlatformEditorClipboardGateway(),
  WenyouEditorClipboardStore? store,
}) async {
  final snapshot = await gateway.read();
  if (snapshot.text != visibleText) return null;
  final source = (store ?? wenyouEditorClipboardStore)
      .resolve(visibleText, marker: snapshot.marker, scope: scope)
      .delta;
  if (source == null) return null;
  final output = Delta();
  for (final operation in source.operations) {
    if (operation.attributes?[MarkdownDeltaLineMetadata
            .sourceSeparatorAttribute] ==
        true) {
      continue;
    }
    final data = operation.data;
    if (data is String) {
      output.insert(data);
    } else if (data is Map &&
        data.containsKey(MarkdownDeltaCodec.internalReferenceEmbed)) {
      output.insert(data);
    } else {
      final text = MarkdownClipboardText.projectDelta(Delta()..insert(data));
      if (text.isNotEmpty) output.insert(text);
    }
  }
  // 完整富文本块末尾的虚拟换行不成为目标编辑器新增的空行。
  var result = output;
  while (result.isNotEmpty &&
      result.last.data is String &&
      (result.last.data as String).endsWith('\n')) {
    result = result.slice(
      0,
      MarkdownDeltaLineMetadata.documentLength(result) - 1,
    );
  }
  return result.isEmpty ? null : result;
}
