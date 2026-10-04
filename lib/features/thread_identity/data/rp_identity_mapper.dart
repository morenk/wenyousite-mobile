import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/media_display_mapper.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

RpIdentity? mapRpIdentity(RpIdentityResponseDto? dto) => dto == null
    ? null
    : RpIdentity(
        id: dto.id,
        nickname: dto.nickname,
        avatarUrl: mapAvatarDisplayUrl(dto.avatar, dto.avatarDisplay),
      );

/// 同一账号可以在正文中有多个历史称呼；不能只按账号覆盖。
Map<String, String> mapMentionIdentityLabels(
  Iterable<MentionIdentityDisplayDto>? values,
) => Map.unmodifiable({
  for (final value in values ?? const <MentionIdentityDisplayDto>[])
    '${value.userId}\u0000${value.label}': value.displayName,
});
