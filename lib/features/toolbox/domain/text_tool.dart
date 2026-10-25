enum TextTool {
  vertical('vertical', '文字竖排'),
  morse('morse', '摩斯编码'),
  fancy('fancy', '花体字'),
  names('names', '起名工具');

  const TextTool(this.id, this.title);

  final String id;
  final String title;

  static TextTool? fromId(String? id) {
    for (final tool in values) {
      if (tool.id == id) return tool;
    }
    return null;
  }
}
