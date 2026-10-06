import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_mention_target.dart';
import 'package:wenyousite_mobile/core/network/media_display_mapper.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

RpIdentity? mapRpIdentity(RpIdentityResponseDto? dto) => dto == null
    ? null
    : RpIdentity(
        id: dto.id,
        nickname: dto.nickname,
        avatarUrl: mapAvatarDisplayUrl(dto.avatar, dto.avatarDisplay),
      );

/// 原链接与原称呼共同定位节点；同账号同名的多个角色不可互相覆盖。
Map<String, String> mapMentionIdentityLabels(
  Iterable<MentionIdentityDisplayDto>? values,
) {
  final result = <String, String>{};
  for (final value in values ?? const <MentionIdentityDisplayDto>[]) {
    final target = MarkdownMentionTarget.parse(
      value.sourceHref ?? '/users/${value.userId}',
    );
    if (target == null ||
        target.userId != value.userId ||
        (value.sourceHref != null &&
            target.identityId != value.targetIdentityId)) {
      continue;
    }
    result[target.projectionKey(value.label)] = value.displayName;
  }
  return Map.unmodifiable(result);
}
