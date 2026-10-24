import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

typedef PhotoFileReader =
    Future<File?> Function(AssetEntity asset, {required bool original});

Future<File?> _readPhotoFile(AssetEntity asset, {required bool original}) =>
    asset.getFile(isOrigin: original);

class DevicePhotoLibrary implements PhotoLibrary {
  DevicePhotoLibrary({bool? isAndroid, PhotoFileReader? fileReader})
    : _isAndroid = isAndroid ?? Platform.isAndroid,
      _fileReader = fileReader ?? _readPhotoFile;
  final bool _isAndroid;
  final PhotoFileReader _fileReader;
  static const permissionOption = PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.image,
      mediaLocation: false,
    ),
  );
  final _paths = <String, AssetPathEntity>{};

  @override
  Future<PhotoLibraryAccess> permission({required bool request}) async {
    final state = request
        ? await PhotoManager.requestPermissionExtend(
            requestOption: permissionOption,
          )
        : await PhotoManager.getPermissionState(
            requestOption: permissionOption,
          );
    return switch (state) {
      PermissionState.authorized => PhotoLibraryAccess.full,
      PermissionState.limited => PhotoLibraryAccess.limited,
      PermissionState.restricted => PhotoLibraryAccess.restricted,
      PermissionState.denied ||
      PermissionState.notDetermined => PhotoLibraryAccess.denied,
    };
  }

  @override
  Future<void> selectMore() =>
      PhotoManager.presentLimited(type: RequestType.image);

  @override
  Future<void> openSettings() async {
    await PhotoManager.openSetting();
  }

  @override
  Future<List<LocalPhotoAlbum>> albums() async {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );
    _paths.clear();
    final result = <LocalPhotoAlbum>[];
    for (final path in paths) {
      _paths[path.id] = path;
      final count = await path.assetCountAsync;
      final cover = count == 0
          ? const <AssetEntity>[]
          : await path.getAssetListRange(start: 0, end: 1);
      result.add(
        LocalPhotoAlbum(
          id: path.id,
          name: path.isAll ? '最近图片' : path.name,
          count: count,
          isRecent: path.isAll,
          cover: cover.isEmpty ? null : LocalPhoto(cover.first.id),
        ),
      );
    }
    result.sort((a, b) => a.isRecent == b.isRecent ? 0 : (a.isRecent ? -1 : 1));
    return result;
  }

  @override
  Future<List<LocalPhoto>> photos(
    String albumId, {
    required int page,
    required int size,
  }) async {
    final path = _paths[albumId];
    if (path == null) return [];
    final assets = await path.getAssetListPaged(page: page, size: size);
    return [for (final asset in assets) LocalPhoto(asset.id)];
  }

  @override
  Future<Uint8List?> thumbnail(
    LocalPhoto photo, {
    required int size,
    bool preserveAspect = false,
  }) async {
    final asset = await AssetEntity.fromId(photo.id);
    if (asset == null) return null;
    final width = asset.orientatedWidth;
    final height = asset.orientatedHeight;
    final ratio = width <= 0 || height <= 0 ? 1.0 : width / height;
    final target = !preserveAspect
        ? ThumbnailSize.square(size)
        : ratio >= 1
        ? ThumbnailSize(size, (size / ratio).round().clamp(1, size))
        : ThumbnailSize((size * ratio).round().clamp(1, size), size);
    return asset.thumbnailDataWithOption(
      _isAndroid
          ? ThumbnailOption(size: target)
          : ThumbnailOption.ios(
              size: target,
              resizeContentMode: preserveAspect
                  ? ResizeContentMode.fit
                  : ResizeContentMode.fill,
            ),
    );
  }

  @override
  Future<bool> exists(LocalPhoto photo) async =>
      await AssetEntity.fromId(photo.id) != null;

  @override
  Future<MediaUploadInput> resolve(
    LocalPhoto photo,
    MediaUploadPurpose purpose,
  ) async {
    final asset = await AssetEntity.fromId(photo.id);
    // 只有明确确认后才取得原件，GIF 保留原字节；浏览只读取缩略图。
    // Android 10 的 originFile 会要求原始位置元数据；普通 file 是内容流复制，
    // 不请求定位、不重编码 GIF。Apple 平台取原件，避免 GIF 被转成静态图。
    final file = asset == null
        ? null
        : await _fileReader(asset, original: !_isAndroid);
    if (file == null || !await file.exists()) {
      throw PhotoLibraryFailure.unavailable;
    }
    final input = await mediaUploadInputFromXFile(
      XFile(file.path, mimeType: asset?.mimeType),
      emptyMessage: '图片文件不能为空。',
      purpose: purpose,
    );
    // dart:io 的 XFile 忽略 name 参数；不要把插件缓存前缀当作原文件名。
    final title = asset?.title;
    return MediaUploadInput.fromPickedSource(
      PickedMediaSource.file(
        filename: title == null || title.trim().isEmpty
            ? input.filename
            : title,
        path: file.path,
        length: input.byteLength,
        declaredContentType: input.declaredContentType,
        purpose: purpose,
      ),
    );
  }
}
