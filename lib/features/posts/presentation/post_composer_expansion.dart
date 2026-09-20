import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';

class ExpandablePostComposer extends StatefulWidget {
  const ExpandablePostComposer({
    super.key,
    required this.target,
    required this.baseline,
    required this.composerKey,
    required this.onClose,
    required this.onRequestClose,
    this.onDraftChanged,
  });

  final PostComposerTarget target;
  final PostComposerBaseline baseline;
  final ValueChanged<PostComposerDraft?>? onDraftChanged;
  final GlobalKey composerKey;
  final VoidCallback onRequestClose;
  final ValueChanged<PostItem?> onClose;

  @override
  State<ExpandablePostComposer> createState() => ExpandablePostComposerState();
}

class ExpandablePostComposerState extends State<ExpandablePostComposer> {
  static const _minimumExtent = .30;
  static const _maximumExtent = .94;
  late final double _restingExtent;
  late double _extent;
  double? _extentBeforeToolbar;
  bool _toolbarAutoExpanded = false;
  bool _dismissEnabled = true;

  @override
  void initState() {
    super.initState();
    _restingExtent = switch (widget.target.kind) {
      PostComposerKind.createFloor || PostComposerKind.createReply => .40,
      PostComposerKind.editPost || PostComposerKind.upsertBody => .52,
    };
    _extent = _restingExtent;
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = (constraints.maxHeight - keyboard).clamp(
          0.0,
          constraints.maxHeight,
        );
        final desiredHeight = constraints.maxHeight * _extent;
        final sheetHeight = desiredHeight < availableHeight
            ? desiredHeight
            : availableHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              label: '收起编辑器并保留草稿',
              button: true,
              enabled: _dismissEnabled,
              child: GestureDetector(
                key: const Key('post-composer-dismiss-region'),
                behavior: HitTestBehavior.opaque,
                onTap: _dismissEnabled ? widget.onRequestClose : null,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: keyboard),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  key: const Key('post-composer-viewport'),
                  height: sheetHeight,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Material(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: PostComposerSheet(
                        key: widget.composerKey,
                        target: widget.target,
                        baseline: widget.baseline,
                        onDraftChanged: widget.onDraftChanged,
                        onClose: widget.onClose,
                        expanded: _extent >= _maximumExtent - .01,
                        onResize: (delta) {
                          _cancelToolbarRestore();
                          setState(() {
                            _extent = (_extent - delta / constraints.maxHeight)
                                .clamp(_minimumExtent, _maximumExtent);
                          });
                        },
                        onToggleExpanded: () {
                          _cancelToolbarRestore();
                          setState(() {
                            _extent = _extent >= _maximumExtent - .01
                                ? _restingExtent
                                : _maximumExtent;
                          });
                        },
                        onToolbarInteractionChanged: (open, requiredHeight) =>
                            _handleToolbarInteraction(
                              open: open,
                              requiredHeight: requiredHeight,
                              viewportHeight: constraints.maxHeight,
                            ),
                        onMinimumHeightRequired: (requiredHeight) =>
                            _ensureMinimumHeight(
                              requiredHeight: requiredHeight,
                              viewportHeight: constraints.maxHeight,
                            ),
                        onDismissEnabledChanged: (enabled) {
                          if (!mounted || _dismissEnabled == enabled) return;
                          setState(() => _dismissEnabled = enabled);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleToolbarInteraction({
    required bool open,
    required double requiredHeight,
    required double viewportHeight,
  }) {
    if (!mounted || viewportHeight <= 0) return;
    if (!open) {
      final previous = _extentBeforeToolbar;
      final shouldRestore = _toolbarAutoExpanded && previous != null;
      _extentBeforeToolbar = null;
      _toolbarAutoExpanded = false;
      if (shouldRestore && (_extent - previous).abs() > .001) {
        setState(() => _extent = previous);
      }
      return;
    }
    final requiredExtent = (requiredHeight / viewportHeight).clamp(
      _minimumExtent,
      _maximumExtent,
    );
    if (requiredExtent <= _extent + .001) return;
    _extentBeforeToolbar ??= _extent;
    _toolbarAutoExpanded = true;
    setState(() => _extent = requiredExtent);
  }

  void _cancelToolbarRestore() {
    _extentBeforeToolbar = null;
    _toolbarAutoExpanded = false;
  }

  void _ensureMinimumHeight({
    required double requiredHeight,
    required double viewportHeight,
  }) {
    if (!mounted || viewportHeight <= 0) return;
    final requiredExtent = (requiredHeight / viewportHeight).clamp(
      _minimumExtent,
      _maximumExtent,
    );
    if (requiredExtent <= _extent + .001) return;
    setState(() => _extent = requiredExtent);
  }
}
