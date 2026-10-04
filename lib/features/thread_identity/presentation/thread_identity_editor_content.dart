import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';

/// 表单内容由调用方持有，提交失败或权限改变时不会重建并丢失输入。
class ThreadIdentityEditorContent extends StatelessWidget {
  const ThreadIdentityEditorContent({
    required this.nicknameController,
    required this.accountName,
    required this.previewName,
    required this.canEdit,
    required this.isBusy,
    required this.onSelectAvatar,
    required this.onClearAvatar,
    required this.onSave,
    required this.onClear,
    required this.onNicknameChanged,
    this.previewAvatarUrl,
    this.hasCustomAvatar = false,
    this.hasSavedIdentity = false,
    this.errorMessage,
    this.progressLabel,
    this.maxNicknameLength,
    super.key,
  });

  final TextEditingController nicknameController;
  final String accountName;
  final String previewName;
  final String? previewAvatarUrl;
  final bool canEdit;
  final bool isBusy;
  final bool hasCustomAvatar;
  final bool hasSavedIdentity;
  final String? errorMessage;
  final String? progressLabel;
  final int? maxNicknameLength;
  final VoidCallback onSelectAvatar;
  final VoidCallback onClearAvatar;
  final VoidCallback onSave;
  final VoidCallback onClear;
  final ValueChanged<String> onNicknameChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final enabled = canEdit && !isBusy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WenyouAvatar(
              username: previewName,
              avatarUrl: previewAvatarUrl,
              size: 48,
            ),
            SizedBox(width: tokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    previewName,
                    style: Theme.of(context).textTheme.wenyouRowTitle,
                  ),
                  Text(
                    '站内账号：$accountName',
                    style: Theme.of(context).textTheme.wenyouCaption,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.space8),
        Wrap(
          spacing: tokens.space8,
          children: [
            TextButton(
              key: const Key('thread-identity-pick-avatar'),
              onPressed: enabled ? onSelectAvatar : null,
              child: const Text('选择帖内头像'),
            ),
            if (hasCustomAvatar)
              TextButton(
                key: const Key('thread-identity-clear-avatar'),
                onPressed: enabled ? onClearAvatar : null,
                child: const Text('沿用站内头像'),
              ),
          ],
        ),
        SizedBox(height: tokens.space8),
        TextField(
          key: const Key('thread-identity-nickname'),
          controller: nicknameController,
          enabled: enabled,
          maxLength: maxNicknameLength,
          decoration: InputDecoration(
            labelText: '帖内昵称',
            hintText: '留空沿用站内昵称',
            helperText: '仅用于本主题及其全部子贴',
            helperMaxLines: 2,
            counterText: maxNicknameLength == null
                ? null
                : '${nicknameController.text.trim().runes.length}/$maxNicknameLength',
          ),
          onChanged: onNicknameChanged,
        ),
        SizedBox(height: tokens.space12),
        Text(
          '保存后用于之后的发言，已有发言的身份保持不变。其他人可以通过身份卡查看你的站内账号。',
          style: Theme.of(context).textTheme.wenyouCaption,
        ),
        if (!canEdit) ...[
          SizedBox(height: tokens.space12),
          const Text('当前无法设置帖内身份，已保留你的输入。'),
        ],
        if (errorMessage case final message?) ...[
          SizedBox(height: tokens.space12),
          Text(
            message,
            key: const Key('thread-identity-editor-error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (isBusy && progressLabel != null) ...[
          SizedBox(height: tokens.space8),
          Text(
            progressLabel!,
            style: Theme.of(context).textTheme.wenyouCaption,
          ),
        ],
        SizedBox(height: tokens.space16),
        FilledButton(
          key: const Key('thread-identity-save'),
          onPressed: enabled ? onSave : null,
          child: Text(isBusy ? '正在保存…' : '保存帖内身份'),
        ),
        if (hasSavedIdentity)
          TextButton(
            key: const Key('thread-identity-clear'),
            onPressed: !isBusy ? onClear : null,
            child: const Text('清除帖内资料'),
          ),
      ],
    );
  }
}
