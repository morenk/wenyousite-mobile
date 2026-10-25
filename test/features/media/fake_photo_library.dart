import 'dart:async';
import 'dart:typed_data';

import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class FakePhotoLibrary implements PhotoLibrary {
  PhotoLibraryAccess access = PhotoLibraryAccess.full;
  final requests = <bool>[];
  final resolved = <String>[];
  final pages = <(String, int)>[];
  final missing = <String>{};
  bool failPage = false;
  bool failAlbums = false;
  bool corruptThumbnail = false;
  int settings = 0;
  int more = 0;
  Completer<List<LocalPhoto>>? pendingPage;
  Completer<MediaUploadInput>? pendingResolve;
  List<LocalPhotoAlbum> availableAlbums = const [
    LocalPhotoAlbum(
      id: 'recent',
      name: '最近图片',
      count: 84,
      isRecent: true,
      cover: LocalPhoto('0'),
    ),
    LocalPhotoAlbum(id: 'other', name: '旅行', count: 3, cover: LocalPhoto('82')),
  ];

  @override
  Future<PhotoLibraryAccess> permission({required bool request}) async {
    requests.add(request);
    return access;
  }

  @override
  Future<void> openSettings() async {
    settings++;
  }

  @override
  Future<void> selectMore() async {
    more++;
  }

  @override
  Future<List<LocalPhotoAlbum>> albums() async {
    if (failAlbums) throw StateError('offline');
    return availableAlbums;
  }

  @override
  Future<bool> exists(LocalPhoto photo) async => !missing.contains(photo.id);
  @override
  Future<List<LocalPhoto>> photos(
    String albumId, {
    required int page,
    required int size,
  }) async {
    pages.add((albumId, page));
    if (pendingPage case final pending?) return pending.future;
    if (failPage) throw StateError('offline');
    final ids = albumId == 'recent'
        ? List.generate(84, (index) => '$index')
        : ['82', '1', '83'];
    return ids.skip(page * size).take(size).map(LocalPhoto.new).toList();
  }

  @override
  Future<Uint8List?> thumbnail(
    LocalPhoto photo, {
    required int size,
    bool preserveAspect = false,
  }) async {
    if (corruptThumbnail) return Uint8List.fromList([1, 2, 3]);
    final index = int.tryParse(photo.id) ?? 0;
    final wide = index.isEven;
    final shade = index % 4 == 0
        ? 20
        : index % 4 == 1
        ? 235
        : 100;
    final picture = image.Image(width: wide ? 160 : 80, height: wide ? 80 : 160)
      ..clear(image.ColorRgb8(shade, shade, shade));
    image.fillRect(
      picture,
      x1: picture.width ~/ 4,
      y1: picture.height ~/ 4,
      x2: picture.width * 3 ~/ 4,
      y2: picture.height * 3 ~/ 4,
      color: image.ColorRgb8(
        100 + index * 23 % 150,
        70 + index * 17 % 140,
        95 + index * 31 % 155,
      ),
    );
    return Uint8List.fromList(image.encodePng(picture));
  }

  @override
  Future<MediaUploadInput> resolve(
    LocalPhoto photo,
    MediaUploadPurpose purpose,
  ) async {
    resolved.add(photo.id);
    if (pendingResolve case final pending?) return pending.future;
    return MediaUploadInput(
      filename: '${photo.id}.png',
      bytes: (await thumbnail(photo, size: 100))!,
      purpose: purpose,
    );
  }
}
