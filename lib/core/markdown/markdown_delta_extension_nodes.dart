import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';

abstract final class MarkdownDeltaExtensionNodes {
  static List<Map<String, Object?>> extract(
    Delta delta, {
    required String mentionEmbed,
    required String diceEmbed,
    required String stickerEmbed,
    required String imageEmbed,
    required String allPlayersLabel,
  }) {
    final nodes = <Map<String, Object?>>[];
    for (final operation in delta.operations) {
      final data = operation.data;
      if (!operation.isInsert || data is! Map || data.length != 1) continue;
      final embed = Map<String, dynamic>.from(data);
      final type = embed.keys.single;
      final payload = _payload(embed[type], type);
      if (type == mentionEmbed) {
        final kind = payload['kind'];
        if (kind == 'all_players') {
          nodes.add({'type': 'mention_all_players', 'label': allPlayersLabel});
        } else if (kind == 'user') {
          nodes.add({
            'type': 'mention',
            'userId': payload['userId'],
            'label': payload['label'],
          });
        }
      } else if (type == diceEmbed) {
        nodes.add({
          'type': 'dice',
          'nodeId': payload['nodeId'],
          'notation': payload['notation'],
        });
      } else if (type == stickerEmbed) {
        nodes.add({
          'type': 'sticker',
          'assetId': payload['assetId'],
          'url': payload['url'],
          'alt': payload['alt'],
        });
      } else if (type == imageEmbed) {
        nodes.add({
          'type': 'image',
          'url': payload['url'],
          'alt': payload['alt'],
          'title': payload['title'],
        });
      }
    }
    return nodes;
  }

  static Map<String, dynamic> _payload(Object? value, String type) {
    if (value is! Map) {
      throw MarkdownCodecException('$type embed 载荷不是对象');
    }
    return Map<String, dynamic>.from(value);
  }
}
