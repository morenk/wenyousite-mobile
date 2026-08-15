import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

part 'editor_toolbar_input_tray.dart';

enum WenyouComposerSurface { page, expandableSheet, inline }

@immutable
class WenyouEditorCapabilities {
  const WenyouEditorCapabilities({
    this.headings = true,
    this.inlineStyles = true,
    this.images = true,
    this.links = true,
    this.blockStyles = true,
    this.dice = true,
    this.stickers = true,
    this.drafts = true,
  });

  static const richMarkdown = WenyouEditorCapabilities();

  final bool headings;
  final bool inlineStyles;
  final bool images;
  final bool links;
  final bool blockStyles;
  final bool dice;
  final bool stickers;
  final bool drafts;

  bool get hasMoreActions =>
      inlineStyles || links || blockStyles || dice || stickers;
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
    this.capabilities = WenyouEditorCapabilities.richMarkdown,
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
  final WenyouEditorCapabilities capabilities;

  @override
  State<WenyouEditorToolbar> createState() => _WenyouEditorToolbarState();
}

class _WenyouEditorToolbarState extends State<WenyouEditorToolbar> {
  _EditorTray _tray = _EditorTray.none;
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: WenyouEditorContract.toolbarHorizontalPadding,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final draftInline = _draftFitsInToolbarRow(
                        constraints.maxWidth,
                      );
                      final promoted = _promotedActionsForWidth(
                        constraints.maxWidth,
                        reserveDraft: draftInline,
                      );
                      final formatControls = <Widget>[
                        if (widget.capabilities.headings)
                          _ToolbarButton(
                            key: const Key('editor-heading'),
                            icon: WenyouIconIds.editorHeading,
                            label: '正文样式',
                            enabled: widget.enabled,
                            selected:
                                style.attributes.containsKey(
                                  Attribute.header.key,
                                ) ||
                                _tray == _EditorTray.heading,
                            onPressed: () => _toggleTray(_EditorTray.heading),
                          ),
                        if (widget.capabilities.inlineStyles)
                          _ToolbarButton(
                            key: const Key('editor-bold'),
                            icon: WenyouIconIds.editorBold,
                            label: '粗体',
                            enabled: widget.enabled,
                            selected: style.attributes.containsKey(
                              Attribute.bold.key,
                            ),
                            onPressed: () => _toggle(Attribute.bold),
                          ),
                        if (widget.capabilities.inlineStyles)
                          _ToolbarButton(
                            key: const Key('editor-italic'),
                            icon: WenyouIconIds.editorItalic,
                            label: '斜体',
                            enabled: widget.enabled,
                            selected: style.attributes.containsKey(
                              Attribute.italic.key,
                            ),
                            onPressed: () => _toggle(Attribute.italic),
                          ),
                        if (widget.capabilities.images)
                          _ToolbarButton(
                            key: const Key('editor-image'),
                            icon: WenyouIconIds.editorImage,
                            label: '图片',
                            enabled: widget.enabled,
                            onPressed: () => _runExternal(widget.onInsertImage),
                          ),
                        if (promoted.contains(_EditorAction.quote))
                          _ToolbarButton(
                            key: const Key('editor-quote'),
                            icon: WenyouIconIds.editorQuote,
                            label: '引用',
                            enabled: widget.enabled,
                            selected: style.attributes.containsKey(
                              Attribute.blockQuote.key,
                            ),
                            onPressed: () => _toggle(Attribute.blockQuote),
                          ),
                        if (promoted.contains(_EditorAction.horizontalRule))
                          _ToolbarButton(
                            key: const Key('editor-horizontal-rule'),
                            icon: WenyouIconIds.editorHorizontalRule,
                            label: '分隔线',
                            enabled: widget.enabled,
                            onPressed: _insertHorizontalRule,
                          ),
                        if (promoted.contains(_EditorAction.sticker))
                          _ToolbarButton(
                            key: const Key('editor-sticker'),
                            icon: WenyouIconIds.editorSticker,
                            label: '表情包',
                            enabled: widget.enabled,
                            onPressed: () =>
                                _runExternal(widget.onInsertSticker!),
                          ),
                      ];
                      final controls = <Widget>[
                        ...formatControls,
                        if (draftInline && widget.capabilities.drafts) ...[
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: context.wenyouTokens.border,
                                ),
                              ),
                            ),
                            child: _buildDraftToolbarButton(),
                          ),
                        ],
                        if (widget.capabilities.hasMoreActions)
                          _ToolbarButton(
                            key: const Key('editor-more'),
                            icon: _tray == _EditorTray.none
                                ? WenyouIconIds.editorMore
                                : WenyouIconIds.editorChevronDown,
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
                      final toolbarRow = SizedBox(
                        height:
                            context.wenyouTokens.minimumTouchTarget +
                            context.wenyouTokens.space8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: controls,
                        ),
                      );
                      if (draftInline || !widget.capabilities.drafts) {
                        return toolbarRow;
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDedicatedDraftRow(context),
                          toolbarRow,
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
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
            final promoted = _promotedActionsForWidth(
              constraints.maxWidth - tokens.space4 * 2,
              reserveDraft: false,
            );
            final items = <Widget>[
              if (widget.capabilities.links)
                _TrayButton(
                  icon: WenyouIconIds.editorLink,
                  label: '链接',
                  onPressed: _openLinkTray,
                ),
              if (widget.capabilities.inlineStyles)
                _TrayButton(
                  icon: WenyouIconIds.editorInlineCode,
                  label: '行内代码',
                  selected: style.attributes.containsKey(
                    Attribute.inlineCode.key,
                  ),
                  onPressed: () =>
                      _runTrayAction(() => _toggle(Attribute.inlineCode)),
                ),
              if (widget.capabilities.blockStyles) ...[
                if (!promoted.contains(_EditorAction.quote))
                  _TrayButton(
                    icon: WenyouIconIds.editorQuote,
                    label: '引用',
                    selected: style.attributes.containsKey(
                      Attribute.blockQuote.key,
                    ),
                    onPressed: () =>
                        _runTrayAction(() => _toggle(Attribute.blockQuote)),
                  ),
                _TrayButton(
                  icon: WenyouIconIds.editorBulletList,
                  label: '无序列表',
                  selected: style.attributes.containsKey(Attribute.ul.key),
                  onPressed: () => _runTrayAction(() => _toggle(Attribute.ul)),
                ),
                _TrayButton(
                  icon: WenyouIconIds.editorOrderedList,
                  label: '有序列表',
                  selected: style.attributes.containsKey(Attribute.ol.key),
                  onPressed: () => _runTrayAction(() => _toggle(Attribute.ol)),
                ),
                if (!promoted.contains(_EditorAction.horizontalRule))
                  _TrayButton(
                    icon: WenyouIconIds.editorHorizontalRule,
                    label: '分隔线',
                    onPressed: () => _runTrayAction(_insertHorizontalRule),
                  ),
              ],
              if (widget.capabilities.dice)
                _TrayButton(
                  icon: WenyouIconIds.editorDice,
                  label: '骰子',
                  onPressed: _openDiceTray,
                ),
              if (widget.capabilities.stickers &&
                  widget.onInsertSticker != null &&
                  !promoted.contains(_EditorAction.sticker))
                _TrayButton(
                  icon: WenyouIconIds.editorSticker,
                  label: '表情包',
                  onPressed: () => _runExternal(widget.onInsertSticker!),
                ),
              if (widget.capabilities.inlineStyles)
                _TrayButton(
                  icon: WenyouIconIds.editorStrikethrough,
                  label: '删除线',
                  selected: style.attributes.containsKey(
                    Attribute.strikeThrough.key,
                  ),
                  onPressed: () =>
                      _runTrayAction(() => _toggle(Attribute.strikeThrough)),
                ),
            ];
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

  Widget _buildDraftToolbarButton() {
    return _ToolbarButton(
      key: const Key('editor-content-drafts'),
      icon: WenyouIconIds.editorContentDrafts,
      label: '正文草稿',
      enabled: widget.enabled,
      onPressed: () => _runExternal(widget.onSaveDraft),
    );
  }

  Widget _buildDedicatedDraftRow(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SizedBox(
      height: tokens.minimumTouchTarget + tokens.space4,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: tokens.space4),
          child: OutlinedButton.icon(
            key: const Key('editor-content-drafts'),
            onPressed: widget.enabled
                ? () {
                    unawaited(_runExternal(widget.onSaveDraft));
                  }
                : null,
            icon: const WenyouIcon(WenyouIconIds.editorContentDrafts),
            label: const Text('正文草稿'),
          ),
        ),
      ),
    );
  }

  bool _draftFitsInToolbarRow(double availableWidth) {
    if (!widget.capabilities.drafts) return true;
    final capacity = (availableWidth / WenyouEditorContract.minimumActionExtent)
        .floor();
    return capacity >= _fixedToolbarControlCount() + 1;
  }

  int _fixedToolbarControlCount() {
    return (widget.capabilities.headings ? 1 : 0) +
        (widget.capabilities.inlineStyles ? 2 : 0) +
        (widget.capabilities.images ? 1 : 0) +
        (widget.capabilities.hasMoreActions ? 1 : 0) +
        (widget.onSubmit != null ? 1 : 0);
  }

  Set<_EditorAction> _promotedActionsForWidth(
    double availableWidth, {
    required bool reserveDraft,
  }) {
    final fixedCount = _fixedToolbarControlCount() + (reserveDraft ? 1 : 0);
    final capacity = (availableWidth / WenyouEditorContract.minimumActionExtent)
        .floor();
    final promotionSlots = (capacity - fixedCount).clamp(0, 3).toInt();
    if (promotionSlots == 0) return const {};
    final available = <String, _EditorAction>{
      if (widget.capabilities.blockStyles) 'quote': _EditorAction.quote,
      if (widget.capabilities.blockStyles) 'hr': _EditorAction.horizontalRule,
      if (widget.capabilities.stickers && widget.onInsertSticker != null)
        'sticker': _EditorAction.sticker,
    };
    final candidates = [
      for (final id in WenyouEditorContract.primaryPromotionOrder)
        ?available[id],
    ];
    return candidates.take(promotionSlots).toSet();
  }

  void _insertHorizontalRule() {
    _insertBlockEmbed(
      const Embeddable(MarkdownDeltaCodec.horizontalRuleEmbed, {'version': 1}),
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

enum _EditorAction { quote, horizontalRule, sticker }

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.selected = false,
    super.key,
  });

  final String icon;
  final String label;
  final bool enabled;
  final bool selected;
  final FutureOr<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints.tightFor(
        width: WenyouEditorContract.minimumActionExtent,
        height: WenyouEditorContract.minimumActionExtent,
      ),
      onPressed: enabled ? () => onPressed() : null,
      isSelected: selected,
      selectedIcon: WenyouIcon(
        icon,
        color: context.wenyouTokens.brandForeground,
      ),
      icon: WenyouIcon(icon),
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
    return WenyouComposerSubmitButton(
      key: const Key('editor-submit'),
      enabled: enabled,
      loading: loading,
      label: label,
      onPressed: () => onPressed(),
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

  final String icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints(
        minWidth: WenyouEditorContract.minimumActionExtent,
        minHeight: WenyouEditorContract.minimumActionExtent,
      ),
      tooltip: label,
      isSelected: selected,
      selectedIcon: WenyouIcon(
        icon,
        color: context.wenyouTokens.brandForeground,
      ),
      onPressed: onPressed,
      icon: WenyouIcon(icon),
    );
  }
}
