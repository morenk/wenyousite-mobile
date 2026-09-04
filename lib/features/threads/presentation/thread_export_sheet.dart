import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
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
        builder: (context) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .9,
          ),
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
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          tokens.space16,
          0,
          tokens.space16,
          tokens.space16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '导出主题档案',
                    style: Theme.of(context).textTheme.wenyouOverlayTitle,
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
            SizedBox(height: tokens.space8),
            Text('正文格式', style: Theme.of(context).textTheme.wenyouCompactTitle),
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
            Text('包含内容', style: Theme.of(context).textTheme.wenyouCompactTitle),
            SizedBox(height: tokens.space8),
            Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space8,
              children: [
                _option(
                  key: 'authors',
                  label: '作者',
                  value: _includeAuthors,
                  onChanged: (value) => _includeAuthors = value,
                ),
                _option(
                  key: 'timestamps',
                  label: '发布时间',
                  value: _includeTimestamps,
                  onChanged: (value) => _includeTimestamps = value,
                ),
                _option(
                  key: 'floor-numbers',
                  label: '楼层号',
                  value: _includeFloorNumbers,
                  onChanged: (value) => _includeFloorNumbers = value,
                ),
                _option(
                  key: 'reply-targets',
                  label: '回复对象',
                  value: _includeReplyTargets,
                  onChanged: (value) => _includeReplyTargets = value,
                ),
                _option(
                  key: 'source-links',
                  label: '来源链接',
                  value: _includeSourceLinks,
                  onChanged: (value) => _includeSourceLinks = value,
                ),
                _option(
                  key: 'media',
                  label: '正文图片',
                  value: _includeMedia,
                  onChanged: (value) => _includeMedia = value,
                ),
              ],
            ),
            if (_includeSourceLinks || _includeMedia) ...[
              SizedBox(height: tokens.space8),
              Text(
                [
                  if (_includeSourceLinks) '来源链接不包含私密邀请。',
                  if (_includeMedia) '无法取得的图片会列在档案说明中。',
                ].join('\n'),
                style: Theme.of(
                  context,
                ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
              ),
            ],
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
            WenyouAsyncButton(
              key: const Key('thread-export-submit'),
              label: '导出并保存',
              loadingLabel: '正在生成档案',
              icon: WenyouIconIds.actionDownload,
              isLoading: _isExporting,
              onPressed: supported ? _export : null,
              expand: true,
            ),
          ],
        ),
      ),
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
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return FilterChip(
      key: ValueKey('thread-export-$key'),
      label: Text(label),
      selected: value,
      onSelected: _isExporting
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
