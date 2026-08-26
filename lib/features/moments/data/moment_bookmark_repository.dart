import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_bookmark_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

export 'package:wenyousite_mobile/features/moments/application/moment_bookmark_repository_ports.dart'
    show MomentBookmarkRepository, momentBookmarkRepositoryProvider;

class ApiMomentBookmarkRepository implements MomentBookmarkRepository {
  ApiMomentBookmarkRepository(this._api, this._moments);

  final MomentsApi _api;
  final MomentRepository _moments;

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() async {
    try {
      final envelope = (await _api.momentsBookmarkFolders()).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '动态收藏夹加载失败，请稍后重试。');
      }
      return envelope.data.map(_mapFolder).toList(growable: false);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<BookmarkFolderItem> createFolder(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty || normalized.length > 24) {
      throw const ApiFailure(userMessage: '收藏夹名称需为 1–24 个字符。');
    }
    try {
      final envelope = (await _api.momentsCreateBookmarkFolder(
        createMomentBookmarkFolderDto: CreateMomentBookmarkFolderDto(
          (builder) => builder.name = normalized,
        ),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '新建动态收藏夹失败，请重试。');
      }
      return _mapFolder(envelope.data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: const {40900: '已有同名收藏夹，请换一个名称。'},
      );
    }
  }

  @override
  Future<CursorPage<MomentCard>> fetchPage({
    required String folderId,
    String? cursor,
    int limit = 20,
  }) {
    return _moments.fetchBookmarks(
      folderId: folderId,
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
    String? folderId,
  }) {
    return _moments.setBookmark(momentId, active: active, folderId: folderId);
  }

  @override
  Future<void> moveBookmark(String momentId, String folderId) {
    return _moments.moveBookmark(momentId, folderId);
  }

  BookmarkFolderItem _mapFolder(MomentBookmarkFolderResponseDto dto) {
    final id = dto.id.trim();
    final name = dto.name.trim();
    if (id.isEmpty || name.isEmpty) {
      throw const ApiFailure(userMessage: '动态收藏夹加载失败，请稍后重试。');
    }
    return BookmarkFolderItem(
      id: id,
      name: name,
      isDefault: dto.isDefault,
      bookmarkCount: dto.momentBookmarkCount.toInt(),
      createdAt: dto.createdAt,
    );
  }
}

final apiMomentBookmarkRepositoryProvider = Provider<MomentBookmarkRepository>((
  ref,
) {
  return ApiMomentBookmarkRepository(
    ref.watch(wenyouApiProvider).getMomentsApi(),
    ref.watch(apiMomentRepositoryProvider),
  );
});
