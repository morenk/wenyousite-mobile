import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/local_audio_marker.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_audio_projection.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_inline_encoder.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_code_source.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_link_identity.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_paragraph_boundaries.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';

/// 仅编辑会话使用的可逆视图；不在 Markdown、API 或系统剪贴板保存。
abstract final class MarkdownAudioEmbed {
  static const type = 'wenyou_audio_view';
  static const _attributes = {
    'link',
    'bold',
    'italic',
    'strike',
    'code',
    markdownLinkIdentityKey,
    MarkdownDeltaInlineEncoder.literalTextKey,
    MarkdownInlineCodeSource.key,
  };

  static Delta? content(Object? payload) {
    if (payload is! Map || payload['link'] is! List) return null;
    try {
      final value = Delta.fromJson(payload['link'] as List);
      return _linkUrl(value) == null ? null : value;
    } on Object {
      return null;
    }
  }

  static String? pendingId(Object? payload) {
    final value = content(payload);
    final url = value == null ? null : _linkUrl(value);
    if (url == null || !url.startsWith(localAudioMarkerPrefix)) return null;
    final id = url.substring(localAudioMarkerPrefix.length);
    return id.isEmpty ? null : id;
  }

  static String? _linkUrl(Delta value) {
    String? url;
    Object? identity;
    var first = true;
    if (value.isEmpty) return null;
    for (final op in value.operations) {
      final text = op.data;
      final attrs = op.attributes ?? const <String, dynamic>{};
      final link = attrs['link'];
      if (!op.isInsert ||
          text is! String ||
          text.isEmpty ||
          text.contains('\n') ||
          link is! String ||
          !isSafeAudioUrl(link) ||
          attrs.keys.any((key) => !_attributes.contains(key))) {
        return null;
      }
      if (!first &&
          (url != link || identity != attrs[markdownLinkIdentityKey])) {
        return null;
      }
      url = link;
      identity = attrs[markdownLinkIdentityKey];
      first = false;
    }
    return url;
  }

  static MarkdownAudioProjection? projection(
    Object? payload,
    Map<String, MediaAudio> audios,
  ) {
    final link = content(payload);
    if (link == null) return null;
    final url = _linkUrl(link)!;
    final audio = audios[url];
    if (audio == null || audio.sourceUrl != url) return null;
    final runs = [
      for (final op in link.operations)
        MarkdownAudioLabelRun(op.data as String, {
          if (op.attributes?['bold'] == true) 'strong',
          if (op.attributes?['italic'] == true) 'em',
          if (op.attributes?['strike'] == true) 'del',
          if (op.attributes?['code'] == true) 'code',
        }),
    ];
    return MarkdownAudioProjection(
      audio,
      runs.map((run) => run.text).join(),
      runs,
    );
  }

  static Delta expand(Delta source, {bool preserveLinkShape = false}) {
    final output = Delta();
    for (final op in source.operations) {
      final data = op.data;
      if (data is! Map || !data.containsKey(type)) {
        output.push(op);
        continue;
      }
      final link = content(data[type]);
      if (data.length != 1 || link == null) {
        throw const MarkdownCodecException('音频链接无法安全保存');
      }
      for (final item in link.operations) {
        output.insert(item.data, {
          ...?item.attributes,
          ...?op.attributes,
          if (preserveLinkShape)
            MarkdownDeltaInlineEncoder.keepLinkShapeKey: true,
        });
      }
    }
    return output;
  }

  static Delta project(Delta source, Map<String, MediaAudio> audios) {
    if (audios.isEmpty &&
        !source.operations.any(
          (op) =>
              (op.data is Map && (op.data as Map).containsKey(type)) ||
              (op.attributes?['link'] is String &&
                  (op.attributes!['link'] as String).startsWith(
                    localAudioMarkerPrefix,
                  )),
        )) {
      return source;
    }
    final expanded = expand(source);
    final output = Delta();
    var offset = 0;
    var start = 0;
    var line = Delta();
    for (final op in expanded.operations) {
      final data = op.data;
      if (data is! String) {
        line.push(op);
        offset += op.length!;
        continue;
      }
      final parts = data.split('\n');
      for (var i = 0; i < parts.length; i++) {
        if (parts[i].isNotEmpty) line.insert(parts[i], op.attributes);
        offset += parts[i].length;
        if (i + 1 == parts.length) continue;
        offset++;
        final payload = {'link': line.toJson()};
        // 普通正文不反复扫描整篇段落；只有可信的单链接行需要查边界。
        final range =
            projection(payload, audios) == null && pendingId(payload) == null
            ? null
            : MarkdownParagraphBoundaries.range(expanded, start);
        if (range?.start == start && range?.end == offset) {
          output.insert({type: payload});
        } else {
          for (final item in line.operations) {
            output.push(item);
          }
        }
        output.insert('\n', op.attributes);
        line = Delta();
        start = offset;
      }
    }
    for (final item in line.operations) {
      output.push(item);
    }
    return output;
  }
}
