import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

const _source = 'https://cdn.example/original.gif';
const _display = MediaDisplay(
  url: 'https://cdn.example/full.webp',
  width: 320,
  height: 180,
  bytes: 180,
  animated: true,
  frameCount: 2,
  durationMs: 360,
  loopCount: 2,
);

void main() {
  test('主题快照恢复保留身份与映射，单项缓存损坏不丢标题/owner/远端草稿', () {
    final metadata = ThreadSnapshotMetadata(
      ownerId: 'user-one',
      title: '标题',
      categorySlug: 'general',
      visibility: ThreadComposeVisibility.private,
      tags: const ['test'],
      mediaDisplays: const {_source: _display},
      remoteDraft: const ThreadRemoteDraft(
        id: 'thread-one',
        version: 3,
        defaultSubthreadId: 'sub-one',
        defaultSubthreadVersion: 2,
        title: '标题',
        categorySlug: 'general',
        visibility: ThreadComposeVisibility.private,
        tags: [],
        body: '![图片]($_source)',
      ),
    );
    final raw = jsonDecode(metadata.toJson()) as Map<String, Object?>;
    final restored = ThreadSnapshotMetadata.fromJson(jsonEncode(raw))!;
    expect(restored.mediaDisplays[_source]!.url, _display.url);
    for (final broken in [
      null,
      7,
      {
        'bad': {'url': 'javascript:bad'},
        _source: _display.toJson(),
      },
    ]) {
      raw['mediaDisplays'] = broken;
      final result = ThreadSnapshotMetadata.fromJson(jsonEncode(raw))!;
      expect(result.title, '标题');
      expect(result.ownerId, 'user-one');
      expect(result.remoteDraft?.id, 'thread-one');
      expect(result.remoteDraft?.version, 3);
      expect(result.mediaDisplays.containsKey('bad'), isFalse);
      expect(
        result.mediaDisplays[_source]?.url,
        broken is Map ? _display.url : null,
      );
    }
  });
  test('动态图本地草稿往返保留原始媒体ID和完整display，坏缓存不破坏正文', () {
    final draft = MomentLocalDraft(
      title: '标题',
      content: '正文',
      images: const [
        UploadedEditorImage(
          mediaId: 'media-one',
          url: _source,
          display: _display,
          animated: true,
        ),
      ],
      updatedAt: DateTime.utc(2026, 9, 12),
    );
    final raw = jsonDecode(jsonEncode(draft.toJson())) as Map<String, Object?>;
    final restored = MomentLocalDraft.fromJson(raw)!;
    expect(restored.images.single.mediaId, 'media-one');
    expect(restored.images.single.url, _source);
    expect(restored.images.single.display?.url, _display.url);
    final image = (raw['images']! as List).single as Map<String, Object?>;
    image['display'] = {'url': 'file:///private'};
    final recovered = MomentLocalDraft.fromJson(raw)!;
    expect(recovered.content, '正文');
    expect(recovered.images.single.url, _source);
    expect(recovered.images.single.display, isNull);
  });
}
