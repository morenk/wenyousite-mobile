import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/local_audio_marker.dart';

/// 仅用于本机 Markdown 快照，不属于服务端图片协议。
const localImageMarkerPrefix = 'https://local.invalid/wenyou-pending/';

bool containsLocalImageMarker(String source) =>
    source.contains(localImageMarkerPrefix);

Delta withoutLocalClipboardImages(Delta source) {
  final result = Delta();
  for (final op in source.toList()) {
    final data = op.data;
    final link = op.attributes?['link'];
    if (link is String && link.startsWith(localAudioMarkerPrefix)) {
      result.insert('[音频未就绪]');
    } else if (data is Map &&
        data.values.any(
          (value) =>
              value is Map &&
              value['url'] is String &&
              (value['url'] as String).startsWith(localImageMarkerPrefix),
        )) {
      result.insert('[图片未就绪]');
    } else {
      result.push(op);
    }
  }
  return result;
}
