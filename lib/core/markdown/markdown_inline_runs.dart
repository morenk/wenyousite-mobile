import 'package:flutter/foundation.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';

class MarkdownInlineRun {
  const MarkdownInlineRun(this.text, this.marks, {this.codeSource});
  final String text;
  final Map<String, dynamic> marks;
  final String? codeSource;
}

/// 对写入的定界符执行独立阅读检查，避免把编码器自身的往返当作阅读证明。
abstract final class MarkdownInlineRuns {
  static List<MarkdownInlineRun> normalizeEdges(List<MarkdownInlineRun> input) {
    final runs = input.where((run) => run.text.isNotEmpty).toList();
    List<Map<String, dynamic>> adjacent(int direction) {
      final result = List<Map<String, dynamic>>.filled(runs.length, const {});
      var carried = const <String, dynamic>{};
      for (
        var index = direction == 1 ? 0 : runs.length - 1;
        index >= 0 && index < runs.length;
        index += direction
      ) {
        final run = runs[index];
        result[index] = {
          for (final entry in run.marks.entries)
            if (carried[entry.key] == entry.value) entry.key: entry.value,
        };
        carried = run.marks['code'] == true || run.text.trim().isNotEmpty
            ? run.marks
            : result[index];
      }
      return result;
    }

    final leftEdges = adjacent(1);
    final rightEdges = adjacent(-1);

    final result = <MarkdownInlineRun>[];
    for (var index = 0; index < runs.length; index++) {
      final run = runs[index];
      if (run.marks['code'] == true || run.marks.isEmpty) {
        result.add(run);
        continue;
      }
      final core = run.text.trim();
      final left = leftEdges[index];
      final right = rightEdges[index];
      if (core.isEmpty) {
        result.add(
          MarkdownInlineRun(run.text, {
            for (final entry in left.entries)
              if (right[entry.key] == entry.value) entry.key: entry.value,
          }),
        );
        continue;
      }
      final leading = run.text.length - run.text.trimLeft().length;
      result.addAll([
        MarkdownInlineRun(run.text.substring(0, leading), left),
        MarkdownInlineRun(core, run.marks),
        MarkdownInlineRun(run.text.substring(leading + core.length), right),
      ]);
    }
    return result.where((run) => run.text.isNotEmpty).toList();
  }

  static bool matches(String source, List<MarkdownInlineRun> expected) {
    final actual = <MarkdownInlineRun>[];
    bool visit(List<md.Node> nodes, Map<String, dynamic> marks) {
      for (final node in nodes) {
        if (node is md.Text) {
          actual.add(MarkdownInlineRun(node.text, marks));
        } else if (node is md.Element) {
          final key = switch (node.tag) {
            'strong' => 'bold',
            'em' => 'italic',
            'del' => 'strike',
            'code' => 'code',
            'a' => 'link',
            _ => null,
          };
          if (key == null || node.children == null) return false;
          if (!visit(node.children!, {
            ...marks,
            key: key == 'link' ? node.attributes['href'] : true,
          })) {
            return false;
          }
        } else {
          return false;
        }
      }
      return true;
    }

    final nodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    ).parseInline(source);
    if (!visit(nodes, const {})) return false;
    final left = _merge(actual);
    final right = _merge(expected);
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index].text != right[index].text ||
          !mapEquals(left[index].marks, right[index].marks)) {
        return false;
      }
    }
    return true;
  }

  static List<MarkdownInlineRun> _merge(List<MarkdownInlineRun> runs) {
    final result = <MarkdownInlineRun>[];
    for (final run in runs) {
      if (run.text.isEmpty) continue;
      if (result.isNotEmpty && mapEquals(result.last.marks, run.marks)) {
        final previous = result.removeLast();
        result.add(MarkdownInlineRun(previous.text + run.text, run.marks));
      } else {
        result.add(run);
      }
    }
    return result;
  }

  static String write(
    List<MarkdownInlineRun> runs, {
    String bold = '**',
    String italic = '_',
  }) {
    final output = StringBuffer();
    var active = <MapEntry<String, dynamic>>[];
    var endsInBacktick = false;
    void close(int prefix) {
      for (final mark in active.skip(prefix).toList().reversed) {
        endsInBacktick = false;
        output.write(switch (mark.key) {
          'bold' => bold,
          'italic' => italic,
          'strike' => '~~',
          'link' => '](${mark.value})',
          _ => '',
        });
      }
    }

    for (final run in runs.where((run) => run.text.isNotEmpty)) {
      final next = [
        for (final key in ['bold', 'italic', 'link', 'strike'])
          if (run.marks[key] != null) MapEntry(key, run.marks[key]),
      ];
      var prefix = 0;
      while (prefix < active.length &&
          prefix < next.length &&
          active[prefix].key == next[prefix].key &&
          active[prefix].value == next[prefix].value) {
        prefix++;
      }
      close(prefix);
      for (final mark in next.skip(prefix)) {
        endsInBacktick = false;
        output.write(switch (mark.key) {
          'bold' => bold,
          'italic' => italic,
          'strike' => '~~',
          'link' => '[',
          _ => '',
        });
      }
      active = next;
      final content =
          run.codeSource ??
          _protectedText(
            run.text,
            protectStart: !endsInBacktick,
            protectWhitespace: true,
          );
      output.write(content);
      if (content.isNotEmpty) endsInBacktick = content.endsWith('`');
    }
    close(0);
    return output.toString();
  }

  static String _protectedText(
    String text, {
    required bool protectStart,
    required bool protectWhitespace,
  }) {
    final runes = text.runes.toList();
    if (runes.isEmpty) return '';
    if (!protectStart &&
        runes.length == 1 &&
        !(protectWhitespace && text.trim().isEmpty)) {
      return MarkdownContent.literalizeInlineText(text);
    }
    // 两端字符引用只改变 Markdown 拼写；可见文字和空白不增加占位符。
    return [
      for (var index = 0; index < runes.length; index++)
        if (protectWhitespace &&
            (index != 0 || protectStart) &&
            String.fromCharCode(runes[index]).trim().isEmpty)
          '&#${runes[index]};'
        else if (((index == 0 && protectStart) || index == runes.length - 1) &&
            String.fromCharCode(runes[index]).trim().isNotEmpty)
          '&#${runes[index]};'
        else
          MarkdownContent.literalizeInlineText(
            String.fromCharCode(runes[index]),
          ),
    ].join();
  }
}
