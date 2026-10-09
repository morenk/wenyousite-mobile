import 'text_tool.dart';

/// 工具网页固定使用自有公网来源，不接受 API 地址或任意入口覆盖。
class ToolboxLocationPolicy {
  final Uri origin = Uri.https('wenyou.site');

  Uri location(TextTool tool, {required bool dark}) => origin.replace(
    path: '/tools/embed/${tool.id}',
    queryParameters: {'theme': dark ? 'dark' : 'light'},
  );

  bool allows(String input) {
    final uri = Uri.tryParse(input);
    if (uri == null ||
        uri.scheme != origin.scheme ||
        uri.host != origin.host ||
        uri.port != origin.port ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment) {
      return false;
    }
    final paths = {
      '/tools/embed',
      for (final tool in TextTool.values) '/tools/embed/${tool.id}',
    };
    if (!paths.contains(uri.path)) return false;
    // 输入和结果不得通过任意 URL 参数进入日志或站外地址。
    return uri.queryParametersAll.entries.every(
      (entry) =>
          entry.key == 'theme' &&
          entry.value.length == 1 &&
          const {'light', 'dark'}.contains(entry.value.single),
    );
  }
}
