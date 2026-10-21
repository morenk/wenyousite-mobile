import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 纯文本编辑器读取受信的站内剪贴板投影，由应用入口装配实现。
/// 未装配时返回 null，调用方继续使用系统纯文本回退。
final atomicEditorClipboardReaderProvider =
    Provider<Future<Delta?> Function(String)>(
      (ref) =>
          (_) async => null,
    );
