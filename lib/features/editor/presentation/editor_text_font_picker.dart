import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_selection.dart';

class EditorTextFontPicker extends ConsumerWidget {
  const EditorTextFontPicker({
    required this.controller,
    required this.enabled,
    this.focusNode,
    super.key,
  });
  final QuillController controller;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capability = ref.watch(appCapabilitiesProvider);
    final account = ref.watch(sessionScopeProvider).accountId;
    if (!capability.textFontSupported || account == null) {
      return const SizedBox.shrink();
    }
    final selected = controller.selection;
    final canSelect =
        enabled &&
        !controller.readOnly &&
        selected.isValid &&
        !selected.isCollapsed;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        key: const Key('editor-font-picker'),
        onPressed: canSelect
            ? () =>
                  _open(context, ref, account, capability.textFontWriteEnabled)
            : null,
        child: Text(canSelect ? '字体' : '选中文字后更换字体'),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    String account,
    bool writeEnabled,
  ) async {
    final selection = controller.selection;
    final original = jsonEncode(controller.document.toDelta().toJson());
    final service = ref.read(textFontServiceProvider);
    try {
      final runtime = await service.load();
      final preferences = await SharedPreferences.getInstance();
      final key = 'editor.textFont.v1.${Uri.encodeComponent(account)}';
      final recent = (preferences.getStringList(key) ?? <String>[])
          .where(
            (id) =>
                runtime.manifest?.fonts[id]?.ready == true &&
                MarkdownTextFont.ids.contains(id),
          )
          .toList();
      if (!context.mounted ||
          ref.read(sessionScopeProvider).accountId != account) {
        return;
      }
      final fonts = runtime.manifest?.fonts.values.toList() ?? [];
      fonts.sort((a, b) {
        final ai = recent.indexOf(a.id), bi = recent.indexOf(b.id);
        return (ai < 0 ? 100 : ai).compareTo(bi < 0 ? 100 : bi);
      });
      final picked = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .65,
            child: ListView(
              padding: EdgeInsets.all(context.wenyouTokens.space16),
              children: [
                const ListTile(
                  title: Text('字体'),
                  subtitle: Text('缺少的字使用默认字体显示'),
                ),
                ListTile(
                  key: const Key('editor-font-default'),
                  title: const Text('默认字体'),
                  onTap: () => Navigator.pop(context, ''),
                ),
                if (!writeEnabled)
                  const ListTile(title: Text('暂时无法更换字体，可恢复默认字体')),
                if (fonts.isEmpty) const ListTile(title: Text('字体暂不可用')),
                if (fonts.isEmpty || !runtime.assetsAvailable)
                  ListTile(
                    title: const Text('重新加载字体'),
                    onTap: () => Navigator.pop(context, '__retry'),
                  ),
                for (final language in [...TextFontLanguage.values, null]) ...[
                  if (fonts.any((f) => f.language == language))
                    ListTile(
                      key: Key(
                        'editor-font-group-${language?.name ?? 'other'}',
                      ),
                      title: Text(language?.label ?? '未分类'),
                    ),
                  for (final font in fonts.where((f) => f.language == language))
                    ListTile(
                      key: Key('editor-font-${font.id}'),
                      title: Text(font.name),
                      subtitle:
                          !font.ready || !MarkdownTextFont.ids.contains(font.id)
                          ? const Text('暂不可用')
                          : recent.contains(font.id)
                          ? const Text('最近使用')
                          : null,
                      enabled:
                          writeEnabled &&
                          font.ready &&
                          runtime.assetsAvailable &&
                          MarkdownTextFont.ids.contains(font.id),
                      onTap: () => Navigator.pop(context, font.id),
                    ),
                ],
              ],
            ),
          ),
        ),
      );
      if (!context.mounted ||
          picked == null ||
          ref.read(sessionScopeProvider).accountId != account ||
          jsonEncode(controller.document.toDelta().toJson()) != original) {
        return;
      }
      if (picked == '__retry') {
        await service.retry();
        if (context.mounted &&
            ref.read(sessionScopeProvider).accountId == account &&
            jsonEncode(controller.document.toDelta().toJson()) == original) {
          controller.updateSelection(selection, ChangeSource.local);
          await _open(context, ref, account, writeEnabled);
        }
        return;
      }
      if (EditorTextFontPolicy.apply(
            controller,
            selection,
            picked.isEmpty ? null : picked,
          ) &&
          picked.isNotEmpty) {
        final saved = await preferences.setStringList(
          key,
          [picked, ...recent.where((id) => id != picked)].take(5).toList(),
        );
        if (!saved && context.mounted) {
          showWenyouSnackBar(
            context,
            '最近字体保存失败',
            tone: WenyouSnackBarTone.error,
          );
        }
      }
    } on Object {
      if (context.mounted) {
        showWenyouSnackBar(context, '字体加载失败', tone: WenyouSnackBarTone.error);
      }
    } finally {
      if (context.mounted &&
          ref.read(sessionScopeProvider).accountId == account) {
        focusNode?.requestFocus();
      }
    }
  }
}
