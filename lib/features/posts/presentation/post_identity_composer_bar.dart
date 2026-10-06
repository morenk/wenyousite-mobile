import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_feedback.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_selection.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';

class PostIdentityComposerBar extends StatelessWidget {
  const PostIdentityComposerBar({
    required this.selection,
    required this.locked,
    required this.onSettings,
    super.key,
  });
  final PostIdentitySelection selection;
  final bool locked;
  final ValueChanged<String?> onSettings;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: selection,
    builder: (context, _) {
      final identity = selection.identity;
      final tokens = context.wenyouTokens;
      final enabled = !locked && !selection.loading;
      if (identity == null) {
        return Padding(
          padding: EdgeInsets.all(tokens.space12),
          child: WenyouStatusBanner(
            message: selection.failure == null ? '正在读取发表身份…' : '发表身份加载失败',
            tone: selection.failure == null
                ? WenyouStatusTone.neutral
                : WenyouStatusTone.error,
            action: selection.failure == null
                ? null
                : TextButton(
                    onPressed: enabled ? selection.refresh : null,
                    child: const Text('重试'),
                  ),
          ),
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ThreadIdentityPicker(
            accountName: identity.accountName,
            accountAvatarUrl: identity.accountAvatarUrl,
            identities: [
              for (final role in selection.collection!.identities)
                role.display ??
                    RpIdentity(
                      id: role.identityId!,
                      nickname: role.nickname ?? '未设置',
                    ),
            ],
            unconfiguredIdentityIds: {
              for (final role in selection.collection!.identities)
                if (!role.hasRp) role.identityId!,
            },
            selectedIdentityId: selection.mode == PostIdentityMode.rp
                ? selection.identityId
                : null,
            canEdit: identity.canEdit,
            limit: selection.collection!.limit,
            enabled: enabled,
            onSelected: (id) => selection.select(
              id == null ? PostIdentityMode.account : PostIdentityMode.rp,
              id: id,
            ),
            onEdit: onSettings,
            onCreate: () => onSettings(null),
          ),
          if (!locked && selection.failure != null) ...[
            SizedBox(height: tokens.space4),
            WenyouStatusBanner(
              key: const Key('post-composer-identity-notice'),
              message: '发表身份加载失败，已保留当前选择。',
              tone: WenyouStatusTone.error,
              action: TextButton(
                onPressed: enabled ? selection.refresh : null,
                child: const Text('重试'),
              ),
            ),
          ],
        ],
      );
    },
  );
}
