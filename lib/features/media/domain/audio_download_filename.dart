/// 标签只作为文件名主体，绝不参与目录构造；播放副本统一为 MP3。
String audioDownloadFilename(String label) {
  var name = label
      .replaceAll(
        RegExp(
          r'[\x00-\x1f\x7f<>:"/\\|?*\u200e\u200f\u202a-\u202e\u2066-\u2069]',
        ),
        '_',
      )
      .trim();
  name = name.replaceFirst(RegExp(r'[.\s]+$'), '');
  name = name.replaceFirst(
    RegExp(r'\.[a-z0-9]{1,10}$', caseSensitive: false),
    '',
  );
  name = String.fromCharCodes(
    name.runes.take(80),
  ).replaceFirst(RegExp(r'[.\s]+$'), '');
  if (name.isEmpty || name == '.' || name == '..') name = '音频';
  if (RegExp(
    r'^(con|prn|aux|nul|com[1-9]|lpt[1-9])(?:\.|$)',
    caseSensitive: false,
  ).hasMatch(name)) {
    name = '_$name';
  }
  return '$name.mp3';
}
