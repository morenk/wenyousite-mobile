import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_legacy_mapping.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_font_panel.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_font_specimen.dart';

class EditorDynamicFontList extends StatelessWidget {
  const EditorDynamicFontList({
    required this.service,
    required this.runtime,
    required this.writeEnabled,
    required this.recent,
    this.selectedFont,
    this.mixedSelection = false,
    super.key,
  });
  final TextFontService service;
  final TextFontRuntime runtime;
  final bool writeEnabled;
  final List<String> recent;
  final String? selectedFont;
  final bool mixedSelection;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: runtime,
    builder: (context, _) {
      final entries =
          service.dynamicRuntime?.catalog.entries.toList() ??
          <FontCatalogEntryDto>[];
      final selectedVersion = selectedFont == null
          ? null
          : dynamicTextFontVersion(selectedFont!);
      FontCatalogEntryDto? current;
      for (final entry in entries) {
        if (entry.versionId == selectedVersion) current = entry;
      }
      final currentName = selectedVersion == null
          ? null
          : service.dynamicRuntime?.catalog.descriptor(selectedVersion)?.name;
      entries.sort((a, b) {
        final ai = recent.indexOf(a.versionId),
            bi = recent.indexOf(b.versionId);
        final order = (ai < 0 ? 100 : ai).compareTo(bi < 0 ? 100 : bi);
        if (order != 0) return order;
        final sort = a.sortOrder.compareTo(b.sortOrder);
        return sort != 0 ? sort : a.familyId.compareTo(b.familyId);
      });
      return EditorFontPanel(
        initialLanguage: current == null
            ? 'zh'
            : editorFontLanguage(current.designLanguage.name),
        hasOther: entries.any(
          (e) => editorFontLanguage(e.designLanguage.name) == 'other',
        ),
        defaultSelected: !mixedSelection && selectedFont == null,
        writeEnabled: writeEnabled,
        selectionLabel: mixedSelection
            ? '多种字体'
            : selectedFont != null && current == null
            ? (currentName == null ? '当前字体暂不可用' : '当前：$currentName')
            : null,
        body: (context, language) {
          final matching = entries
              .where(
                (e) => editorFontLanguage(e.designLanguage.name) == language,
              )
              .toList();
          if (matching.isEmpty) {
            return Center(child: Text(entries.isEmpty ? '字体暂不可用' : '暂无这类字体'));
          }
          return ListView.builder(
            key: Key('editor-font-list-$language'),
            padding: EdgeInsets.only(bottom: context.wenyouTokens.space16),
            scrollCacheExtent: const ScrollCacheExtent.pixels(0),
            addAutomaticKeepAlives: false,
            itemCount: matching.length,
            itemBuilder: (context, index) {
              final entry = matching[index];
              return _DynamicFontTile(
                key: ValueKey(entry.versionId),
                entry: entry,
                service: service,
                enabled: writeEnabled,
                selected: !mixedSelection && entry.versionId == selectedVersion,
              );
            },
          );
        },
      );
    },
  );
}

class _DynamicFontTile extends StatefulWidget {
  const _DynamicFontTile({
    required this.entry,
    required this.service,
    required this.enabled,
    required this.selected,
    super.key,
  });
  final FontCatalogEntryDto entry;
  final TextFontService service;
  final bool enabled;
  final bool selected;
  @override
  State<_DynamicFontTile> createState() => _DynamicFontTileState();
}

class _DynamicFontTileState extends State<_DynamicFontTile>
    with WidgetsBindingObserver {
  Uint8List? _image;
  bool _selecting = false, _loading = false, _foreground = true;
  Timer? _retry;
  int _failures = 0, _generation = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  Future<void> _load() async {
    if (!mounted || !_foreground || _loading || _image != null) return;
    _loading = true;
    final generation = ++_generation;
    Uint8List? bytes;
    try {
      bytes = await widget.service.specimen(
        widget.entry,
        owner: this,
        isActive: () => mounted && _foreground && generation == _generation,
      );
    } on Object {
      /* 样张不影响选择；共享服务保留网络退避。 */
    }
    if (!mounted || generation != _generation) return;
    _loading = false;
    setState(() => _image = bytes);
    if (bytes == null && _foreground) {
      _failures++;
      final delay = _failures >= 6 ? 60 : 1 << _failures;
      _retry?.cancel();
      _retry = Timer(Duration(seconds: delay), () => unawaited(_load()));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) {
      _retry?.cancel();
      widget.service.cancelSpecimen(this);
    } else {
      unawaited(_load());
    }
  }

  @override
  void didUpdateWidget(covariant _DynamicFontTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.specimen.sha256 != widget.entry.specimen.sha256) {
      _generation++;
      _loading = false;
      _image = null;
      _failures = 0;
      _retry?.cancel();
      widget.service.cancelSpecimen(this);
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    _generation++;
    _retry?.cancel();
    widget.service.cancelSpecimen(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final enabled = widget.enabled && !_selecting;
    return Semantics(
      key: Key('editor-font-${widget.entry.versionId}'),
      button: true,
      selected: widget.selected,
      enabled: enabled,
      child: Material(
        color: widget.selected ? tokens.accentedBackground : Colors.transparent,
        child: InkWell(
          onTap: enabled ? _select : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space16,
              vertical: tokens.space4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.entry.name,
                        style: Theme.of(context).textTheme.wenyouCaption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.selected)
                      WenyouIcon(
                        WenyouIconIds.actionConfirm,
                        color: tokens.onAccentedBackground,
                        size: 16,
                      ),
                  ],
                ),
                SizedBox(height: tokens.space4),
                SizedBox(
                  height: 30,
                  child: _image == null
                      ? const SizedBox.shrink()
                      : EditorFontSpecimen(bytes: _image!, color: tokens.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _select() async {
    setState(() => _selecting = true);
    await widget.service.checkPasteVersions({widget.entry.versionId});
    if (!mounted || !context.mounted) return;
    if (widget.service.dynamicRuntime?.catalog.canSelect(
          widget.entry.versionId,
        ) ==
        true) {
      Navigator.pop(context, widget.entry.versionId);
    } else {
      setState(() => _selecting = false);
      showWenyouSnackBar(context, '字体暂不可用', tone: WenyouSnackBarTone.error);
    }
  }
}
