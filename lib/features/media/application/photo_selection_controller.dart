import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class PhotoSelectionController extends ChangeNotifier {
  PhotoSelectionController({required this.library, required this.request});
  final PhotoLibrary library;
  final PhotoSelectionRequest request;
  static const pageSize = 80;
  PhotoLibraryAccess? access;
  List<LocalPhotoAlbum> albums = [];
  LocalPhotoAlbum? album;
  List<LocalPhoto> photos = [];
  final _selected = <String, LocalPhoto>{};
  List<LocalPhoto> get selected => List.unmodifiable(_selected.values);
  int number(LocalPhoto photo) => _selected.keys.toList().indexOf(photo.id) + 1;
  bool loading = false;
  bool loadingPage = false;
  bool confirming = false;
  bool hasMore = false;
  String? error;
  String? pageError;
  int _page = 0;
  int _revision = 0;
  bool _disposed = false;
  bool get accessible =>
      access == PhotoLibraryAccess.full || access == PhotoLibraryAccess.limited;
  bool get busy => loading || confirming;

  bool _current(int revision) => !_disposed && revision == _revision;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> refresh({
    bool requestPermission = false,
    bool selectMore = false,
  }) async {
    if (confirming || loading) return;
    final revision = ++_revision;
    loading = true;
    loadingPage = false;
    error = null;
    pageError = null;
    // 返回前台时立即撤掉旧图库，不沿用可能已经撤销的授权。
    photos = [];
    albums = [];
    _emit();
    try {
      if (selectMore) await library.selectMore();
      final permission = await library.permission(request: requestPermission);
      if (!_current(revision)) return;
      access = permission;
      if (!accessible) {
        album = null;
        _selected.clear();
        return;
      }
      final available = await library.albums();
      if (!_current(revision)) return;
      albums = available;
      album =
          available.where((item) => item.id == album?.id).firstOrNull ??
          available.firstOrNull;
      for (final photo in selected) {
        final exists = await library.exists(photo);
        if (!_current(revision)) return;
        if (!exists) _selected.remove(photo.id);
      }
      _page = 0;
      hasMore = album != null;
    } on Object {
      if (_current(revision)) error = '加载失败，请重试。';
    } finally {
      if (_current(revision)) {
        loading = false;
        _emit();
      }
    }
    if (_current(revision) && error == null && accessible) await loadMore();
  }

  Future<void> switchAlbum(LocalPhotoAlbum next) async {
    if (busy || album?.id == next.id) return;
    ++_revision;
    album = next;
    photos = [];
    _page = 0;
    hasMore = true;
    loadingPage = false;
    pageError = null;
    error = null;
    _emit();
    await loadMore();
  }

  Future<void> loadMore() async {
    final currentAlbum = album;
    if (busy || loadingPage || !hasMore || currentAlbum == null) return;
    final revision = _revision;
    loadingPage = true;
    pageError = null;
    _emit();
    try {
      final items = await library.photos(
        currentAlbum.id,
        page: _page,
        size: pageSize,
      );
      if (!_current(revision)) return;
      final seen = photos.map((item) => item.id).toSet();
      photos = [...photos, ...items.where((item) => seen.add(item.id))];
      _page++;
      hasMore = items.length == pageSize;
    } on Object {
      if (_current(revision)) pageError = '加载失败，请重试。';
    } finally {
      if (_current(revision)) {
        loadingPage = false;
        _emit();
      }
    }
  }

  void toggle(LocalPhoto photo) {
    if (busy || !accessible) return;
    error = null;
    if (_selected.containsKey(photo.id)) {
      _selected.remove(photo.id);
    } else if (_selected.length < request.limit) {
      _selected[photo.id] = photo;
    } else {
      error = '最多选择 ${request.limit} 张图片。';
    }
    _emit();
  }

  Future<List<MediaUploadInput>?> confirm() async {
    if (busy || _selected.isEmpty) return null;
    final revision = _revision;
    confirming = true;
    error = null;
    _emit();
    try {
      final permission = await library.permission(request: false);
      if (!_current(revision)) return null;
      access = permission;
      if (!accessible) {
        _selected.clear();
        photos = [];
        albums = [];
        throw PhotoLibraryFailure.permissionRevoked;
      }
      final inputs = <MediaUploadInput>[];
      for (final photo in selected) {
        if (!await library.exists(photo)) {
          if (!_current(revision)) return null;
          _selected.remove(photo.id);
          throw PhotoLibraryFailure.unavailable;
        }
        if (!_current(revision)) return null;
        final input = await library.resolve(photo, request.purpose);
        if (!_current(revision)) return null;
        inputs.add(input);
      }
      // 云端照片读取可能跨越一次前后台切换，交付前再次核验读取授权。
      final finalPermission = await library.permission(request: false);
      if (!_current(revision)) return null;
      access = finalPermission;
      if (!accessible) {
        _selected.clear();
        photos = [];
        albums = [];
        throw PhotoLibraryFailure.permissionRevoked;
      }
      return inputs;
    } on Object catch (failure) {
      if (_current(revision)) {
        error = switch (failure) {
          PhotoLibraryFailure.permissionRevoked => '照片读取权限已关闭，请重新允许或使用系统选择。',
          PhotoLibraryFailure.unavailable => '图片已删除或无法读取，请重新选择。',
          ApiFailure apiFailure => apiFailure.userMessage,
          _ => '选择图片失败，请重试或更换图片。',
        };
      }
      return null;
    } finally {
      if (_current(revision)) {
        confirming = false;
        _emit();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_revision;
    super.dispose();
  }
}
