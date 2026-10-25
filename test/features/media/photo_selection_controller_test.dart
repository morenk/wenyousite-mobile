import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/application/photo_selection_controller.dart';
import 'package:wenyousite_mobile/features/media/data/unified_image_picker.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

import 'fake_photo_library.dart';

void main() {
  late FakePhotoLibrary library;
  late PhotoSelectionController controller;
  setUp(() {
    library = FakePhotoLibrary();
    controller = PhotoSelectionController(
      library: library,
      request: const PhotoSelectionRequest(
        limit: 2,
        purpose: MediaUploadPurpose.moment,
      ),
    );
  });
  tearDown(() => controller.dispose());

  test('按需申请、分页与跨相册顺序，上限不丢失已选，确认前不读取文件', () async {
    expect(library.requests, isEmpty);
    await controller.refresh(requestPermission: true);
    expect(library.requests, [true]);
    expect(controller.photos, hasLength(80));
    controller.toggle(controller.photos[4]);
    controller.toggle(controller.photos[1]);
    controller.toggle(controller.photos[2]);
    expect(controller.selected.map((photo) => photo.id), ['4', '1']);
    expect(controller.error, contains('2'));
    expect(library.resolved, isEmpty);
    await controller.loadMore();
    expect(controller.photos, hasLength(84));
    expect(controller.hasMore, isFalse);
    await controller.switchAlbum(controller.albums.last);
    expect(controller.number(controller.photos[1]), 2);
    controller.toggle(controller.photos[1]);
    controller.toggle(controller.photos.first);
    final result = await controller.confirm();
    expect(library.resolved, ['4', '82']);
    expect(
      result!.map((input) => input.purpose),
      everyElement(MediaUploadPurpose.moment),
    );
  });

  test('分页失败显式重试，同一页未跳过', () async {
    library.failPage = true;
    await controller.refresh();
    expect(controller.pageError, isNotNull);
    library.failPage = false;
    await controller.loadMore();
    expect(library.pages, [('recent', 0), ('recent', 0)]);
    expect(controller.photos, hasLength(80));
  });

  for (final access in PhotoLibraryAccess.values) {
    test('权限 $access 和返回前台刷新不重复弹授权', () async {
      library.access = access;
      await controller.refresh(requestPermission: true);
      expect(
        controller.accessible,
        access == PhotoLibraryAccess.full ||
            access == PhotoLibraryAccess.limited,
      );
      if (controller.accessible) controller.toggle(controller.photos.first);
      library.access = PhotoLibraryAccess.denied;
      await controller.refresh();
      expect(controller.photos, isEmpty);
      expect(controller.selected, isEmpty);
      expect(library.requests, [true, false]);
      library.access = PhotoLibraryAccess.limited;
      await controller.refresh(selectMore: true);
      expect(library.more, 1);
      expect(controller.accessible, isTrue);
    });
  }

  test('空相册、读取失败与恢复；删除选中文件不交付半批输入', () async {
    library.availableAlbums = [];
    await controller.refresh();
    expect(controller.photos, isEmpty);
    library.availableAlbums = const [
      LocalPhotoAlbum(id: 'recent', name: '最近图片', count: 84),
    ];
    library.failAlbums = true;
    await controller.refresh();
    expect(controller.error, isNotNull);
    library.failAlbums = false;
    await controller.refresh();
    controller.toggle(controller.photos.first);
    controller.toggle(controller.photos[1]);
    library.missing.add('1');
    expect(await controller.confirm(), isNull);
    expect(controller.selected.map((photo) => photo.id), ['0']);
    expect(controller.error, contains('删除'));
  });

  test('确认期间撤销权限清空选择，不取文件', () async {
    await controller.refresh();
    controller.toggle(controller.photos.first);
    library.access = PhotoLibraryAccess.denied;
    expect(await controller.confirm(), isNull);
    expect(library.resolved, isEmpty);
    expect(controller.photos, isEmpty);
    expect(controller.selected, isEmpty);
  });

  test('切换相册丢弃旧分页结果', () async {
    await controller.refresh();
    final pending = library.pendingPage = Completer<List<LocalPhoto>>();
    final loading = controller.loadMore();
    library.pendingPage = null;
    await controller.switchAlbum(controller.albums.last);
    pending.complete([const LocalPhoto('old')]);
    await loading;
    expect(controller.photos.map((photo) => photo.id), ['82', '1', '83']);
  });

  test('读取文件期间撤权，不返回已经读出的文件', () async {
    await controller.refresh();
    controller.toggle(controller.photos.first);
    final pending = library.pendingResolve = Completer<MediaUploadInput>();
    final result = controller.confirm();
    await Future<void>.delayed(Duration.zero);
    library.access = PhotoLibraryAccess.denied;
    pending.complete(
      MediaUploadInput(filename: 'local.png', bytes: Uint8List(1)),
    );
    expect(await result, isNull);
    expect(controller.photos, isEmpty);
    expect(controller.selected, isEmpty);
  });

  test('数据端口保留单选、多选、用途与防重入', () async {
    final coordinator = PhotoSelectionCoordinator();
    final picker = UnifiedImagePicker(coordinator);
    final pending = Completer<List<MediaUploadInput>?>();
    PhotoSelectionRequest? request;
    coordinator.presenter = (value) {
      request = value;
      return pending.future;
    };
    final first = picker.pickManyFromGalleryFor(
      limit: 9,
      purpose: MediaUploadPurpose.moment,
    );
    expect(await picker.pickFromGallery(), isNull);
    expect(request?.limit, 9);
    expect(request?.purpose, MediaUploadPurpose.moment);
    pending.complete([]);
    expect(await first, isEmpty);
    for (final purpose in MediaUploadPurpose.values) {
      coordinator.presenter = (value) async {
        expect(value.purpose, purpose);
        expect(value.limit, 1);
        return [
          MediaUploadInput(
            filename: 'a.gif',
            bytes: Uint8List.fromList([71, 73, 70]),
            purpose: purpose,
          ),
        ];
      };
      final input = await picker.pickFromGalleryFor(purpose);
      expect(input!.bytes, [71, 73, 70]);
    }
  });

  test('宿主未绑定是明确失败，不伪装成取消', () async {
    final coordinator = PhotoSelectionCoordinator();
    const request = PhotoSelectionRequest(
      limit: 1,
      purpose: MediaUploadPurpose.avatar,
    );
    await expectLater(coordinator.pick(request), throwsStateError);
    coordinator.presenter = (_) async => [];
    expect(await coordinator.pick(request), isEmpty, reason: '失败后不遗留busy');
  });
}
