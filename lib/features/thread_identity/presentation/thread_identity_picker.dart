import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_summary.dart';

enum _Action { account, identity, edit, create }

typedef _Choice = ({_Action action, String? identityId});

/// 身份选择和行尾编辑共享同一菜单；只返回稳定 ID，不修改资料或草稿。
class ThreadIdentityPicker extends StatelessWidget {
  const ThreadIdentityPicker({
    required this.accountName,
    required this.identities,
    required this.selectedIdentityId,
    required this.canEdit,
    required this.limit,
    required this.enabled,
    required this.onSelected,
    required this.onEdit,
    required this.onCreate,
    this.accountAvatarUrl,
    this.unconfiguredIdentityIds = const {},
    super.key,
  });

  final String accountName;
  final String? accountAvatarUrl;
  final List<RpIdentity> identities;
  final Set<String> unconfiguredIdentityIds;
  final String? selectedIdentityId;
  final bool canEdit;
  final int limit;
  final bool enabled;
  final ValueChanged<String?> onSelected;
  final ValueChanged<String> onEdit;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final byId = {for (final identity in identities) identity.id: identity};
    final selected = unconfiguredIdentityIds.contains(selectedIdentityId)
        ? null
        : byId[selectedIdentityId];
    final name = selected?.nickname ?? accountName;
    final modeLabel = selected == null ? '站内身份' : '帖内身份';
    final canCreate = canEdit && identities.length < limit;
    final canChoose = identities.isNotEmpty || canCreate;
    Widget summary({bool isOpen = false}) => ConstrainedBox(
      constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: ThreadIdentitySummary(
          name: name,
          avatarUrl: selected == null ? accountAvatarUrl : selected.avatarUrl,
          avatarSize: 28,
          maxNameLines: 1,
          trailing: canChoose
              ? WenyouIcon(
                  isOpen
                      ? WenyouIconIds.navigationCollapse
                      : WenyouIconIds.navigationExpand,
                  size: 16,
                  color: enabled ? tokens.text : tokens.mutedText,
                )
              : null,
        ),
      ),
    );
    if (!canChoose) return summary();
    return WenyouSelectionMenu<_Choice>(
      key: const Key('post-composer-identity-mode'),
      selected: (
        action: selected == null ? _Action.account : _Action.identity,
        identityId: selected?.id,
      ),
      enabled: enabled,
      tooltip: '选择本次发表身份',
      optionKeyPrefix: 'post-identity-option',
      showScrollIndicator: identities.isNotEmpty,
      optionMaxLines: 1,
      optionTrailingBuilder: !canEdit
          ? null
          : (menuContext, choice) => choice.identityId != null
                ? IconButton(
                    key: Key('thread-identity-edit-${choice.identityId}'),
                    tooltip: '编辑${byId[choice.identityId]!.nickname}',
                    onPressed: () => Navigator.of(menuContext).pop<_Choice>((
                      action: _Action.edit,
                      identityId: choice.identityId,
                    )),
                    icon: const WenyouIcon(WenyouIconIds.actionEdit, size: 20),
                  )
                : null,
      optionLeadingBuilder: (_, choice) {
        if (choice.action == _Action.create) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.softPanel,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: WenyouIcon(WenyouIconIds.actionAdd, size: 20),
            ),
          );
        }
        final identity = byId[choice.identityId];
        return WenyouAvatar(
          username: identity?.nickname ?? accountName,
          avatarUrl: identity == null ? accountAvatarUrl : identity.avatarUrl,
          size: 32,
        );
      },
      options: [
        for (final identity in identities)
          WenyouFilterOption(
            value: (
              action: unconfiguredIdentityIds.contains(identity.id)
                  ? _Action.edit
                  : _Action.identity,
              identityId: identity.id,
            ),
            keyValue: 'rp-${identity.id}',
            label: identity.nickname,
          ),
        WenyouFilterOption(
          value: (action: _Action.account, identityId: null),
          keyValue: 'account',
          label: accountName,
        ),
        if (canCreate)
          const WenyouFilterOption(
            value: (action: _Action.create, identityId: null),
            keyValue: 'settings',
            label: '新增身份',
          ),
      ],
      onSelected: (choice) {
        if (!enabled) return;
        switch (choice.action) {
          case _Action.account:
            onSelected(null);
          case _Action.identity:
            onSelected(choice.identityId);
          case _Action.edit:
            onEdit(choice.identityId!);
          case _Action.create:
            onCreate();
        }
      },
      anchorBuilder: (_, isOpen) => Semantics(
        label: '以$modeLabel「$name」发表',
        child: summary(isOpen: isOpen),
      ),
    );
  }
}
