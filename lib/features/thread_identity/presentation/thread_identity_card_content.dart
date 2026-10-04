import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';

/// 仅接收已授权的展示资料；历史身份不会覆盖账号操作的真实目标。
class ThreadIdentityCardContent extends StatelessWidget {
  const ThreadIdentityCardContent({
    required this.accountName,
    required this.identityEnabled,
    required this.onOpenAccount,
    this.accountAvatarUrl,
    this.historicalName,
    this.historicalAvatarUrl,
    this.currentName,
    this.currentAvatarUrl,
    this.roleLabel,
    this.fromPost = false,
    this.onMention,
    this.onOnlyThisUser,
    super.key,
  });

  final String accountName;
  final String? accountAvatarUrl;
  final bool identityEnabled;
  final String? historicalName;
  final String? historicalAvatarUrl;
  final String? currentName;
  final String? currentAvatarUrl;
  final String? roleLabel;
  final bool fromPost;
  final VoidCallback onOpenAccount;
  final VoidCallback? onMention;
  final VoidCallback? onOnlyThisUser;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final history = identityEnabled ? historicalName : null;
    final current = identityEnabled ? currentName : null;
    final name = history ?? (fromPost ? accountName : current ?? accountName);
    final avatar = history != null
        ? historicalAvatarUrl
        : current != null && !fromPost
        ? currentAvatarUrl
        : accountAvatarUrl;
    final changed =
        (fromPost || history != null) &&
        (name != (current ?? accountName) ||
            avatar != (current == null ? accountAvatarUrl : currentAvatarUrl));
    return Column(
      key: const Key('thread-identity-card-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WenyouAvatar(username: name, avatarUrl: avatar, size: 48),
            SizedBox(width: tokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (history != null || fromPost)
                    Text(
                      '本条发言身份',
                      style: Theme.of(context).textTheme.wenyouCaption.copyWith(
                        color: tokens.mutedText,
                      ),
                    ),
                  Text(name, style: Theme.of(context).textTheme.wenyouRowTitle),
                  if (history != null || current != null)
                    Text(
                      '站内账号：$accountName',
                      style: Theme.of(context).textTheme.wenyouCaption.copyWith(
                        color: tokens.mutedText,
                      ),
                    ),
                  if (roleLabel case final role?)
                    Text(
                      role,
                      style: Theme.of(context).textTheme.wenyouCaption,
                    ),
                ],
              ),
            ),
          ],
        ),
        if (changed) ...[
          SizedBox(height: tokens.space12),
          Text(
            current == null ? '当前使用站内资料' : '当前帖内身份：$current',
            key: const Key('thread-identity-current-name'),
            style: Theme.of(context).textTheme.wenyouCaption,
          ),
        ],
        SizedBox(height: tokens.space16),
        Wrap(
          spacing: tokens.space8,
          runSpacing: tokens.space8,
          children: [
            if (onMention != null)
              OutlinedButton.icon(
                key: const Key('thread-identity-mention'),
                onPressed: onMention,
                icon: const WenyouIcon(WenyouIconIds.actionMention),
                label: const Text('提及'),
              ),
            if (onOnlyThisUser != null)
              OutlinedButton.icon(
                key: const Key('thread-identity-filter'),
                onPressed: onOnlyThisUser,
                icon: const WenyouIcon(WenyouIconIds.actionFilter),
                label: const Text('只看此人'),
              ),
          ],
        ),
        SizedBox(height: tokens.space8),
        TextButton.icon(
          key: const Key('thread-identity-open-account'),
          onPressed: onOpenAccount,
          icon: const WenyouIcon(WenyouIconIds.navigationNext),
          label: const Text('查看站内主页'),
        ),
      ],
    );
  }
}
