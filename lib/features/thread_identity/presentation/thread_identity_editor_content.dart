import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_edit_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_feedback.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_summary.dart';

/// 表单内容由调用方持有，提交失败或权限改变时不会重建并丢失输入。
class ThreadIdentityEditorContent extends StatelessWidget {
  const ThreadIdentityEditorContent({
    required this.nicknameController,
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
    this.onReviewIdentities,
    super.key,
  });

  final TextEditingController nicknameController;
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
  final VoidCallback? onReviewIdentities;
  final ValueChanged<String> onNicknameChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final enabled = canEdit && !isBusy;
    final nicknameError = validateThreadIdentityNickname(
      nicknameController.text,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ThreadIdentitySummary(
          name: previewName,
          avatar: WenyouAvatarEditButton(
            key: const Key('thread-identity-pick-avatar'),
            username: previewName,
            avatarUrl: previewAvatarUrl,
            label: hasCustomAvatar ? '更换帖内头像' : '选择帖内头像',
            onPressed: enabled ? onSelectAvatar : null,
          ),
        ),
        if (hasCustomAvatar)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              key: const Key('thread-identity-clear-avatar'),
              onPressed: enabled ? onClearAvatar : null,
              child: const Text('沿用站内头像'),
            ),
          ),
        SizedBox(height: tokens.space16),
        TextField(
          key: const Key('thread-identity-nickname'),
          controller: nicknameController,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: '帖内昵称',
            hintText: '留空沿用站内昵称',
            errorText: nicknameError,
            errorMaxLines: 3,
            counterText: maxNicknameLength == null
                ? null
                : '${nicknameController.text.trim().runes.length}/$maxNicknameLength',
          ),
          onChanged: onNicknameChanged,
        ),
        if (!canEdit) ...[
          SizedBox(height: tokens.space12),
          const WenyouStatusBanner(message: '当前无法设置帖内身份，已保留你的输入。'),
        ],
        if (errorMessage case final message?) ...[
          SizedBox(height: tokens.space12),
          WenyouStatusBanner(
            key: const Key('thread-identity-editor-error'),
            message: message,
            tone: WenyouStatusTone.error,
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
          onPressed: enabled && nicknameError == null ? onSave : null,
          child: Text(isBusy ? '正在保存…' : '保存帖内身份'),
        ),
        if (onReviewIdentities != null)
          TextButton(
            onPressed: !isBusy ? onReviewIdentities : null,
            child: const Text('返回身份列表'),
          ),
        if (hasSavedIdentity)
          TextButton(
            key: const Key('thread-identity-clear'),
            onPressed: !isBusy ? onClear : null,
            child: const Text('删除身份'),
          ),
      ],
    );
  }
}
