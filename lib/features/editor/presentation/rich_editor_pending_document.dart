import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/local_image_marker.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

extension RichEditorPendingDocument on RichEditorSession {
  Set<String> get localImageIds {
    return {
      for (final op in controller.document.toDelta().toList())
        if (_imageUrl(op.data) case final String url)
          if (url.startsWith(localImageMarkerPrefix))
            url.substring(localImageMarkerPrefix.length),
    };
  }

  void insertLocalImage(String id) =>
      insertBlockImage(url: '$localImageMarkerPrefix$id');

  /// 后台完成只替换仍存在的节点，不重建文档、不改变选区和焦点。
  void resolveLocalImage(String id, UploadedEditorImage image) {
    if (image.display != null) {
      replaceMediaDisplays({...mediaDisplays, image.url: image.display!});
    }
    _replaceLocalImage(id, image, ChangeSource.remote);
  }

  void removeLocalImage(String id) => controller.runEditCommand(
    () => _replaceLocalImage(id, null, ChangeSource.local),
  );

  void _replaceLocalImage(
    String id,
    UploadedEditorImage? image,
    ChangeSource source,
  ) {
    final change = Delta();
    var changed = false;
    var offset = 0;
    var cursor = controller.selection;
    for (final op in controller.document.toDelta().toList()) {
      if (_imageUrl(op.data) == '$localImageMarkerPrefix$id') {
        changed = true;
        if (image != null) {
          final payload = Map<String, Object?>.from(
            (op.data as Map)[MarkdownDeltaCodec.imageEmbed] as Map,
          )..['url'] = image.url;
          change.insert({
            MarkdownDeltaCodec.imageEmbed: payload,
          }, op.attributes);
        } else {
          cursor = TextSelection(
            baseOffset: cursor.baseOffset > offset
                ? cursor.baseOffset - 1
                : cursor.baseOffset,
            extentOffset: cursor.extentOffset > offset
                ? cursor.extentOffset - 1
                : cursor.extentOffset,
          );
        }
        change.delete(1);
      } else {
        change.retain(op.length ?? 0);
      }
      offset += op.length ?? 0;
    }
    if (changed) controller.compose(change, cursor, source);
  }
}

String? _imageUrl(Object? data) {
  if (data is! Map) return null;
  final image = data[MarkdownDeltaCodec.imageEmbed];
  return image is Map ? image['url'] as String? : null;
}
