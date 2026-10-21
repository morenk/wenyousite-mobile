import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_inline_compatibility_syntax.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';

class MarkdownAudioLabelRun {
  const MarkdownAudioLabelRun(this.text, this.marks);
  final String text;
  final Set<String> marks;
}

class MarkdownAudioProjection {
  const MarkdownAudioProjection(this.audio, this.label, this.labelRuns);
  final MediaAudio audio;
  final String label;
  final List<MarkdownAudioLabelRun> labelRuns;

  static Set<String> sourceKeys(Map<String, MediaAudio> audios) => {
    for (final entry in audios.entries)
      if (entry.key == entry.value.sourceUrl) entry.key,
  };

  static MarkdownAudioProjection? fromLine(
    String line,
    Map<String, MediaAudio> audios,
  ) {
    if (!line.contains('[')) return null;
    final blocks = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: MarkdownInlineCompatibilitySyntax.create(),
      encodeHtml: false,
    ).parse(line);
    return blocks.length == 1 ? fromBlock(blocks.single, audios) : null;
  }

  /// 仅调用于顶层块，列表/引用内部不递归升级。
  static MarkdownAudioProjection? fromBlock(
    md.Node block,
    Map<String, MediaAudio> audios,
  ) {
    if (block is! md.Element || block.tag != 'p') return null;
    final children = block.children;
    if (children == null || children.length != 1) return null;
    var link = children.single;
    final outerMarks = <String>{};
    // 旧编辑器会把整段标签样式放到链接外；只展开单一文字样式链，
    // 不把混排、多链接、代码或块容器猜成音频。
    while (link is md.Element &&
        const {'strong', 'em', 'del', 's'}.contains(link.tag) &&
        link.children?.length == 1) {
      outerMarks.add(link.tag);
      link = link.children!.single;
    }
    if (link is! md.Element ||
        link.tag != 'a' ||
        link.attributes.containsKey('title')) {
      return null;
    }
    final audio = audios[link.attributes['href']];
    if (audio == null || !_textLabel(link)) return null;
    final runs = <MarkdownAudioLabelRun>[];
    void visit(md.Node node, Set<String> marks) {
      if (node is md.Text) {
        runs.add(MarkdownAudioLabelRun(node.text, Set.unmodifiable(marks)));
      } else if (node is md.Element) {
        for (final child in node.children ?? const <md.Node>[]) {
          visit(child, {...marks, if (node.tag != 'a') node.tag});
        }
      }
    }

    visit(link, outerMarks);
    return MarkdownAudioProjection(
      audio,
      link.textContent,
      List.unmodifiable(runs),
    );
  }

  static bool _textLabel(md.Node node) =>
      node is md.Text ||
      (node is md.Element &&
          const {'a', 'strong', 'em', 'del', 's', 'code'}.contains(node.tag) &&
          (node.children?.every(_textLabel) ?? false));
}
