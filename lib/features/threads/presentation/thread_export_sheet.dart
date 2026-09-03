import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/document_saver.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_management_repository_ports.dart';

Future<bool> showThreadExportSheet({
  required BuildContext context,
  required String threadId,
}) async {
  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) => FractionallySizedBox(
          heightFactor: .9,
          child: ThreadExportSheet(threadId: threadId),
        ),
      ) ??
      false;
}

class ThreadExportSheet extends ConsumerStatefulWidget {
  const ThreadExportSheet({required this.threadId, super.key});

  final String threadId;

  @override
  ConsumerState<ThreadExportSheet> createState() => _ThreadExportSheetState();
}

class _ThreadExportSheetState extends ConsumerState<ThreadExportSheet> {
  ThreadArchiveFormat _format = ThreadArchiveFormat.both;
  bool _includeAuthors = true;
  bool _includeTimestamps = true;
  bool _includeFloorNumbers = true;
  bool _includeReplyTargets = true;
  bool _includeSourceLinks = false;
  bool _includeMedia = true;
  bool _isExporting = false;
  ApiFailure? _failure;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final supported = ref.watch(documentSaverProvider).isSupported;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space16,
            0,
            tokens.space8,
            tokens.space12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '导出主题档案',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: tokens.space4),
                    Text(
                      '生成 ZIP 后，由你选择保存位置。',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('thread-export-close'),
                tooltip: '关闭导出设置',
                onPressed: _isExporting ? null : () => Navigator.pop(context),
                icon: const WenyouIcon(WenyouIconIds.actionClose),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: tokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('正文格式', style: Theme.of(context).textTheme.titleSmall),
                SizedBox(height: tokens.space8),
                Wrap(
                  spacing: tokens.space8,
                  runSpacing: tokens.space8,
                  children: [
                    _formatChoice(ThreadArchiveFormat.text, '纯文本'),
                    _formatChoice(ThreadArchiveFormat.markdown, 'Markdown'),
                    _formatChoice(ThreadArchiveFormat.both, '两种都要'),
                  ],
                ),
                SizedBox(height: tokens.space16),
                _option(
                  key: 'authors',
                  title: '保留作者名称',
                  value: _includeAuthors,
                  onChanged: (value) => _includeAuthors = value,
                ),
                _option(
                  key: 'timestamps',
                  title: '保留发布时间',
                  value: _includeTimestamps,
                  onChanged: (value) => _includeTimestamps = value,
                ),
                _option(
                  key: 'floor-numbers',
                  title: '保留楼层编号',
                  value: _includeFloorNumbers,
                  onChanged: (value) => _includeFloorNumbers = value,
                ),
                _option(
                  key: 'reply-targets',
                  title: '保留回复对象',
                  value: _includeReplyTargets,
                  onChanged: (value) => _includeReplyTargets = value,
                ),
                _option(
                  key: 'source-links',
                  title: '保留站内来源链接',
                  subtitle: '邀请链接始终隐藏。',
                  value: _includeSourceLinks,
                  onChanged: (value) => _includeSourceLinks = value,
                ),
                _option(
                  key: 'media',
                  title: '打包正文图片',
                  subtitle: '无法取得的图片会在档案说明中列出。',
                  value: _includeMedia,
                  onChanged: (value) => _includeMedia = value,
                ),
                if (!supported) ...[
                  SizedBox(height: tokens.space12),
                  const WenyouStatusBanner(
                    tone: WenyouStatusTone.error,
                    message: '当前设备暂不支持保存档案。',
                  ),
                ],
                if (_failure case final failure?) ...[
                  SizedBox(height: tokens.space12),
                  WenyouStatusBanner(
                    key: const Key('thread-export-failure'),
                    tone: WenyouStatusTone.error,
                    message: failure.userMessage,
                    detail: wenyouFailureDetail(failure),
                  ),
                ],
                SizedBox(height: tokens.space16),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(tokens.space16),
            child: WenyouAsyncButton(
              key: const Key('thread-export-submit'),
              label: '生成并选择保存位置',
              loadingLabel: '正在生成档案',
              icon: WenyouIconIds.actionDownload,
              isLoading: _isExporting,
              onPressed: supported ? _export : null,
              expand: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _formatChoice(ThreadArchiveFormat value, String label) {
    return ChoiceChip(
      key: ValueKey('thread-export-format-${value.name}'),
      label: Text(label),
      selected: _format == value,
      onSelected: _isExporting
          ? null
          : (selected) {
              if (selected) setState(() => _format = value);
            },
    );
  }

  Widget _option({
    required String key,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return SwitchListTile.adaptive(
      key: ValueKey('thread-export-$key'),
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      value: value,
      onChanged: _isExporting
          ? null
          : (next) => setState(() => onChanged(next)),
    );
  }

  Future<void> _export() async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _failure = null;
    });
    try {
      final archive = await ref
          .read(threadManagementRepositoryProvider)
          .exportArchive(
            widget.threadId,
            ThreadArchiveOptions(
              format: _format,
              includeAuthors: _includeAuthors,
              includeTimestamps: _includeTimestamps,
              includeFloorNumbers: _includeFloorNumbers,
              includeReplyTargets: _includeReplyTargets,
              includeSourceLinks: _includeSourceLinks,
              includeMedia: _includeMedia,
            ),
          );
      final saved = await ref
          .read(documentSaverProvider)
          .save(
            bytes: archive.bytes,
            fileName: archive.fileName,
            mimeType: 'application/zip',
          );
      if (saved && mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _failure = error is DocumentSaveException
            ? ApiFailure(userMessage: error.userMessage, cause: error)
            : mapApplicationFailure(error, '主题档案导出失败，请稍后重试。');
      });
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
