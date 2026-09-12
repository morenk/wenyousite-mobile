import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_inline_encoder.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

/// Compares visible editor state without encoding it a second time.
/// Only known provenance and canonical block separators are normalized;
/// text, soft breaks, paragraph breaks, marks and node identity stay observable.
final class MarkdownDeltaSemantics {
  MarkdownDeltaSemantics._();

  static bool equivalent(Delta before, Delta after) =>
      _signature(before) == _signature(after);

  static String _signature(Delta source) {
    final delta = MarkdownDeltaLineMetadata.prepareForEncoding(source);
    final lines = <_SemanticLine>[];
    var line = _SemanticLine();
    for (final operation in delta.operations) {
      final data = operation.data;
      if (data is! String) {
        line.runs.insert(_node(data));
        continue;
      }
      final parts = data.split('\n');
      for (var index = 0; index < parts.length; index++) {
        if (parts[index].isNotEmpty) {
          line.runs.insert(
            parts[index],
            MarkdownDeltaInlineEncoder.visibleMarks(operation.attributes),
          );
        }
        if (index == parts.length - 1) continue;
        final attributes = operation.attributes ?? const <String, dynamic>{};
        line.block = {
          for (final key in const [
            'header',
            'list',
            'blockquote',
            'indent',
            'align',
          ])
            if (attributes[key] != null &&
                attributes[key] != false &&
                !(key == 'align' && attributes[key] == 'left') &&
                !(key == 'indent' && attributes[key] == 0))
              key: attributes[key],
          if (attributes[MarkdownDeltaLineMetadata.emptyKey] == true)
            'empty': true,
        };
        line.literal =
            attributes[MarkdownDeltaLineMetadata.literalLineKey] == true;
        lines.add(line);
        line = _SemanticLine();
      }
    }
    if (line.runs.isNotEmpty || lines.isEmpty) lines.add(line);

    final contentLines = lines
        .where((line) => !line.isSourceSeparator)
        .toList();
    for (final line in contentLines) {
      if (line.hasOnlyPlainText &&
          MarkdownAlignmentContract.isMarkerLine(line.plainText)) {
        line.literal = true;
      }
    }
    final literalIndexes = MarkdownContent.unsupportedLineIndexes(
      contentLines.map((line) => line.plainText).join('\n'),
      imageAlignment: true,
    );
    for (final index in literalIndexes) {
      if (index < contentLines.length && contentLines[index].hasOnlyPlainText) {
        contentLines[index].literal = true;
      }
    }
    final semanticLines = <Object>[];
    for (var index = 0; index < lines.length; index++) {
      final current = lines[index];
      if (current.isSourceSeparator &&
          ((index > 0 && lines[index - 1].requiresBlockSeparator) ||
              (index + 1 < lines.length &&
                  lines[index + 1].requiresBlockSeparator))) {
        continue;
      }
      semanticLines.add({
        'runs': current.normalizedRuns.toJson(),
        'block': current.block,
      });
    }
    return jsonEncode(_ordered(semanticLines));
  }

  static Object? _node(Object? data) {
    if (data is! Map || data.length != 1 || data.values.single is! Map) {
      return data;
    }
    final type = data.keys.single;
    final payload = Map<String, dynamic>.from(data.values.single as Map);
    if (type == 'wenyou_dice') {
      final id = payload['nodeId'];
      final notation = payload['notation'];
      if (id is String) payload['nodeId'] = id.toLowerCase();
      if (notation is String) {
        payload['notation'] = MarkdownDiceContract.normalizeNotation(notation);
      }
    } else if (type == 'wenyou_sticker') {
      // Sticker labels are fixed by the existing Markdown node contract.
      payload['alt'] = '表情';
    } else if (type == 'wenyou_image') {
      payload.putIfAbsent('title', () => null);
    } else if (type == 'wenyou_internal_reference') {
      final location = payload['location'];
      if (location is String) {
        payload['location'] =
            parseInternalReference(location)?.location.toString() ?? location;
      }
    } else if (type == 'wenyou_compatibility') {
      // The reason is diagnostic metadata; the original node token is retained.
      payload.remove('reason');
    }
    return {type: payload};
  }

  static Object? _ordered(Object? value) {
    if (value is List) return value.map(_ordered).toList();
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      return {for (final key in keys) key: _ordered(value[key])};
    }
    return value;
  }
}

final class _SemanticLine {
  final runs = Delta();
  Map<String, dynamic> block = {};
  bool literal = false;

  String get plainText => runs.operations
      .map((op) => op.data is String ? op.data as String : '\uFFFC')
      .join();

  bool get hasOnlyPlainText => runs.operations.every(
    (op) => op.data is String && (op.attributes?.isEmpty ?? true),
  );

  bool get isSourceSeparator => runs.isEmpty && block.isEmpty;

  bool get requiresBlockSeparator =>
      literal ||
      block['empty'] == true ||
      block['list'] != null ||
      (runs.operations.length == 1 &&
          runs.operations.single.data is Map &&
          ((runs.operations.single.data as Map).containsKey('wenyou_image') ||
              (runs.operations.single.data as Map).containsKey(
                'wenyou_horizontal_rule',
              )));

  Delta get normalizedRuns {
    final output = Delta();
    for (final op in runs.operations) {
      final data = op.data;
      final attributes = op.attributes;
      if (data is! String ||
          attributes == null ||
          attributes.isEmpty ||
          attributes['code'] == true) {
        output.insert(data, attributes);
        continue;
      }
      // Markdown's existing edge-whitespace rule leaves those spaces outside
      // marks. Interior whitespace in a merged logical run retains all marks.
      final leading = data.length - data.trimLeft().length;
      final core = data.trim();
      if (leading > 0) output.insert(data.substring(0, leading));
      if (core.isNotEmpty) output.insert(core, attributes);
      if (leading + core.length < data.length) {
        output.insert(data.substring(leading + core.length));
      }
    }
    // Delta merges equal adjacent attributes; explicit empty maps are omitted.
    return Delta.fromJson([
      for (final op in output.operations)
        {
          'insert': op.data,
          if (!mapEquals(op.attributes, const {}) && op.attributes != null)
            'attributes': op.attributes,
        },
    ]);
  }
}
