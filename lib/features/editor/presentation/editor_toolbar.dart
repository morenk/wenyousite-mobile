import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

enum WenyouComposerSurface { page, expandableSheet, inline }

enum WenyouComposerProfile {
  richMarkdown,
  momentBody,
  momentComment,
  directMessage,
}

typedef WenyouComposerDock = WenyouEditorToolbar;

class WenyouEditorToolbarController extends ChangeNotifier {
  VoidCallback? _closeTray;
  bool _trayOpen = false;

  bool get trayOpen => _trayOpen;

  bool closeTray() {
    if (!_trayOpen) return false;
    _closeTray?.call();
    return true;
  }

  void _attach({required bool trayOpen, required VoidCallback closeTray}) {
    _trayOpen = trayOpen;
    _closeTray = closeTray;
  }

  void _detach(VoidCallback closeTray) {
    if (_closeTray == closeTray) {
      _closeTray = null;
      _trayOpen = false;
    }
  }
}

/// A keyboard-docked WYSIWYG toolbar.
///
/// The core actions never scroll horizontally. Secondary actions expand inside
/// the composer so formatting does not dismiss the IME or lose the selection.
class WenyouEditorToolbar extends StatefulWidget {
  const WenyouEditorToolbar({
    required this.controller,
    required this.onInsertImage,
    required this.onSaveDraft,
    required this.enabled,
    this.onInsertSticker,
    this.editorFocusNode,
    this.onInteractionChanged,
    this.onSubmit,
    this.isSubmitting = false,
    this.submitLabel = '发送',
    this.characterCount,
    this.characterLimit,
    this.toolbarController,
    this.surface = WenyouComposerSurface.page,
    this.profile = WenyouComposerProfile.richMarkdown,
    this.floating = false,
    super.key,
  });

  final QuillController controller;
  final Future<void> Function() onInsertImage;
  final Future<void> Function()? onInsertSticker;
  final Future<void> Function() onSaveDraft;
  final bool enabled;
  final FocusNode? editorFocusNode;
  final ValueChanged<bool>? onInteractionChanged;
  final FutureOr<void> Function()? onSubmit;
  final bool isSubmitting;
  final String submitLabel;
  final int? characterCount;
  final int? characterLimit;
  final WenyouEditorToolbarController? toolbarController;
  final WenyouComposerSurface surface;
  final WenyouComposerProfile profile;

  /// Kept for call-site compatibility while remaining feature pages migrate
  /// from the former floating launcher to the docked toolbar.
  final bool floating;

  @override
  State<WenyouEditorToolbar> createState() => _WenyouEditorToolbarState();
}

class _WenyouEditorToolbarState extends State<WenyouEditorToolbar> {
  _EditorTray _tray = _EditorTray.none;
  bool _legacyFloatingExpanded = false;
  late final TextEditingController _linkLabelController;
  late final TextEditingController _linkUrlController;
  late final TextEditingController _diceController;
  TextSelection? _preservedSelection;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _linkLabelController = TextEditingController();
    _linkUrlController = TextEditingController();
    _diceController = TextEditingController(text: '1d20');
    widget.controller.addListener(_onControllerChanged);
    _syncToolbarController();
  }

  @override
  void didUpdateWidget(covariant WenyouEditorToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
    if (oldWidget.toolbarController != widget.toolbarController) {
      oldWidget.toolbarController?._detach(_closeTray);
      _syncToolbarController();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    widget.toolbarController?._detach(_closeTray);
    _linkLabelController.dispose();
    _linkUrlController.dispose();
    _diceController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final style = widget.controller.getSelectionStyle();
    if (widget.floating) {
      return _buildLegacyFloating(context, tokens, style);
    }
    final media = MediaQuery.of(context);
    final bottomSafeInset =
        widget.surface == WenyouComposerSurface.expandableSheet &&
            media.viewInsets.bottom == 0
        ? media.viewPadding.bottom
        : 0.0;
    return Material(
      key: const Key('editor-toolbar-dock'),
      color: tokens.softPanel,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomSafeInset),
        child: Semantics(
          container: true,
          label: '正文格式工具',
          expanded: _tray != _EditorTray.none,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _trayContent(context, style),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: tokens.border)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.space4),
                  child: SizedBox(
                    height: tokens.minimumTouchTarget + tokens.space8,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 560;
                        final controls = <Widget>[
                          _ToolbarButton(
                            key: const Key('editor-heading'),
                            icon: Icons.title_rounded,
                            label: '正文样式',
                            enabled: widget.enabled,
                            selected:
                                style.attributes.containsKey(
                                  Attribute.header.key,
                                ) ||
                                _tray == _EditorTray.heading,
                            onPressed: () => _toggleTray(_EditorTray.heading),
                          ),
                          _ToolbarButton(
                            key: const Key('editor-bold'),
                            icon: Icons.format_bold_rounded,
                            label: '粗体',
                            enabled: widget.enabled,
                            selected: style.attributes.containsKey(
                              Attribute.bold.key,
                            ),
                            onPressed: () => _toggle(Attribute.bold),
                          ),
                          _ToolbarButton(
                            key: const Key('editor-italic'),
                            icon: Icons.format_italic_rounded,
                            label: '斜体',
                            enabled: widget.enabled,
                            selected: style.attributes.containsKey(
                              Attribute.italic.key,
                            ),
                            onPressed: () => _toggle(Attribute.italic),
                          ),
                          _ToolbarButton(
                            key: const Key('editor-image'),
                            icon: Icons.image_outlined,
                            label: '图片',
                            enabled: widget.enabled,
                            onPressed: () => _runExternal(widget.onInsertImage),
                          ),
                          if (wide && widget.onInsertSticker != null)
                            _ToolbarButton(
                              key: const Key('editor-sticker'),
                              icon: Icons.add_reaction_outlined,
                              label: '表情包',
                              enabled: widget.enabled,
                              onPressed: () =>
                                  _runExternal(widget.onInsertSticker!),
                            ),
                          if (wide)
                            _ToolbarButton(
                              key: const Key('editor-content-drafts'),
                              icon: Icons.cloud_outlined,
                              label: '正文草稿',
                              enabled: widget.enabled,
                              onPressed: () => _runExternal(widget.onSaveDraft),
                            ),
                          _ToolbarButton(
                            key: const Key('editor-more'),
                            icon: _tray == _EditorTray.none
                                ? Icons.more_horiz_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            label: _tray == _EditorTray.none ? '更多' : '收起更多',
                            enabled: widget.enabled,
                            selected: _tray != _EditorTray.none,
                            onPressed: () => _toggleTray(_EditorTray.more),
                          ),
                          if (widget.onSubmit != null)
                            _SubmitButton(
                              enabled: widget.enabled,
                              loading: widget.isSubmitting,
                              label: widget.submitLabel,
                              onPressed: widget.onSubmit!,
                            ),
                        ];
                        return Row(
                          children: [
                            for (final control in controls)
                              Expanded(child: control),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegacyFloating(
    BuildContext context,
    WenyouThemeTokens tokens,
    Style style,
  ) {
    if (!_legacyFloatingExpanded) {
      return Semantics(
        button: true,
        label: '格式工具',
        expanded: false,
        enabled: widget.enabled,
        excludeSemantics: true,
        child: ExcludeSemantics(
          child: Material(
            color: tokens.accentedBackground,
            shape: CircleBorder(side: BorderSide(color: tokens.border)),
            child: IconButton(
              key: const Key('editor-format-tools'),
              tooltip: '展开格式工具',
              onPressed: widget.enabled
                  ? () {
                      setState(() => _legacyFloatingExpanded = true);
                      widget.editorFocusNode?.requestFocus();
                    }
                  : null,
              icon: const Icon(Icons.text_format_rounded),
            ),
          ),
        ),
      );
    }
    return Semantics(
      container: true,
      label: '格式工具',
      expanded: true,
      child: Material(
        color: tokens.softPanel,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: tokens.border),
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _trayContent(context, style),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToolbarButton(
                  key: const Key('editor-heading'),
                  icon: Icons.title_rounded,
                  label: '正文样式',
                  enabled: widget.enabled,
                  selected: style.attributes.containsKey(
                    Attribute.header.key,
                  ),
                  onPressed: () => _toggleTray(_EditorTray.heading),
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
                  selected: style.attributes.containsKey(
                    Attribute.italic.key,
                  ),
                  onPressed: () => _toggle(Attribute.italic),
                ),
                _ToolbarButton(
                  key: const Key('editor-image'),
                  icon: Icons.image_outlined,
                  label: '图片',
                  enabled: widget.enabled,
                  onPressed: () => _runExternal(widget.onInsertImage),
                ),
                _ToolbarButton(
                  key: const Key('editor-more'),
                  icon: Icons.more_horiz_rounded,
                  label: '更多',
                  enabled: widget.enabled,
                  onPressed: () => _toggleTray(_EditorTray.more),
                ),
                IconButton(
                  key: const Key('editor-format-tools-close'),
                  tooltip: '收起格式工具',
                  onPressed: () {
                    setState(() {
                      _legacyFloatingExpanded = false;
                      _tray = _EditorTray.none;
                    });
                    _syncToolbarController();
                    widget.onInteractionChanged?.call(false);
                    widget.editorFocusNode?.requestFocus();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _trayContent(BuildContext context, Style style) {
    final content = switch (_tray) {
      _EditorTray.none => const SizedBox.shrink(),
      _EditorTray.heading => _buildHeadingTray(context),
      _EditorTray.more => _buildMoreTray(context, style),
      _EditorTray.link => _buildLinkTray(context),
      _EditorTray.dice => _buildDiceTray(context),
    };
    return content;
  }

  Widget _buildHeadingTray(BuildContext context) {
    final tokens = context.wenyouTokens;
    final header = widget.controller
        .getSelectionStyle()
        .attributes[Attribute.header.key]
        ?.value;
    return Container(
      key: const Key('editor-heading-tray'),
      padding: EdgeInsets.all(tokens.space8),
      decoration: BoxDecoration(
        color: tokens.accentedBackground,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: SegmentedButton<int>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: 0, label: Text('正文')),
          ButtonSegment(value: 2, label: Text('H2')),
          ButtonSegment(value: 3, label: Text('H3')),
        ],
        selected: {
          header == 2
              ? 2
              : header == 3
              ? 3
              : 0,
        },
        onSelectionChanged: widget.enabled
            ? (selection) => _applyHeading(selection.single)
            : null,
      ),
    );
  }

  Widget _buildMoreTray(BuildContext context, Style style) {
    final tokens = context.wenyouTokens;
    final items = <Widget>[
      _TrayButton(
        icon: Icons.link_rounded,
        label: '链接',
        onPressed: _openLinkTray,
      ),
      _TrayButton(
        icon: Icons.code_rounded,
        label: '行内代码',
        selected: style.attributes.containsKey(Attribute.inlineCode.key),
        onPressed: () => _runTrayAction(() => _toggle(Attribute.inlineCode)),
      ),
      _TrayButton(
        icon: Icons.format_quote_rounded,
        label: '引用',
        selected: style.attributes.containsKey(Attribute.blockQuote.key),
        onPressed: () => _runTrayAction(() => _toggle(Attribute.blockQuote)),
      ),
      _TrayButton(
        icon: Icons.format_list_bulleted_rounded,
        label: '无序列表',
        selected: style.attributes.containsKey(Attribute.ul.key),
        onPressed: () => _runTrayAction(() => _toggle(Attribute.ul)),
      ),
      _TrayButton(
        icon: Icons.format_list_numbered_rounded,
        label: '有序列表',
        selected: style.attributes.containsKey(Attribute.ol.key),
        onPressed: () => _runTrayAction(() => _toggle(Attribute.ol)),
      ),
      _TrayButton(
        icon: Icons.horizontal_rule_rounded,
        label: '分隔线',
        onPressed: () => _runTrayAction(
          () => _insertBlockEmbed(
            const Embeddable(MarkdownDeltaCodec.horizontalRuleEmbed, {
              'version': 1,
            }),
          ),
        ),
      ),
      _TrayButton(
        icon: Icons.casino_outlined,
        label: '骰子',
        onPressed: _openDiceTray,
      ),
      if (widget.onInsertSticker != null)
        _TrayButton(
          icon: Icons.add_reaction_outlined,
          label: '表情包',
          onPressed: () => _runExternal(widget.onInsertSticker!),
        ),
      _TrayButton(
        icon: Icons.cloud_outlined,
        label: '正文草稿',
        onPressed: () => _runExternal(widget.onSaveDraft),
      ),
      _TrayButton(
        icon: Icons.strikethrough_s_rounded,
        label: '删除线',
        selected: style.attributes.containsKey(Attribute.strikeThrough.key),
        onPressed: () => _runTrayAction(() => _toggle(Attribute.strikeThrough)),
      ),
    ];
    return Container(
      key: const Key('editor-more-tray'),
      constraints: const BoxConstraints(maxHeight: 152),
      padding: EdgeInsets.symmetric(vertical: tokens.space4),
      decoration: BoxDecoration(
        color: tokens.accentedBackground,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = (constraints.maxWidth / 64).floor().clamp(4, 8);
            final width = constraints.maxWidth / columns;
            return Wrap(
              children: [
                for (final item in items) SizedBox(width: width, child: item),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLinkTray(BuildContext context) {
    return _InlineInputTray(
      key: const Key('editor-link-tray'),
      primaryController: _linkLabelController,
      primaryHint: '显示文字',
      secondaryController: _linkUrlController,
      secondaryHint: 'https://…',
      error: _inlineError,
      onBack: () => _setTray(_EditorTray.more),
      onConfirm: _insertLink,
    );
  }

  Widget _buildDiceTray(BuildContext context) {
    return _InlineInputTray(
      key: const Key('editor-dice-tray'),
      primaryController: _diceController,
      primaryHint: '例如 1d20 或 2d6+3',
      error: _inlineError,
      onBack: () => _setTray(_EditorTray.more),
      onConfirm: _insertDice,
    );
  }

  void _toggleTray(_EditorTray requested) {
    _setTray(
      _tray == requested ||
              (_tray != _EditorTray.none && requested == _EditorTray.more)
          ? _EditorTray.none
          : requested,
    );
  }

  void _setTray(_EditorTray tray) {
    setState(() {
      _tray = tray;
      _inlineError = null;
    });
    _syncToolbarController();
    widget.onInteractionChanged?.call(tray != _EditorTray.none);
    if (tray == _EditorTray.none ||
        tray == _EditorTray.heading ||
        tray == _EditorTray.more) {
      widget.editorFocusNode?.requestFocus();
    }
  }

  void _closeTray() => _setTray(_EditorTray.none);

  void _syncToolbarController() {
    widget.toolbarController?._attach(
      trayOpen: _tray != _EditorTray.none,
      closeTray: _closeTray,
    );
  }

  void _applyHeading(int selected) {
    widget.controller.formatSelection(
      selected == 2
          ? Attribute.h2
          : selected == 3
          ? Attribute.h3
          : Attribute.clone(Attribute.header, null),
    );
    _setTray(_EditorTray.none);
  }

  void _toggle(Attribute attribute) {
    final active = widget.controller.getSelectionStyle().attributes.containsKey(
      attribute.key,
    );
    widget.controller.formatSelection(
      active ? Attribute.clone(attribute, null) : attribute,
    );
    widget.editorFocusNode?.requestFocus();
  }

  void _runTrayAction(FutureOr<void> Function() action) {
    action();
    _setTray(_EditorTray.none);
  }

  Future<void> _runExternal(Future<void> Function() action) async {
    _preservedSelection = widget.controller.selection;
    final documentLength = widget.controller.document.length;
    widget.onInteractionChanged?.call(true);
    try {
      await action();
    } finally {
      if (mounted) {
        final selection = _preservedSelection;
        if (selection != null &&
            widget.controller.document.length == documentLength &&
            selection.end <= widget.controller.document.length - 1) {
          widget.controller.updateSelection(selection, ChangeSource.local);
        }
        _setTray(_EditorTray.none);
        widget.editorFocusNode?.requestFocus();
      }
    }
  }

  void _openLinkTray() {
    final selection = widget.controller.selection;
    _preservedSelection = selection;
    _linkLabelController.text = selection.isCollapsed
        ? ''
        : widget.controller.document.getPlainText(
            selection.start,
            selection.end - selection.start,
          );
    _linkUrlController.clear();
    _setTray(_EditorTray.link);
  }

  void _insertLink() {
    final label = _linkLabelController.text.trim();
    final url = _linkUrlController.text.trim();
    final uri = Uri.tryParse(url);
    if (label.isEmpty) {
      setState(() => _inlineError = '请填写显示文字');
      return;
    }
    if (uri == null || !uri.hasScheme || !MarkdownContent.isSafeLink(uri)) {
      setState(() => _inlineError = '仅支持 HTTP(S) 或 mailto 链接');
      return;
    }
    final selection = _preservedSelection ?? widget.controller.selection;
    if (selection.isCollapsed) {
      widget.controller.replaceText(
        selection.start,
        0,
        label,
        TextSelection.collapsed(offset: selection.start + label.length),
      );
      widget.controller.formatText(
        selection.start,
        label.length,
        LinkAttribute(url),
      );
    } else {
      widget.controller.formatText(
        selection.start,
        selection.end - selection.start,
        LinkAttribute(url),
      );
    }
    _setTray(_EditorTray.none);
  }

  void _openDiceTray() {
    _preservedSelection = widget.controller.selection;
    _diceController.text = '1d20';
    _setTray(_EditorTray.dice);
  }

  void _insertDice() {
    final normalized = MarkdownDeltaCodec.normalizeDiceNotation(
      _diceController.text,
    );
    if (normalized == null) {
      setState(() => _inlineError = '请输入 1～100 枚、2～1000 面的骰子');
      return;
    }
    final selection = _preservedSelection ?? widget.controller.selection;
    widget.controller.replaceText(
      selection.start,
      selection.end - selection.start,
      Embeddable(MarkdownDeltaCodec.diceEmbed, {
        'version': 1,
        'nodeId': const Uuid().v4(),
        'notation': normalized,
      }),
      TextSelection.collapsed(offset: selection.start + 1),
    );
    _setTray(_EditorTray.none);
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

enum _EditorTray { none, heading, more, link, dice }

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
    return IconButton(
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      onPressed: enabled ? () => onPressed() : null,
      isSelected: selected,
      selectedIcon: Icon(icon, color: context.wenyouTokens.brand),
      icon: Icon(icon),
      tooltip: label,
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.enabled,
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final String label;
  final FutureOr<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      key: const Key('editor-submit'),
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      tooltip: label,
      onPressed: enabled && !loading ? () => onPressed() : null,
      icon: loading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.send_rounded),
    );
  }
}

class _TrayButton extends StatelessWidget {
  const _TrayButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      tooltip: label,
      isSelected: selected,
      selectedIcon: Icon(icon, color: context.wenyouTokens.brand),
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _InlineInputTray extends StatelessWidget {
  const _InlineInputTray({
    required this.primaryController,
    required this.primaryHint,
    required this.error,
    required this.onBack,
    required this.onConfirm,
    this.secondaryController,
    this.secondaryHint,
    super.key,
  });

  final TextEditingController primaryController;
  final String primaryHint;
  final TextEditingController? secondaryController;
  final String? secondaryHint;
  final String? error;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Container(
      padding: EdgeInsets.fromLTRB(
        tokens.space4,
        tokens.space4,
        tokens.space4,
        tokens.space8,
      ),
      decoration: BoxDecoration(
        color: tokens.accentedBackground,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: '返回格式工具',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: TextField(
                  controller: primaryController,
                  autofocus: true,
                  textInputAction: secondaryController == null
                      ? TextInputAction.done
                      : TextInputAction.next,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: primaryHint,
                    errorText: error,
                  ),
                  onSubmitted: secondaryController == null
                      ? (_) => onConfirm()
                      : null,
                ),
              ),
              if (secondaryController != null) ...[
                SizedBox(width: tokens.space4),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: secondaryController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: secondaryHint,
                    ),
                    onSubmitted: (_) => onConfirm(),
                  ),
                ),
              ],
              IconButton.filled(
                tooltip: '确认插入',
                onPressed: onConfirm,
                icon: const Icon(Icons.check_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
