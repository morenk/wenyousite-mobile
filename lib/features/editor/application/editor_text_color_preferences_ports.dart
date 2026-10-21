import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class EditorTextColorPreferenceStore {
  Future<List<String>> read(String accountId);
  Future<void> write(String accountId, List<String> colors);
}

final editorTextColorPreferenceStoreProvider =
    Provider<EditorTextColorPreferenceStore>(
      (ref) => throw UnimplementedError('文字颜色存储未配置'),
    );

/// 只在用户应用自定义颜色后调用；取消及预设选择不改变最近色。
List<String> rememberEditorTextColor(
  List<String> previous,
  String color, {
  required int maximum,
}) => [color, ...previous.where((value) => value != color)]
    .where((value) => RegExp(r'^#[0-9A-F]{6}$').hasMatch(value))
    .toSet()
    .take(maximum)
    .toList();
