import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class EditorDynamicFontList extends StatelessWidget {
  const EditorDynamicFontList({
    required this.service,
    required this.runtime,
    required this.writeEnabled,
    required this.recent,
    super.key,
  });
  final TextFontService service;
  final TextFontRuntime runtime;
  final bool writeEnabled;
  final List<String> recent;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: runtime,
    builder: (context, _) {
      final entries =
          service.dynamicRuntime?.catalog.entries.toList() ??
          <FontCatalogEntryDto>[];
      entries.sort((a, b) {
        final ai = recent.indexOf(a.versionId),
            bi = recent.indexOf(b.versionId);
        final byRecent = (ai < 0 ? 100 : ai).compareTo(bi < 0 ? 100 : bi);
        if (byRecent != 0) return byRecent;
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        return byOrder != 0 ? byOrder : a.familyId.compareTo(b.familyId);
      });
      final rows = <({String? group, FontCatalogEntryDto? entry})>[];
      for (final language in const {
        'zh': '中文',
        'ja': '日文',
        'en': '英文',
        'other': '其他',
      }.entries) {
        final matching = entries
            .where((e) => e.designLanguage.name == language.key)
            .toList();
        if (matching.isEmpty) continue;
        rows.add((group: language.value, entry: null));
        rows.addAll(matching.map((e) => (group: null, entry: e)));
      }
      return ListView.builder(
        padding: EdgeInsets.all(context.wenyouTokens.space16),
        scrollCacheExtent: const ScrollCacheExtent.pixels(0),
        addAutomaticKeepAlives: false,
        itemCount: rows.length + 3,
        itemBuilder: (context, index) {
          if (index == 0) return const ListTile(title: Text('字体'));
          if (index == 1) {
            return ListTile(
              key: const Key('editor-font-default'),
              title: const Text('默认字体'),
              onTap: () => Navigator.pop(context, ''),
            );
          }
          if (index == 2) {
            if (!writeEnabled) {
              return const ListTile(title: Text('暂时无法更换字体，可恢复默认字体'));
            }
            if (entries.isEmpty) return const ListTile(title: Text('字体暂不可用'));
            return const SizedBox.shrink();
          }
          final row = rows[index - 3];
          if (row.group case final label?) return ListTile(title: Text(label));
          return _DynamicFontTile(
            key: ValueKey(row.entry!.versionId),
            entry: row.entry!,
            service: service,
            enabled: writeEnabled,
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
    super.key,
  });
  final FontCatalogEntryDto entry;
  final TextFontService service;
  final bool enabled;
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
  Widget build(BuildContext context) => ListTile(
    key: Key('editor-font-${widget.entry.versionId}'),
    title: Text(widget.entry.name),
    enabled: widget.enabled && !_selecting,
    subtitle: _image == null
        ? null
        : Image.memory(
            _image!,
            height: 48,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            excludeFromSemantics: true,
            cacheWidth: 600,
            cacheHeight: 120,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
    onTap: () async {
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
    },
  );
}
