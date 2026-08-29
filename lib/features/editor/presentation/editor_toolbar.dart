import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_capabilities.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_dice_input_tray.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar_buttons.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar_input_tray.dart';

export 'package:wenyousite_mobile/features/editor/presentation/editor_capabilities.dart'
    show WenyouEditorCapabilities;

enum WenyouComposerSurface { page, expandableSheet, inline }

typedef WenyouComposerDock = WenyouEditorToolbar;

typedef _EditorDiceInputValue = ({
  String quantity,
  String sides,
  String modifier,
});

_EditorDiceInputValue get _defaultEditorDiceInput => (
  quantity: '${WenyouElementContract.diceDefaultQuantity}',
  sides: '${WenyouElementContract.diceDefaultSides}',
  modifier: '${WenyouElementContract.diceDefaultModifier}',
);

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
    this.onInsertHorizontalRule,
    this.editorFocusNode,
    this.onInteractionChanged,
    this.onSubmit,
    this.isSubmitting = false,
    this.submitLabel = '发送',
    this.characterCount,
    this.characterLimit,
    this.draftStatusLabel,
    this.toolbarController,
    this.surface = WenyouComposerSurface.page,
    this.capabilities = WenyouEditorCapabilities.richMarkdown,
    super.key,
  });

  final QuillController controller;
  final Future<void> Function() onInsertImage;
  final Future<void> Function(TextSelection selection)? onInsertSticker;
  final VoidCallback? onInsertHorizontalRule;
  final Future<void> Function() onSaveDraft;
  final bool enabled;
  final FocusNode? editorFocusNode;
  final ValueChanged<bool>? onInteractionChanged;
  final FutureOr<void> Function()? onSubmit;
  final bool isSubmitting;
  final String submitLabel;
  final int? characterCount;
  final int? characterLimit;
  final String? draftStatusLabel;
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
  late final TextEditingController _diceQuantityController;
  late final TextEditingController _diceSidesController;
  late final TextEditingController _diceModifierController;
  late _EditorDiceInputValue _lastSuccessfulDiceInput;
  TextSelection? _preservedSelection;
  String? _linkLabelError;
  String? _linkUrlError;
  EditorDiceInputErrors _diceErrors = noEditorDiceInputErrors;

  @override
  void initState() {
    super.initState();
    _linkLabelController = TextEditingController();
    _linkUrlController = TextEditingController();
    _lastSuccessfulDiceInput = _defaultEditorDiceInput;
    _diceQuantityController = TextEditingController(
      text: _lastSuccessfulDiceInput.quantity,
    );
    _diceSidesController = TextEditingController(
      text: _lastSuccessfulDiceInput.sides,
    );
    _diceModifierController = TextEditingController(
      text: _lastSuccessfulDiceInput.modifier,
    );
    widget.controller.addListener(_onControllerChanged);
    _syncToolbarController();
  }

  @override
  void didUpdateWidget(covariant WenyouEditorToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _lastSuccessfulDiceInput = _defaultEditorDiceInput;
      _applyDiceInput(_lastSuccessfulDiceInput);
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
    _diceQuantityController.dispose();
    _diceSidesController.dispose();
    _diceModifierController.dispose();
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
    final taskTrayOpen = _tray == _EditorTray.link || _tray == _EditorTray.dice;
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
              if (!taskTrayOpen)
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
                            WenyouEditorToolbarButton(
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
                            WenyouEditorToolbarButton(
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
                            WenyouEditorToolbarButton(
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
                            WenyouEditorToolbarButton(
                              key: const Key('editor-image'),
                              icon: WenyouIconIds.editorImage,
                              label: '图片',
                              enabled: widget.enabled,
                              onPressed: () =>
                                  _runExternal(widget.onInsertImage),
                            ),
                          if (promoted.contains(_EditorAction.quote))
                            WenyouEditorToolbarButton(
                              key: const Key('editor-quote'),
                              icon: WenyouIconIds.editorQuote,
                              label: '引用',
                              enabled: widget.enabled,
                              selected: style.attributes.containsKey(
                                Attribute.blockQuote.key,
                              ),
                              onPressed: () => _toggle(Attribute.blockQuote),
                            ),
                          if (promoted.contains(_EditorAction.sticker))
                            WenyouEditorToolbarButton(
                              key: const Key('editor-sticker'),
                              icon: WenyouIconIds.editorSticker,
                              label: '表情包',
                              enabled: widget.enabled,
                              onPressed: () => _runSelectionExternal(
                                widget.onInsertSticker!,
                              ),
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
                            WenyouEditorToolbarButton(
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
                            WenyouEditorSubmitButton(
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
            final toolbarAvailableWidth =
                constraints.maxWidth -
                WenyouEditorContract.toolbarHorizontalPadding * 2;
            final draftInline = _draftFitsInToolbarRow(toolbarAvailableWidth);
            final promoted = _promotedActionsForWidth(
              toolbarAvailableWidth,
              reserveDraft: draftInline,
            );
            final items = <Widget>[
              if (widget.capabilities.links)
                WenyouEditorTrayButton(
                  icon: WenyouIconIds.editorLink,
                  label: '链接',
                  onPressed: _openLinkTray,
                ),
              if (widget.capabilities.inlineStyles)
                WenyouEditorTrayButton(
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
                  WenyouEditorTrayButton(
                    icon: WenyouIconIds.editorQuote,
                    label: '引用',
                    selected: style.attributes.containsKey(
                      Attribute.blockQuote.key,
                    ),
                    onPressed: () =>
                        _runTrayAction(() => _toggle(Attribute.blockQuote)),
                  ),
                WenyouEditorTrayButton(
                  icon: WenyouIconIds.editorBulletList,
                  label: '无序列表',
                  selected: WenyouEditorFormatPolicy.isActive(
                    style,
                    Attribute.ul,
                  ),
                  onPressed: () => _runTrayAction(() => _toggle(Attribute.ul)),
                ),
                WenyouEditorTrayButton(
                  icon: WenyouIconIds.editorOrderedList,
                  label: '有序列表',
                  selected: WenyouEditorFormatPolicy.isActive(
                    style,
                    Attribute.ol,
                  ),
                  onPressed: () => _runTrayAction(() => _toggle(Attribute.ol)),
                ),
                WenyouEditorTrayButton(
                  key: const Key('editor-horizontal-rule'),
                  icon: WenyouIconIds.editorHorizontalRule,
                  label: '分隔线',
                  onPressed: () => _runTrayAction(_insertHorizontalRule),
                ),
              ],
              if (widget.capabilities.alignment) _buildAlignmentButton(),
              if (widget.capabilities.dice)
                WenyouEditorTrayButton(
                  icon: WenyouIconIds.editorDice,
                  label: '骰子',
                  onPressed: _openDiceTray,
                ),
              if (widget.capabilities.stickers &&
                  widget.onInsertSticker != null &&
                  !promoted.contains(_EditorAction.sticker))
                WenyouEditorTrayButton(
                  icon: WenyouIconIds.editorSticker,
                  label: '表情包',
                  onPressed: () =>
                      _runSelectionExternal(widget.onInsertSticker!),
                ),
              if (widget.capabilities.inlineStyles)
                WenyouEditorTrayButton(
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

  Widget _buildAlignmentButton() {
    final alignment = WenyouEditorFormatPolicy.selectedAlignment(
      widget.controller,
    );
    final (icon, label) = switch (alignment) {
      WenyouTextAlignment.left => (WenyouIconIds.editorAlignLeft, '左对齐（点击切换）'),
      WenyouTextAlignment.center => (
        WenyouIconIds.editorAlignCenter,
        '居中（点击切换）',
      ),
      WenyouTextAlignment.right => (
        WenyouIconIds.editorAlignRight,
        '右对齐（点击切换）',
      ),
    };
    return WenyouEditorTrayButton(
      key: const Key('editor-alignment'),
      icon: icon,
      label: label,
      selected: alignment != WenyouTextAlignment.left,
      onPressed: () => _runTrayAction(
        () => WenyouEditorFormatPolicy.cycleAlignment(widget.controller),
      ),
    );
  }

  Widget _buildLinkTray(BuildContext context) {
    return EditorInlineInputTray(
      key: const Key('editor-link-tray'),
      primaryController: _linkLabelController,
      primaryLabel: '显示文字',
      secondaryController: _linkUrlController,
      secondaryLabel: '链接地址',
      primaryError: _linkLabelError,
      secondaryError: _linkUrlError,
      onBack: () => _setTray(_EditorTray.more),
      onConfirm: _insertLink,
      onInputChanged: _clearLinkErrors,
    );
  }

  Widget _buildDiceTray(BuildContext context) {
    return EditorDiceInputTray(
      key: const Key('editor-dice-tray'),
      quantityController: _diceQuantityController,
      sidesController: _diceSidesController,
      modifierController: _diceModifierController,
      errors: _diceErrors,
      currentCount: MarkdownDiceContract.countDeltaNodes(
        widget.controller.document.toDelta(),
      ),
      insertEnabled:
          MarkdownDiceContract.countDeltaNodes(
            widget.controller.document.toDelta(),
          ) <
          MarkdownDiceContract.maximumNodesPerPost,
      onBack: () => _setTray(_EditorTray.more),
      onConfirm: _insertDice,
      onInputChanged: _clearDiceErrors,
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
      _linkLabelError = null;
      _linkUrlError = null;
      _diceErrors = noEditorDiceInputErrors;
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
    WenyouEditorFormatPolicy.applyHeading(widget.controller, selected);
    _setTray(_EditorTray.none);
  }

  void _toggle(Attribute attribute) {
    WenyouEditorFormatPolicy.toggle(widget.controller, attribute);
    widget.editorFocusNode?.requestFocus();
  }

  Widget _buildDraftToolbarButton() {
    return WenyouEditorToolbarButton(
      key: const Key('editor-content-drafts'),
      icon: WenyouIconIds.editorContentDrafts,
      label: _draftActionLabel,
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
            label: Text(_draftActionLabel),
          ),
        ),
      ),
    );
  }

  String get _draftActionLabel => widget.draftStatusLabel == null
      ? '正文草稿'
      : '正文草稿 · ${widget.draftStatusLabel}';

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
    final callback = widget.onInsertHorizontalRule;
    if (callback != null) {
      callback();
    } else {
      _insertBlockEmbed(
        const Embeddable(MarkdownDeltaCodec.horizontalRuleEmbed, {
          'version': 1,
        }),
      );
    }
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

  Future<void> _runSelectionExternal(
    Future<void> Function(TextSelection selection) action,
  ) {
    final selection = widget.controller.selection;
    return _runExternal(() => action(selection));
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
    final labelError = label.isEmpty ? '请填写显示文字' : null;
    final urlError =
        uri == null || !uri.hasScheme || !MarkdownContent.isSafeLink(uri)
        ? '仅支持 HTTP(S) 或 mailto 链接'
        : null;
    if (labelError != null || urlError != null) {
      setState(() {
        _linkLabelError = labelError;
        _linkUrlError = urlError;
      });
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
      WenyouEditorFormatPolicy.applyLink(
        widget.controller,
        selection: TextSelection(
          baseOffset: selection.start,
          extentOffset: selection.start + label.length,
        ),
        url: url,
      );
    } else {
      WenyouEditorFormatPolicy.applyLink(
        widget.controller,
        selection: selection,
        url: url,
      );
    }
    _setTray(_EditorTray.none);
  }

  void _openDiceTray() {
    _preservedSelection = widget.controller.selection;
    _applyDiceInput(_lastSuccessfulDiceInput);
    _setTray(_EditorTray.dice);
  }

  void _insertDice() {
    if (MarkdownDiceContract.countDeltaNodes(
          widget.controller.document.toDelta(),
        ) >=
        MarkdownDiceContract.maximumNodesPerPost) {
      return;
    }
    final errors = validateEditorDiceInputs(
      quantity: _diceQuantityController.text,
      sides: _diceSidesController.text,
      modifier: _diceModifierController.text,
    );
    if (hasEditorDiceInputErrors(errors)) {
      setState(() => _diceErrors = errors);
      return;
    }
    final normalized = canonicalDiceNotation(
      quantity: _diceQuantityController.text,
      sides: _diceSidesController.text,
      modifier: _diceModifierController.text,
    );
    if (normalized == null) return;
    _lastSuccessfulDiceInput = (
      quantity: '${int.parse(_diceQuantityController.text.trim())}',
      sides: '${int.parse(_diceSidesController.text.trim())}',
      modifier:
          '${int.tryParse(_diceModifierController.text.trim()) ?? WenyouElementContract.diceDefaultModifier}',
    );
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

  void _applyDiceInput(_EditorDiceInputValue input) {
    void replace(TextEditingController controller, String value) {
      controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    replace(_diceQuantityController, input.quantity);
    replace(_diceSidesController, input.sides);
    replace(_diceModifierController, input.modifier);
  }

  void _clearLinkErrors() {
    if (_linkLabelError == null && _linkUrlError == null) return;
    setState(() {
      _linkLabelError = null;
      _linkUrlError = null;
    });
  }

  void _clearDiceErrors() {
    if (!hasEditorDiceInputErrors(_diceErrors)) return;
    setState(() => _diceErrors = noEditorDiceInputErrors);
  }

  void _insertBlockEmbed(Embeddable embed) {
    final selection = widget.controller.selection;
    final plain = widget.controller.document.toPlainText();
    final documentEnd = widget.controller.document.length - 1;
    final start = selection.start.clamp(0, documentEnd).toInt();
    final end = selection.end.clamp(start, documentEnd).toInt();
    final needsLeadingNewline = start > 0 && plain[start - 1] != '\n';
    final needsTrailingNewline = end >= plain.length || plain[end] != '\n';
    final change = Delta()..retain(start);
    if (end > start) change.delete(end - start);
    if (needsLeadingNewline) change.insert('\n');
    change.insert(embed.toJson());
    if (needsTrailingNewline) {
      change.insert('\n');
    } else {
      change.retain(1, const {
        'header': null,
        'list': null,
        'blockquote': null,
        'indent': null,
      });
    }
    widget.controller.compose(change, selection, ChangeSource.local);
    final cursor =
        start +
        (needsLeadingNewline ? 1 : 0) +
        1 +
        (needsTrailingNewline || end < plain.length - 1 ? 1 : 0);
    widget.controller.updateSelection(
      TextSelection.collapsed(offset: cursor),
      ChangeSource.local,
    );
  }
}

enum _EditorTray { none, heading, more, link, dice }

enum _EditorAction { quote, sticker }
