import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

const _maximumDiagnosticEntries = 40;
const _maximumStackLines = 120;
const wenyouFieldDiagnosticsEnabled = bool.fromEnvironment(
  'WENYOU_ENABLE_FIELD_DIAGNOSTICS',
  defaultValue: false,
);
const wenyouRendererVariant = String.fromEnvironment(
  'WENYOU_RENDERER_VARIANT',
  defaultValue: 'unspecified',
);

/// Installs debug-only error capture without changing Flutter's error policy.
///
/// Exception messages are deliberately excluded because they can contain
/// server payloads or user content. The runtime type and stack are sufficient
/// for locating the failing code path in a remote reproduction.
void installWenyouDebugDiagnostics() {
  if (!kDebugMode || DebugDiagnosticBuffer.instance.isErrorCaptureInstalled) {
    return;
  }
  DebugDiagnosticBuffer.instance.isErrorCaptureInstalled = true;

  final previousFlutterHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    DebugDiagnosticBuffer.instance.recordFlutterError(details);
    if (previousFlutterHandler case final handler?) {
      handler(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  final previousPlatformHandler = ui.PlatformDispatcher.instance.onError;
  ui.PlatformDispatcher.instance.onError = (error, stackTrace) {
    DebugDiagnosticBuffer.instance.record('platform_error', {
      'errorType': error.runtimeType.toString(),
    }, stackTrace: stackTrace);
    return previousPlatformHandler?.call(error, stackTrace) ?? false;
  };
}

class DebugDiagnosticBuffer extends ChangeNotifier {
  DebugDiagnosticBuffer._();

  static final instance = DebugDiagnosticBuffer._();

  final _entries = <_DebugDiagnosticEntry>[];
  bool isErrorCaptureInstalled = false;

  void record(
    String category,
    Map<String, Object?> fields, {
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    _entries.add(
      _DebugDiagnosticEntry(
        capturedAt: DateTime.now().toUtc(),
        category: category,
        fields: Map.unmodifiable(fields),
        stackTrace: stackTrace == null ? null : _limitStack(stackTrace),
      ),
    );
    if (_entries.length > _maximumDiagnosticEntries) {
      _entries.removeRange(0, _entries.length - _maximumDiagnosticEntries);
    }
    notifyListeners();
  }

  void recordFlutterError(FlutterErrorDetails details) {
    record('flutter_error', {
      'errorType': details.exception.runtimeType.toString(),
      'library': details.library ?? 'unknown',
    }, stackTrace: details.stack);
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  String exportText() {
    final encoder = const JsonEncoder.withIndent('  ');
    final output = StringBuffer(
      '温油站 Debug 现场诊断\n'
      '隐私说明：不包含正文、帖子 ID、账号、Token、私聊或请求 URL。\n',
    );
    if (_entries.isEmpty) {
      output.writeln('暂无诊断记录。');
      return output.toString();
    }
    for (var index = 0; index < _entries.length; index += 1) {
      final entry = _entries[index];
      output
        ..writeln(
          '\n#${index + 1} ${entry.category} ${entry.capturedAt.toIso8601String()}',
        )
        ..writeln(encoder.convert(entry.fields));
      if (entry.stackTrace case final stack?) {
        output
          ..writeln('stack:')
          ..writeln(stack);
      }
    }
    return output.toString();
  }
}

class WenyouDebugDiagnosticOverlay extends StatefulWidget {
  const WenyouDebugDiagnosticOverlay({required this.child, super.key});

  final Widget child;

  @override
  State<WenyouDebugDiagnosticOverlay> createState() =>
      _WenyouDebugDiagnosticOverlayState();
}

class _WenyouDebugDiagnosticOverlayState
    extends State<WenyouDebugDiagnosticOverlay> {
  var _isOpen = false;
  var _copyStatus = '';

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_isOpen)
          _DiagnosticPanel(
            copyStatus: _copyStatus,
            onClose: () => setState(() {
              _isOpen = false;
              _copyStatus = '';
            }),
            onClear: () {
              DebugDiagnosticBuffer.instance.clear();
              _captureWindowMetrics();
              setState(() => _copyStatus = '已清空，仅保留当前窗口指标');
            },
            onCopy: _copyDiagnostics,
          )
        else
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: Material(
                color: const Color(0xE6222228),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  key: const Key('debug-diagnostic-open'),
                  onTap: () {
                    _captureWindowMetrics();
                    setState(() => _isOpen = true);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text(
                      '诊断',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _captureWindowMetrics() {
    final media = MediaQuery.of(context);
    final view = View.of(context);
    DebugDiagnosticBuffer.instance.record('window_metrics', {
      'rendererVariant': wenyouRendererVariant,
      'logicalWidth': media.size.width,
      'logicalHeight': media.size.height,
      'devicePixelRatio': view.devicePixelRatio,
      'physicalWidth': view.physicalSize.width,
      'physicalHeight': view.physicalSize.height,
      'effectivePadding': _edgeInsets(media.padding),
      'effectiveViewPadding': _edgeInsets(media.viewPadding),
      'effectiveViewInsets': _edgeInsets(media.viewInsets),
      'effectiveSystemGestures': _edgeInsets(media.systemGestureInsets),
      'rawPaddingPhysical': _viewPadding(view.padding),
      'rawViewPaddingPhysical': _viewPadding(view.viewPadding),
      'rawViewInsetsPhysical': _viewPadding(view.viewInsets),
      'rawSystemGesturesPhysical': _viewPadding(view.systemGestureInsets),
    });
  }

  Future<void> _copyDiagnostics() async {
    _captureWindowMetrics();
    final text = DebugDiagnosticBuffer.instance.exportText();
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) setState(() => _copyStatus = '已复制，可直接粘贴发送');
    } on PlatformException {
      if (mounted) setState(() => _copyStatus = '复制失败，请长按选择下面的文本');
    }
  }
}

class _DiagnosticPanel extends StatelessWidget {
  const _DiagnosticPanel({
    required this.copyStatus,
    required this.onClose,
    required this.onClear,
    required this.onCopy,
  });

  final String copyStatus;
  final VoidCallback onClose;
  final VoidCallback onClear;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('debug-diagnostic-panel'),
      color: const Color(0xFFF7F7F9),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '现场诊断（Debug）',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Semantics(
                    label: '关闭诊断面板',
                    button: true,
                    child: IconButton(
                      key: const Key('debug-diagnostic-close'),
                      onPressed: onClose,
                      icon: const WenyouIcon(WenyouIconIds.actionClose),
                    ),
                  ),
                ],
              ),
              const Text('请先复现问题，再点“复制全部”发给开发者。内容已脱敏。'),
              if (copyStatus.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(copyStatus, key: const Key('debug-diagnostic-status')),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD7D7DC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AnimatedBuilder(
                    animation: DebugDiagnosticBuffer.instance,
                    builder: (context, _) => SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: SelectableText(
                        DebugDiagnosticBuffer.instance.exportText(),
                        key: const Key('debug-diagnostic-text'),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Color(0xFF25252B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    key: const Key('debug-diagnostic-clear'),
                    onPressed: onClear,
                    child: const Text('清空'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    key: const Key('debug-diagnostic-copy'),
                    onPressed: onCopy,
                    icon: const WenyouIcon(WenyouIconIds.actionCopy),
                    label: const Text('复制全部'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebugDiagnosticEntry {
  const _DebugDiagnosticEntry({
    required this.capturedAt,
    required this.category,
    required this.fields,
    this.stackTrace,
  });

  final DateTime capturedAt;
  final String category;
  final Map<String, Object?> fields;
  final String? stackTrace;
}

Map<String, double> _edgeInsets(EdgeInsets value) => {
  'left': value.left,
  'top': value.top,
  'right': value.right,
  'bottom': value.bottom,
};

Map<String, double> _viewPadding(ui.ViewPadding value) => {
  'left': value.left,
  'top': value.top,
  'right': value.right,
  'bottom': value.bottom,
};

String _limitStack(StackTrace stackTrace) {
  return stackTrace.toString().split('\n').take(_maximumStackLines).join('\n');
}
