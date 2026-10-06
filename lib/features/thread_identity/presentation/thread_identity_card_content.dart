import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_summary.dart';

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
    this.profile,
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
  final Widget? profile;
  final VoidCallback onOpenAccount;

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
    final hasRp = history != null || (!fromPost && current != null);
    final account = Semantics(
      button: true,
      label: '查看 $accountName 的个人主页',
      excludeSemantics: true,
      onTap: onOpenAccount,
      child: InkWell(
        key: const Key('thread-identity-open-account'),
        onTap: onOpenAccount,
        borderRadius: BorderRadius.circular(tokens.radiusControl),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.space8),
            child: ThreadIdentitySummary(
              name: accountName,
              avatarUrl: accountAvatarUrl,
              avatarSize: hasRp ? 32 : 48,
              supportingText: hasRp ? null : roleLabel,
              trailing: const WenyouIcon(
                WenyouIconIds.navigationNext,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
    return Column(
      key: const Key('thread-identity-card-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        account,
        if (hasRp) ...[
          Divider(height: 1, color: tokens.border),
          SizedBox(height: tokens.space16),
          ThreadIdentitySummary(
            name: name,
            avatarUrl: avatar,
            avatarSize: 48,
            nameBadge: roleLabel,
            supportingText: '帖内身份',
          ),
          if (profile != null) ...[SizedBox(height: tokens.space16), profile!],
        ],
      ],
    );
  }
}
