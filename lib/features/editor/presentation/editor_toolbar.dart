import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

class WenyouEditorToolbar extends StatefulWidget {
  const WenyouEditorToolbar({
    required this.controller,
    required this.onInsertImage,
    required this.onSaveDraft,
    required this.enabled,
    this.onInsertSticker,
    super.key,
  });

  final QuillController controller;
  final Future<void> Function() onInsertImage;
  final Future<void> Function()? onInsertSticker;
  final Future<void> Function() onSaveDraft;
  final bool enabled;

  @override
  State<WenyouEditorToolbar> createState() => _WenyouEditorToolbarState();
}

class _WenyouEditorToolbarState extends State<WenyouEditorToolbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant WenyouEditorToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final style = widget.controller.getSelectionStyle();
    final wide = MediaQuery.sizeOf(context).width >= 600;
    return Container(
      decoration: BoxDecoration(
        color: tokens.softPanel,
        border: Border(bottom: BorderSide(color: tokens.border)),
      ),
      padding: EdgeInsets.symmetric(horizontal: tokens.space4),
      child: Row(
        children: [
          _ToolbarButton(
            key: const Key('editor-heading'),
            icon: Icons.title_rounded,
            label: '正文样式',
            enabled: widget.enabled,
            selected: style.attributes.containsKey(Attribute.header.key),
            onPressed: _chooseHeading,
          ),
          _ToolbarButton(
            key: const Key('editor-bold'),
            icon: Icons.format_bold_rounded,
            label: '粗体',
            enabled: widget.enabled,
            selected: style.attributes.containsKey(Attribute.bold.key),
            onPressed: () => _toggle(Attribute.bold),
          ),
          _ToolbarButton(
            key: const Key('editor-italic'),
            icon: Icons.format_italic_rounded,
            label: '斜体',
            enabled: widget.enabled,
            selected: style.attributes.containsKey(Attribute.italic.key),
            onPressed: () => _toggle(Attribute.italic),
          ),
          _ToolbarButton(
            key: const Key('editor-image'),
            icon: Icons.image_outlined,
            label: '图片',
            enabled: widget.enabled,
            onPressed: () => widget.onInsertImage(),
          ),
          if (wide) ...[
            if (widget.onInsertSticker != null)
              _ToolbarButton(
                key: const Key('editor-sticker'),
                icon: Icons.add_reaction_outlined,
                label: '收藏表情',
                enabled: widget.enabled,
                onPressed: widget.onInsertSticker!,
              ),
            _ToolbarButton(
              icon: Icons.strikethrough_s_rounded,
              label: '删除线',
              enabled: widget.enabled,
              selected: style.attributes.containsKey(
                Attribute.strikeThrough.key,
              ),
              onPressed: () => _toggle(Attribute.strikeThrough),
            ),
            _ToolbarButton(
              key: const Key('editor-content-drafts'),
              icon: Icons.cloud_outlined,
              label: '正文草稿',
              enabled: widget.enabled,
              onPressed: () => widget.onSaveDraft(),
            ),
          ],
          const Spacer(),
          _ToolbarButton(
            key: const Key('editor-more'),
            icon: Icons.more_horiz_rounded,
            label: '更多',
            enabled: widget.enabled,
            onPressed: _showMoreSheet,
          ),
        ],
      ),
    );
  }

  Future<void> _chooseHeading() async {
    final selected = await showModalBottomSheet<int?>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields_rounded),
              title: const Text('正文'),
              onTap: () => Navigator.pop(context, 0),
            ),
            ListTile(
              leading: const Icon(Icons.looks_two_rounded),
              title: const Text('二级标题'),
              onTap: () => Navigator.pop(context, 2),
            ),
            ListTile(
              leading: const Icon(Icons.looks_3_rounded),
              title: const Text('三级标题'),
              onTap: () => Navigator.pop(context, 3),
            ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    widget.controller.formatSelection(
      selected == 2
          ? Attribute.h2
          : selected == 3
          ? Attribute.h3
          : Attribute.clone(Attribute.header, null),
    );
  }

  void _toggle(Attribute attribute) {
    final active = widget.controller.getSelectionStyle().attributes.containsKey(
      attribute.key,
    );
    widget.controller.formatSelection(
      active ? Attribute.clone(attribute, null) : attribute,
    );
  }

  Future<void> _showMoreSheet() async {
    final action = await showModalBottomSheet<_MoreAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            _moreTile(context, _MoreAction.link, Icons.link_rounded, '链接'),
            _moreTile(
              context,
              _MoreAction.inlineCode,
              Icons.code_rounded,
              '行内代码',
            ),
            _moreTile(
              context,
              _MoreAction.quote,
              Icons.format_quote_rounded,
              '引用',
            ),
            _moreTile(
              context,
              _MoreAction.bulletList,
              Icons.format_list_bulleted_rounded,
              '无序列表',
            ),
            _moreTile(
              context,
              _MoreAction.orderedList,
              Icons.format_list_numbered_rounded,
              '有序列表',
            ),
            _moreTile(
              context,
              _MoreAction.horizontalRule,
              Icons.horizontal_rule_rounded,
              '分隔线',
            ),
            _moreTile(context, _MoreAction.dice, Icons.casino_outlined, '骰子'),
            if (widget.onInsertSticker != null)
              _moreTile(
                context,
                _MoreAction.sticker,
                Icons.add_reaction_outlined,
                '收藏表情',
              ),
            _moreTile(context, _MoreAction.draft, Icons.cloud_outlined, '正文草稿'),
            _moreTile(
              context,
              _MoreAction.strike,
              Icons.strikethrough_s_rounded,
              '删除线',
            ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    switch (action) {
      case _MoreAction.link:
        await _editLink();
      case _MoreAction.inlineCode:
        _toggle(Attribute.inlineCode);
      case _MoreAction.quote:
        _toggle(Attribute.blockQuote);
      case _MoreAction.bulletList:
        _toggle(Attribute.ul);
      case _MoreAction.orderedList:
        _toggle(Attribute.ol);
      case _MoreAction.horizontalRule:
        _insertBlockEmbed(
          const Embeddable(MarkdownDeltaCodec.horizontalRuleEmbed, {
            'version': 1,
          }),
        );
      case _MoreAction.dice:
        await _insertDice();
      case _MoreAction.sticker:
        await widget.onInsertSticker?.call();
      case _MoreAction.draft:
        await widget.onSaveDraft();
      case _MoreAction.strike:
        _toggle(Attribute.strikeThrough);
    }
  }

  Widget _moreTile(
    BuildContext context,
    _MoreAction action,
    IconData icon,
    String label,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      minTileHeight: context.wenyouTokens.minimumTouchTarget,
      onTap: () => Navigator.pop(context, action),
    );
  }

  Future<void> _editLink() async {
    final selection = widget.controller.selection;
    final selectedText = selection.isCollapsed
        ? ''
        : widget.controller.document.getPlainText(
            selection.start,
            selection.end - selection.start,
          );
    final labelController = TextEditingController(text: selectedText);
    final urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('插入链接'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selection.isCollapsed)
                TextFormField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: '显示文字'),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? '请填写显示文字' : null,
                ),
              SizedBox(height: context.wenyouTokens.space12),
              TextFormField(
                controller: urlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: '链接地址',
                  hintText: 'https://…',
                ),
                validator: (value) {
                  final uri = Uri.tryParse(value?.trim() ?? '');
                  return uri == null ||
                          !uri.hasScheme ||
                          !MarkdownContent.isSafeLink(uri)
                      ? '仅支持 HTTP(S) 或 mailto 链接'
                      : null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.pop(context, (
                labelController.text.trim(),
                urlController.text.trim(),
              ));
            },
            child: const Text('插入'),
          ),
        ],
      ),
    );
    labelController.dispose();
    urlController.dispose();
    if (result == null || !mounted) return;
    if (selection.isCollapsed) {
      widget.controller.replaceText(
        selection.start,
        0,
        result.$1,
        TextSelection.collapsed(offset: selection.start + result.$1.length),
      );
      widget.controller.formatText(
        selection.start,
        result.$1.length,
        LinkAttribute(result.$2),
      );
    } else {
      widget.controller.formatText(
        selection.start,
        selection.end - selection.start,
        LinkAttribute(result.$2),
      );
    }
  }

  Future<void> _insertDice() async {
    final controller = TextEditingController(text: '1d20');
    final formKey = GlobalKey<FormState>();
    final notation = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('插入待掷骰子'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '骰子表达式',
              hintText: '例如 1d20 或 2d6+3',
            ),
            validator: (value) =>
                MarkdownDeltaCodec.normalizeDiceNotation(value ?? '') == null
                ? '请输入 1～100 枚、2～1000 面的骰子'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.pop(context, controller.text);
            },
            child: const Text('插入'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (notation == null || !mounted) return;
    final normalized = MarkdownDeltaCodec.normalizeDiceNotation(notation)!;
    _insertInlineEmbed(
      Embeddable(MarkdownDeltaCodec.diceEmbed, {
        'version': 1,
        'nodeId': const Uuid().v4(),
        'notation': normalized,
      }),
    );
  }

  void _insertInlineEmbed(Embeddable embed) {
    final selection = widget.controller.selection;
    widget.controller.replaceText(
      selection.start,
      selection.end - selection.start,
      embed,
      TextSelection.collapsed(offset: selection.start + 1),
    );
  }

  void _insertBlockEmbed(Embeddable embed) {
    var selection = widget.controller.selection;
    final plain = widget.controller.document.toPlainText();
    if (selection.start > 0 && plain[selection.start - 1] != '\n') {
      widget.controller.replaceText(
        selection.start,
        0,
        '\n',
        TextSelection.collapsed(offset: selection.start + 1),
      );
      selection = TextSelection.collapsed(offset: selection.start + 1);
    }
    widget.controller.replaceText(
      selection.start,
      selection.end - selection.start,
      embed,
      TextSelection.collapsed(offset: selection.start + 1),
    );
    widget.controller.replaceText(
      selection.start + 1,
      0,
      '\n',
      TextSelection.collapsed(offset: selection.start + 2),
    );
  }
}

enum _MoreAction {
  link,
  inlineCode,
  quote,
  bulletList,
  orderedList,
  horizontalRule,
  dice,
  sticker,
  draft,
  strike,
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.selected = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final bool selected;
  final FutureOr<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: IconButton(
        onPressed: enabled ? () => onPressed() : null,
        isSelected: selected,
        selectedIcon: Icon(icon, color: context.wenyouTokens.brand),
        icon: Icon(icon),
        tooltip: label,
      ),
    );
  }
}
