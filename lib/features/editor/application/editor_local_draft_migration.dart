import 'dart:io';

import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';

/// 只迁移当前入口明确归属的旧草稿；先复制附件并提交新记录，再标记旧记录。
/// 中途失败仍保留旧文件，不扫描或拼接其他入口的历史内容。
Future<void> migrateEditorLocalDraft({
  required PendingMediaFileStore store,
  required String accountId,
  required String source,
  required String target,
  required Map<String, Object?> payload,
}) async {
  final images = <Map<String, Object?>>[];
  for (final value in payload['images'] as List? ?? const []) {
    if (value is! Map) continue;
    final entry = Map<String, Object?>.from(value);
    final encoded = entry['input'];
    if (entry['id'] is String && encoded is Map) {
      final input = decodePendingMediaInput(Map<String, Object?>.from(encoded));
      if (input != null) {
        if (input.sourcePath != null &&
            !await File(input.sourcePath!).exists()) {
          // 保留缺失文件的原路径与可重试/移除占位，不阻断整份正文恢复。
          images.add(entry);
          continue;
        }
        final copied = await store.persist(
          input,
          accountId: accountId,
          target: target,
          attachmentId: entry['id'] as String,
        );
        entry['input'] = encodePendingMediaInput(copied);
      }
    }
    images.add(entry);
  }
  await store.write(
    accountId: accountId,
    target: target,
    payload: {...payload, 'images': images, 'migratedFrom': source},
  );
  // 保留旧附件文件供异常恢复，不对历史目录做隐式清理。
  await store.write(
    accountId: accountId,
    target: source,
    payload: {'version': 1, 'completed': true, 'migratedTo': target},
  );
}
