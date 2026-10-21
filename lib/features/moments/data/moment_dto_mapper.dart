import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/media_display_mapper.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_response_contract_validator.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

/// 两种卡片 DTO 的作者和图片类型相同；入口错误标签及诊断仍由校验策略决定。
class MomentDtoMapper {
  const MomentDtoMapper(this._contract);
  final MomentResponseContractValidator _contract;
  MomentAuthor author(PostAuthorResponseDto dto) {
    return MomentAuthor(
      id: _contract.requiredText(dto.id, '作者 ID'),
      username: _contract.requiredText(dto.username, '作者用户名'),
      avatarUrl: _contract.optionalHttpUri(
        mapAvatarDisplayUrl(dto.avatar, dto.avatarDisplay),
        '作者头像',
      ),
      level: _contract.nonNegativeInteger(dto.level, '作者等级'),
    );
  }

  MomentMedia media(MomentMediaResponseDto dto) {
    final width = _contract.optionalPositiveInteger(dto.width, '图片宽度');
    final height = _contract.optionalPositiveInteger(dto.height, '图片高度');
    if ((width == null) != (height == null)) {
      _contract.violation(
        'MOMENT_MEDIA_DIMENSION_MISMATCH',
        userMessage: _contract.mediaFailureMessage,
      );
    }
    return MomentMedia(
      display: mapMediaDisplay(dto.display),
      id: _contract.requiredText(dto.id, '图片 ID'),
      url: _contract.requiredHttpUri(dto.url, '图片地址'),
      thumbnailUrl: _contract.optionalHttpUri(dto.thumbnailUrl, '图片缩略图地址'),
      feedUrl: _contract.optionalHttpUri(dto.feedUrl, '图片列表地址'),
      mediumUrl: _contract.optionalHttpUri(dto.mediumUrl, '图片预览地址'),
      contentType: dto.contentType?.trim(),
      animated: dto.animated,
      width: width,
      height: height,
    );
  }
}
