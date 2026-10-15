import 'package:flutter_quill/flutter_quill.dart';

/// 按 Quill 的 UTF-16 坐标读取可编辑范围，Embed 始终占一个 U+FFFC。
///
/// 文末保护换行不属于 UI 选区；结构替换可显式包含该换行以保留块属性。
/// 失效范围返回 null，调用方须跳过
/// 查询或操作，不能 clamp 到另一段正文。逐叶读取不经过剪贴板展开，
/// 也不进入 Quill getPlainText 在过期范围下重复读取末行的路径。
String? readQuillDocumentRange(
  Document document,
  int start,
  int length, {
  bool includeTerminalNewline = false,
}) {
  final lastCursor = document.length - 1;
  final end = includeTerminalNewline ? document.length : lastCursor;
  if (start < 0 || length < 0 || start > lastCursor || length > end - start) {
    return null;
  }
  if (length == 0) return '';

  final first = document.queryChild(start);
  var line = first.node as Line?;
  var offset = first.offset;
  var remaining = length;
  final result = StringBuffer();
  while (remaining > 0 && line != null) {
    for (final leaf in line.children) {
      if (offset >= leaf.length) {
        offset -= leaf.length;
        continue;
      }
      final available = leaf.length - offset;
      final take = remaining < available ? remaining : available;
      final text = leaf.toPlainText();
      result.write(text.substring(offset, offset + take));
      remaining -= take;
      if (remaining == 0) return result.toString();
      offset = 0;
    }
    // 每行自身的换行在叶节点之外，仍然占一个文档坐标。
    result.write('\n');
    remaining--;
    offset = 0;
    line = line.nextLine;
  }
  if (remaining != 0) {
    throw StateError('Quill 文档长度与实际行内容不一致');
  }
  return result.toString();
}
