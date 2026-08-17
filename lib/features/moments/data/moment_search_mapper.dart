import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

/// 将动态搜索 DTO 收敛为与动态信息流共享的展示模型。
///
/// 搜索 DTO 与卡片 DTO 字段相同但不是同一生成类型，因此这里继续执行与
/// Moments 仓储一致的 fail-closed 校验，避免搜索页绕过封面和 URL 约束。
class MomentSearchMapper {
  const MomentSearchMapper._();

  static MomentCard map(MomentSearchResponseDto dto) {
    final id = _requiredText(dto.id, '动态 ID');
    final author = _author(dto.author);
    if (_requiredText(dto.authorId, '动态作者 ID') != author.id) {
      throw const ApiFailure(userMessage: '动态作者信息不一致，请重新搜索。');
    }
    final coverType = switch (dto.coverType.name) {
      'IMAGE' => MomentCoverType.image,
      'TEXT' => MomentCoverType.text,
      _ => throw const ApiFailure(userMessage: '这张动态封面暂时无法显示。'),
    };
    final textTheme = switch (dto.textCoverTheme.name) {
      'ROSE' => MomentTextCoverTheme.rose,
      'LILAC' => MomentTextCoverTheme.lilac,
      'MINT' => MomentTextCoverTheme.mint,
      'AMBER' => MomentTextCoverTheme.amber,
      _ => throw const ApiFailure(userMessage: '这张动态封面暂时无法显示。'),
    };
    final imageCount = _nonNegativeInteger(dto.imageCount, '动态图片数量');
    final cover = dto.coverMedia == null ? null : _media(dto.coverMedia!);
    if ((coverType == MomentCoverType.image && cover == null) ||
        (coverType == MomentCoverType.text && cover != null) ||
        (cover != null && imageCount < 1) ||
        imageCount > 9) {
      throw const ApiFailure(userMessage: '动态封面加载失败，请重新搜索。');
    }
    if (!RegExp(r'^(?:0|[1-9]\d*)$').hasMatch(dto.tipTotal)) {
      throw const ApiFailure(userMessage: '搜索结果的动态加油数值无效，请重新搜索。');
    }
    final title = _requiredText(dto.title, '动态标题');
    if (title.length < 2 || title.length > 40) {
      throw const ApiFailure(userMessage: '搜索结果的动态标题长度无效，请重新搜索。');
    }
    return MomentCard(
      id: id,
      author: author,
      title: title,
      contentExcerpt: dto.contentExcerpt.trim(),
      coverType: coverType,
      textCoverTheme: textTheme,
      coverMedia: cover,
      imageCount: imageCount,
      likeCount: _nonNegativeInteger(dto.likeCount, '动态点赞数'),
      commentCount: _nonNegativeInteger(dto.commentCount, '动态评论数'),
      bookmarkCount: _nonNegativeInteger(dto.bookmarkCount, '动态收藏数'),
      tipTotal: dto.tipTotal,
      viewerLiked: dto.viewerLiked,
      viewerBookmarked: dto.viewerBookmarked,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static MomentAuthor _author(PostAuthorResponseDto dto) {
    return MomentAuthor(
      id: _requiredText(dto.id, '作者 ID'),
      username: _requiredText(dto.username, '作者用户名'),
      avatarUrl: _optionalHttpUri(dto.avatar, '作者头像'),
      level: _nonNegativeInteger(dto.level, '作者等级'),
    );
  }

  static MomentMedia _media(MomentMediaResponseDto dto) {
    final width = _optionalPositiveInteger(dto.width, '图片宽度');
    final height = _optionalPositiveInteger(dto.height, '图片高度');
    if ((width == null) != (height == null)) {
      throw const ApiFailure(userMessage: '图片加载失败，请重新搜索。');
    }
    return MomentMedia(
      id: _requiredText(dto.id, '图片 ID'),
      url: _requiredHttpUri(dto.url, '图片地址'),
      thumbnailUrl: _optionalHttpUri(dto.thumbnailUrl, '图片缩略图地址'),
      feedUrl: _optionalHttpUri(dto.feedUrl, '图片列表地址'),
      mediumUrl: _optionalHttpUri(dto.mediumUrl, '图片预览地址'),
      width: width,
      height: height,
    );
  }

  static String _requiredText(String value, String label) {
    final normalized = value.trim();
    if (normalized.isEmpty) throw ApiFailure(userMessage: '$label不能为空。');
    return normalized;
  }

  static String _requiredHttpUri(String value, String label) {
    return _safeHttpUri(value, label).toString();
  }

  static String? _optionalHttpUri(String? value, String label) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return _safeHttpUri(normalized, label).toString();
  }

  static Uri _safeHttpUri(String value, String label) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw ApiFailure(userMessage: '$label不安全，请重新搜索。');
    }
    return uri;
  }

  static int _nonNegativeInteger(num value, String label) {
    final integer = value.toInt();
    if (!value.isFinite || integer != value || integer < 0) {
      throw ApiFailure(userMessage: '$label无效，请重新搜索。');
    }
    return integer;
  }

  static int? _optionalPositiveInteger(num? value, String label) {
    if (value == null) return null;
    final integer = value.toInt();
    if (!value.isFinite || integer != value || integer < 1) {
      throw ApiFailure(userMessage: '$label无效，请重新搜索。');
    }
    return integer;
  }
}
