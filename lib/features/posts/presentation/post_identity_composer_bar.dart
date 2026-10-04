import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_selection.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

class PostIdentityComposerBar extends StatelessWidget {
  const PostIdentityComposerBar({
    required this.selection,
    required this.locked,
    required this.onSettings,
    super.key,
  });
  final PostIdentitySelection selection;
  final bool locked;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: selection,
    builder: (context, _) {
      final identity = selection.identity;
      final tokens = context.wenyouTokens;
      if (identity == null) {
        return ListTile(
          dense: true,
          title: Text(selection.failure == null ? '正在读取发表身份…' : '发表身份加载失败'),
          trailing: selection.failure == null
              ? null
              : TextButton(
                  onPressed: locked ? null : selection.refresh,
                  child: const Text('重试'),
                ),
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.space12),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<PostIdentityMode>(
                  key: const Key('post-composer-identity-mode'),
                  value: selection.mode,
                  isExpanded: true,
                  onChanged: locked || selection.loading
                      ? null
                      : (value) {
                          if (value != null) selection.select(value);
                        },
                  selectedItemBuilder: (context) => [
                    for (final mode in PostIdentityMode.values)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _option(context, mode, selected: true),
                      ),
                  ],
                  items: [
                    DropdownMenuItem(
                      value: PostIdentityMode.account,
                      child: _option(context, PostIdentityMode.account),
                    ),
                    DropdownMenuItem(
                      value: PostIdentityMode.rp,
                      enabled: identity.hasRp,
                      child: _option(context, PostIdentityMode.rp),
                    ),
                  ],
                ),
              ),
            ),
            if (identity.canEdit)
              TextButton(
                key: const Key('post-composer-identity-settings'),
                onPressed: locked || selection.loading ? null : onSettings,
                child: const Text('设置'),
              ),
          ],
        ),
      );
    },
  );

  Widget _option(
    BuildContext context,
    PostIdentityMode mode, {
    bool selected = false,
  }) {
    final identity = selection.identity!;
    final rp = mode == PostIdentityMode.rp;
    final name = rp ? identity.displayName : identity.accountName;
    final title = rp ? '帖内身份' : '站内身份';
    final label = rp && selection.changed && selected
        ? '帖内身份已变化，发表前需确认'
        : rp && !identity.hasRp
        ? '帖内身份（暂不可用）'
        : selected
        ? '以$title「$name」发表'
        : '$title · $name';
    return Row(
      children: [
        WenyouAvatar(
          username: name,
          avatarUrl: rp
              ? identity.display?.avatarUrl
              : identity.accountAvatarUrl,
          size: 24,
        ),
        SizedBox(width: context.wenyouTokens.space8),
        Expanded(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
