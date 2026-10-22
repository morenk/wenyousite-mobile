import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_sheet.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';

class EditorTextFontPicker extends ConsumerStatefulWidget {
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
  ConsumerState<EditorTextFontPicker> createState() =>
      _EditorTextFontPickerState();
}

class _EditorTextFontPickerState extends ConsumerState<EditorTextFontPicker> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final capability = ref.watch(appCapabilitiesProvider);
    final account = ref.watch(sessionScopeProvider).accountId;
    if (!capability.textFontSupported || account == null) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final canSelect =
            widget.enabled &&
            !widget.controller.readOnly &&
            widget.controller.selection.isValid;
        return Align(
          alignment: Alignment.centerLeft,
          child: Tooltip(
            message: '更换字体',
            child: TextButton(
              key: const Key('editor-font-picker'),
              onPressed: canSelect && !_open ? () => _show(account) : null,
              child: const Text('字体'),
            ),
          ),
        );
      },
    );
  }

  Future<void> _show(String account) async {
    if (_open) return;
    setState(() => _open = true);
    final controller = widget.controller;
    final document = controller.document;
    final selection = controller.selection;
    final selectedFont = EditorTextFontPolicy.selection(controller);
    final typingStyle = controller is LiteralTextQuillController
        ? controller.captureTypingStyle()
        : null;
    final original = jsonEncode(document.toDelta().toJson());
    final service = ref.read(textFontServiceProvider);
    bool current() =>
        mounted &&
        identical(widget.controller, controller) &&
        identical(controller.document, document) &&
        ref.read(sessionScopeProvider).accountId == account;
    bool unchanged() =>
        current() && jsonEncode(document.toDelta().toJson()) == original;
    void restore() {
      if (controller is LiteralTextQuillController) {
        controller.restoreToolSelection(selection, snapshot: typingStyle);
      } else {
        controller.updateSelection(selection, ChangeSource.local);
      }
    }

    bool applied = false;
    List<String> recent = [];
    try {
      final picked = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .65,
            child: Consumer(
              builder: (context, ref, _) {
                final capability = ref.watch(appCapabilitiesProvider);
                return EditorTextFontSheet(
                  service: service,
                  account: account,
                  writeEnabled: capability.textFontV2Supported
                      ? capability.textFontV2WriteEnabled
                      : capability.textFontWriteEnabled,
                  selectedFont: selectedFont,
                  onRecentLoaded: (value) => recent = value,
                );
              },
            ),
          ),
        ),
      );
      if (!unchanged() ||
          picked == null ||
          controller.readOnly ||
          !widget.enabled) {
        return;
      }
      final capability = ref.read(appCapabilitiesProvider);
      if (picked.isNotEmpty &&
          !(service.dynamicEnabled
              ? capability.textFontV2WriteEnabled
              : capability.textFontWriteEnabled)) {
        return;
      }
      if (MarkdownTextFont.isVersionId(picked) &&
          service.dynamicRuntime?.catalog.canSelect(picked) != true) {
        return;
      }
      // 先恢复入口的光标，再设置新字体，不能用旧快照覆盖新输入样式。
      restore();
      applied = EditorTextFontPolicy.apply(
        controller,
        selection,
        picked.isEmpty ? null : picked,
      );
      if (applied && picked.isNotEmpty) {
        final preferences = await SharedPreferences.getInstance();
        if (!current()) return;
        final key = 'editor.textFont.v1.${Uri.encodeComponent(account)}';
        final saved = await preferences.setStringList(
          key,
          [picked, ...recent.where((id) => id != picked)].take(5).toList(),
        );
        if (!saved && mounted) {
          showWenyouSnackBar(
            context,
            '最近字体保存失败',
            tone: WenyouSnackBarTone.error,
          );
        }
      }
    } on Object {
      if (mounted) {
        showWenyouSnackBar(context, '字体加载失败', tone: WenyouSnackBarTone.error);
      }
    } finally {
      service.closePicker();
      if (current()) {
        if (!applied && unchanged()) restore();
        widget.focusNode?.requestFocus();
      }
      if (mounted) setState(() => _open = false);
    }
  }
}
