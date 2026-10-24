import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

enum PhotoLibraryAccess { full, limited, denied, restricted }

enum PhotoLibraryFailure implements Exception { permissionRevoked, unavailable }

class LocalPhoto {
  const LocalPhoto(this.id);
  final String id;
}

class LocalPhotoAlbum {
  const LocalPhotoAlbum({
    required this.id,
    required this.name,
    required this.count,
    this.cover,
    this.isRecent = false,
  });
  final String id;
  final String name;
  final int count;
  final LocalPhoto? cover;
  final bool isRecent;
}

abstract interface class PhotoLibrary {
  Future<PhotoLibraryAccess> permission({required bool request});
  Future<void> selectMore();
  Future<void> openSettings();
  Future<List<LocalPhotoAlbum>> albums();
  Future<List<LocalPhoto>> photos(
    String albumId, {
    required int page,
    required int size,
  });
  Future<Uint8List?> thumbnail(
    LocalPhoto photo, {
    required int size,
    bool preserveAspect = false,
  });
  Future<bool> exists(LocalPhoto photo);
  Future<MediaUploadInput> resolve(
    LocalPhoto photo,
    MediaUploadPurpose purpose,
  );
}

final photoLibraryProvider = Provider<PhotoLibrary>((ref) {
  throw StateError('PhotoLibrary has not been bound at the app boundary.');
});

class PhotoSelectionRequest {
  const PhotoSelectionRequest({required this.limit, required this.purpose})
    : assert(limit > 0);
  final int limit;
  final MediaUploadPurpose purpose;
}

typedef PresentPhotoSelection =
    Future<List<MediaUploadInput>?> Function(PhotoSelectionRequest request);

/// 应用宿主绑定展示能力；数据适配器不保留调用页面的 BuildContext。
class PhotoSelectionCoordinator {
  PresentPhotoSelection? presenter;
  bool _busy = false;

  Future<List<MediaUploadInput>?> pick(PhotoSelectionRequest request) async {
    final present = presenter;
    if (_busy) return null;
    if (present == null) {
      throw StateError('Photo selection host is not bound.');
    }
    _busy = true;
    try {
      return await present(request);
    } finally {
      _busy = false;
    }
  }
}

final photoSelectionCoordinatorProvider = Provider(
  (ref) => PhotoSelectionCoordinator(),
);
