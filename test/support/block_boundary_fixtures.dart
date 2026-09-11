import 'dart:convert';
import 'dart:io';
import 'package:flutter_quill/quill_delta.dart';

Map<String, dynamic> loadBlockBoundaryFixture() =>
    jsonDecode(
          File(
            'contracts/markdown-block-boundary-v1-fixtures.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

bool usesExistingLinkTitleFallback(String id) => const {
  'backtick-link-title-later-code',
  'backtick-link-title-multiline-code',
}.contains(id);

List<String> expectedBoundaryEditorLines(Map<String, dynamic> item) {
  final lines = (item['lines'] as List).cast<String>().toList();
  if (usesExistingLinkTitleFallback(item['id'] as String)) {
    lines[0] = (item['markdown'] as String).split('\n').first;
  }
  return lines;
}

List<Map<String, dynamic>> boundaryRows(Delta delta) {
  final rows = <Map<String, dynamic>>[];
  var text = StringBuffer();
  var nodeType = '';
  for (final op in delta.operations) {
    final data = op.data;
    if (data is Map) {
      final type = data.keys.single;
      if (type == 'wenyou_horizontal_rule') {
        nodeType = 'horizontal-rule';
      } else if (type == 'wenyou_image') {
        text.write('[图片]');
        nodeType = 'image';
      } else if (type == 'wenyou_sticker') {
        text.write('[表情]');
      } else if (data.values.single is Map) {
        final node = data.values.single as Map;
        text.write(node['label'] ?? node['raw'] ?? node['notation'] ?? '');
      }
      continue;
    }
    if (data is! String) continue;
    final parts = data.split('\n');
    for (var i = 0; i < parts.length; i++) {
      text.write(parts[i]);
      if (i == parts.length - 1) continue;
      final attrs = op.attributes ?? {};
      if (attrs['wenyou_source_separator'] != true &&
          nodeType != 'horizontal-rule') {
        rows.add({
          'text': text.toString(),
          'alignment': attrs['align'] ?? 'left',
          'type': nodeType.isNotEmpty
              ? nodeType
              : attrs['header'] != null
              ? 'heading-${attrs['header']}'
              : attrs['list'] == 'bullet'
              ? 'bullet-list'
              : attrs['list'] == 'ordered'
              ? 'ordered-list'
              : attrs['blockquote'] == true
              ? 'blockquote'
              : attrs['wenyou_empty_paragraph'] == true
              ? 'empty-paragraph'
              : 'paragraph',
        });
      }
      text = StringBuffer();
      nodeType = '';
    }
  }
  return rows;
}
