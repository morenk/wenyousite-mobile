import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_dto_mapper.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_response_contract_validator.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

/// 将动态搜索 DTO 收敛为与动态信息流共享的展示模型。
///
/// 搜索 DTO 与卡片 DTO 字段相同但不是同一生成类型，因此这里继续执行与
/// Moments 仓储一致的 fail-closed 校验，避免搜索页绕过封面和 URL 约束。
class MomentSearchMapper {
  static const _contract = MomentResponseContractValidator.search();
  static const _mapper = MomentDtoMapper(_contract);
  const MomentSearchMapper._();

  static MomentCard map(MomentSearchResponseDto dto) {
    final id = _requiredText(dto.id, '动态 ID');
    final author = _mapper.author(dto.author);
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
    final cover = dto.coverMedia == null
        ? null
        : _mapper.media(dto.coverMedia!);
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
    if (title.runes.length < 2 || title.runes.length > 40) {
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
      canInteract: dto.canInteract ?? true,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static String _requiredText(String value, String label) =>
      _contract.requiredText(value, label);
  static int _nonNegativeInteger(num value, String label) =>
      _contract.nonNegativeInteger(value, label);
}
