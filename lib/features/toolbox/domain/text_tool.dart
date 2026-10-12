enum TextTool {
  vertical('vertical', '文字竖排', '从右往左读，自定列间空格'),
  morse('morse', '摩斯编码', '字母、数字与标点的编码和解码'),
  fancy('fancy', '花体英文', '转换为可复制的花体字符'),
  names('names', '起名工具', '十一国人名、中文古风与幻想角色名');

  const TextTool(this.id, this.title, this.description);

  final String id;
  final String title;
  final String description;

  static TextTool? fromId(String? id) {
    for (final tool in values) {
      if (tool.id == id) return tool;
    }
    return null;
  }
}
