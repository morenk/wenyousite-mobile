import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_compose_controller.dart';

enum ThreadRemoteDraftAction { save, open }

enum ThreadComposeMetadataPanel { category, visibility, tags }

class ThreadComposeMetadataBar extends StatelessWidget {
  const ThreadComposeMetadataBar({
    required this.categoryValue,
    required this.visibilityValue,
    required this.tagsValue,
    required this.activePanel,
    required this.enabled,
    required this.onPanelChanged,
    super.key,
  });

  final String categoryValue;
  final String visibilityValue;
  final String tagsValue;
  final ThreadComposeMetadataPanel? activePanel;
  final bool enabled;
  final ValueChanged<ThreadComposeMetadataPanel> onPanelChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Container(
      key: const Key('compose-publish-settings'),
      height: tokens.minimumTouchTarget,
      padding: EdgeInsets.symmetric(horizontal: tokens.space8),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: tokens.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetadataButton(
              key: const Key('compose-category'),
              icon: WenyouIconIds.contentCategory,
              title: '分类',
              value: categoryValue,
              selected: activePanel == ThreadComposeMetadataPanel.category,
              enabled: enabled,
              onPressed: () =>
                  onPanelChanged(ThreadComposeMetadataPanel.category),
            ),
          ),
          Expanded(
            child: _MetadataButton(
              key: const Key('compose-visibility'),
              icon: WenyouIconIds.actionShow,
              title: '可见性',
              value: visibilityValue,
              selected: activePanel == ThreadComposeMetadataPanel.visibility,
              enabled: enabled,
              onPressed: () =>
                  onPanelChanged(ThreadComposeMetadataPanel.visibility),
            ),
          ),
          Expanded(
            child: _MetadataButton(
              icon: WenyouIconIds.contentTag,
              title: '标签',
              value: tagsValue,
              selected: activePanel == ThreadComposeMetadataPanel.tags,
              enabled: enabled,
              onPressed: () => onPanelChanged(ThreadComposeMetadataPanel.tags),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataButton extends StatelessWidget {
  const _MetadataButton({
    required this.icon,
    required this.title,
    required this.value,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final String icon;
  final String title;
  final String value;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final semanticLabel = '$title：$value';
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Tooltip(
        message: title,
        child: TextButton.icon(
          onPressed: enabled ? onPressed : null,
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(
              Size(0, tokens.minimumTouchTarget),
            ),
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: tokens.space4),
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => selected && !states.contains(WidgetState.disabled)
                  ? tokens.accentedBackground
                  : Colors.transparent,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? tokens.mutedText
                  : selected
                  ? tokens.brandForeground
                  : tokens.text,
            ),
          ),
          icon: WenyouIcon(icon, size: 18),
          label: Text(
            '$title · $value',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}

class ThreadComposeStatusArea extends StatelessWidget {
  const ThreadComposeStatusArea({
    required this.state,
    required this.documentIssues,
    required this.codecFailure,
    required this.operationFailure,
    required this.uploadFailure,
    required this.uploadProgress,
    required this.uploading,
    required this.onCancelUpload,
    required this.onRetryUpload,
    required this.onRefreshBootstrap,
    super.key,
  });

  final ThreadComposeState state;
  final List<MarkdownCodecIssue> documentIssues;
  final String? codecFailure;
  final String? operationFailure;
  final MediaUploadFailure? uploadFailure;
  final MediaUploadProgress? uploadProgress;
  final bool uploading;
  final VoidCallback onCancelUpload;
  final VoidCallback onRetryUpload;
  final VoidCallback onRefreshBootstrap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final banners = <Widget>[
      if (state.action == ThreadComposeAction.openRemoteDraft)
        const WenyouStatusBanner(message: '正在读取云端草稿…'),
      if (state.restoredFromLocal)
        const WenyouStatusBanner(
          message: '已恢复上次未完成的本地内容。',
          tone: WenyouStatusTone.accent,
        ),
      if (state.bootstrapLoading)
        const WenyouStatusBanner(message: '正在准备发布选项…'),
      if (state.bootstrapFailure != null)
        WenyouStatusBanner(
          message: state.bootstrapFailure!.userMessage,
          detail: wenyouRequestDetail(state.bootstrapFailure),
          tone: WenyouStatusTone.error,
          action: TextButton(
            onPressed: state.bootstrapLoading ? null : onRefreshBootstrap,
            child: const Text('重新同步'),
          ),
        ),
      if (documentIssues.isNotEmpty)
        WenyouStatusBanner(
          message: '正文中有 ${documentIssues.length} 处内容暂时无法编辑。',
          detail: '这些内容会原样保留。',
        ),
      if (codecFailure != null)
        WenyouStatusBanner(
          message: '当前格式组合暂时不能安全保存。',
          detail: codecFailure,
          tone: WenyouStatusTone.error,
        ),
      if (operationFailure != null)
        WenyouStatusBanner(
          message: operationFailure!,
          tone: WenyouStatusTone.error,
        ),
      if (state.actionFailure != null)
        WenyouStatusBanner(
          key: const Key('compose-action-failure'),
          message: state.actionFailure!.userMessage,
          detail: wenyouRequestDetail(state.actionFailure),
          tone: WenyouStatusTone.error,
        ),
      if (state.successMessage != null)
        WenyouStatusBanner(
          message: state.successMessage!,
          tone: WenyouStatusTone.accent,
        ),
      if (uploadFailure != null)
        WenyouStatusBanner(
          message: uploadFailure!.userMessage,
          detail: _uploadRequestDetail(uploadFailure),
          tone: WenyouStatusTone.error,
          action: uploadFailure!.canRetry
              ? TextButton(
                  key: const Key('compose-retry-upload'),
                  onPressed: onRetryUpload,
                  child: const Text('重试上传'),
                )
              : null,
        ),
      if (uploading)
        _UploadStatus(progress: uploadProgress, onCancel: onCancelUpload),
    ];
    if (banners.isEmpty) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 120),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          tokens.space12,
          tokens.space8,
          tokens.space12,
          tokens.space4,
        ),
        child: Column(
          children: [
            for (var index = 0; index < banners.length; index++) ...[
              banners[index],
              if (index != banners.length - 1) SizedBox(height: tokens.space8),
            ],
          ],
        ),
      ),
    );
  }
}

bool hasMeaningfulThreadComposeContent(ThreadComposeState state) {
  return state.title.trim().isNotEmpty ||
      state.categorySlug != null ||
      state.tags.isNotEmpty ||
      MarkdownContent.hasVisibleContent(state.body) ||
      state.remoteDraft != null;
}

String? _uploadRequestDetail(MediaUploadFailure? failure) {
  final requestId = failure?.requestId;
  return requestId == null ? null : '问题编号：$requestId';
}

class ThreadComposeLoadFailure extends StatelessWidget {
  const ThreadComposeLoadFailure({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.actionDisableEdit,
          title: '打开创作空间失败',
          message: failure?.userMessage ?? '请重试；原有本地数据不会被覆盖。',
          detail: wenyouRequestDetail(failure),
          action: FilledButton(onPressed: onRetry, child: const Text('重试')),
        ),
      ),
    );
  }
}

class _UploadStatus extends StatelessWidget {
  const _UploadStatus({required this.progress, required this.onCancel});

  final MediaUploadProgress? progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final current = progress;
    final label = switch (current?.stage) {
      MediaUploadStage.preparing => '正在准备图片…',
      MediaUploadStage.uploading => '正在上传图片…',
      MediaUploadStage.confirming => '正在确认上传…',
      MediaUploadStage.processing => '图片处理中…',
      null => '正在准备图片…',
    };
    return WenyouStatusBanner(
      message: label,
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: current?.fraction),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: onCancel, child: const Text('取消上传')),
          ),
        ],
      ),
    );
  }
}

class ThreadComposeLocalSaveStatus extends StatelessWidget {
  const ThreadComposeLocalSaveStatus({required this.state, super.key});

  final ThreadComposeState state;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (state.localSnapshotStatus) {
      LocalSnapshotStatus.idle => (WenyouIconIds.actionEdit, '有未保存的修改'),
      LocalSnapshotStatus.saving => (WenyouIconIds.actionSync, '正在保存草稿…'),
      LocalSnapshotStatus.saved => (WenyouIconIds.statusSuccess, '草稿已保存'),
      LocalSnapshotStatus.failed => (WenyouIconIds.statusError, '保存失败，请先不要退出'),
    };
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          WenyouIcon(icon, size: 18),
          SizedBox(width: context.wenyouTokens.space8),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
