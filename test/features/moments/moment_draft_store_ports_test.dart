import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';

void main() {
  test('待完成图片保留稳定顺序、封面、私有路径与已上传身份', () {
    final draft = MomentLocalDraft(
      title: '本机图片',
      content: '正文',
      images: const [],
      imageOrder: const ['local-1'],
      coverMediaId: 'local-1',
      updatedAt: DateTime.utc(2026),
      pendingImages: [
        MomentPendingDraftImage(
          id: 'local-1',
          input: MediaUploadInput.fromPickedSource(
            const PickedMediaSource.file(
              filename: 'photo.png',
              path: '/private/missing-photo.png',
              length: 512,
              purpose: MediaUploadPurpose.moment,
            ),
          ),
          pending: const PendingMediaUpload(
            mediaId: 'server-1',
            purpose: MediaUploadPurpose.moment,
          ),
        ),
      ],
    );
    final restored = MomentLocalDraft.fromJson(draft.toJson())!;
    expect(restored.imageOrder, ['local-1']);
    expect(restored.coverMediaId, 'local-1');
    expect(
      restored.pendingImages.single.input.sourcePath,
      '/private/missing-photo.png',
    );
    expect(restored.pendingImages.single.pending?.mediaId, 'server-1');
    expect(
      restored.withPersistence('request').pendingImages.single.id,
      'local-1',
    );
  });

  test('动态草稿完整保存图片派生地址和动画标记', () {
    final draft = MomentLocalDraft(
      title: '晚风',
      content: '今天也很好。',
      images: const [
        UploadedEditorImage(
          mediaId: 'media-1',
          url: 'https://cdn.example.com/master.gif',
          thumbnailUrl: 'https://cdn.example.com/thumb.webp',
          feedUrl: 'https://cdn.example.com/feed.webp',
          mediumUrl: 'https://cdn.example.com/medium.webp',
          contentType: 'image/gif',
          animated: true,
          width: 640,
          height: 480,
        ),
      ],
      coverMediaId: 'media-1',
      updatedAt: DateTime.utc(2026, 8, 24),
    );

    final restored = MomentLocalDraft.fromJson(draft.toJson())!;
    final image = restored.images.single;

    expect(image.thumbnailUrl, 'https://cdn.example.com/thumb.webp');
    expect(image.feedUrl, 'https://cdn.example.com/feed.webp');
    expect(image.mediumUrl, 'https://cdn.example.com/medium.webp');
    expect(image.contentType, 'image/gif');
    expect(image.animated, isTrue);
    expect(image.previewUrls.first, 'https://cdn.example.com/thumb.webp');
  });

  test('旧动态草稿缺少新增图片字段时仍可恢复', () {
    final restored = MomentLocalDraft.fromJson({
      'title': '旧草稿',
      'content': '',
      'updatedAt': '2026-08-23T00:00:00.000Z',
      'coverMediaId': 'media-old',
      'images': [
        {
          'mediaId': 'media-old',
          'url': 'https://cdn.example.com/old.webp',
          'width': 320,
          'height': 240,
        },
      ],
    })!;

    expect(restored.images.single.animated, isFalse);
    expect(restored.images.single.thumbnailUrl, isNull);
    expect(restored.images.single.previewUrls, [
      'https://cdn.example.com/old.webp',
    ]);
  });
}
