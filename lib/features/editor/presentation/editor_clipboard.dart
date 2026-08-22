import 'package:flutter_quill/quill_delta.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';

enum WenyouEditorClipboardOperation { copy, cut }

class WenyouEditorClipboardResolution {
  const WenyouEditorClipboardResolution._({
    this.delta,
    this.usePlainText = false,
  });

  const WenyouEditorClipboardResolution.noMatch() : this._();

  const WenyouEditorClipboardResolution.plainText()
    : this._(usePlainText: true);

  const WenyouEditorClipboardResolution.structured(Delta delta)
    : this._(delta: delta);

  final Delta? delta;
  final bool usePlainText;
}

class WenyouEditorClipboardStore {
  WenyouEditorClipboardStore({
    DateTime Function()? now,
    this.maximumAge = const Duration(minutes: 10),
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final Duration maximumAge;
  _EditorClipboardPayload? _payload;

  String capture({
    required Delta delta,
    required String plainTextFallback,
    required WenyouEditorClipboardOperation operation,
  }) {
    final cloned = Delta.fromJson(delta.toJson());
    var fallback = plainTextFallback;
    try {
      fallback = MarkdownDeltaCodec.encode(cloned);
    } on Object {
      // Plain text is still a safe interoperable fallback for a partial Delta.
    }
    _payload = _EditorClipboardPayload(
      delta: cloned,
      fallback: fallback,
      operation: operation,
      capturedAt: _now(),
    );
    return fallback;
  }

  WenyouEditorClipboardResolution resolve(String clipboardText) {
    final payload = _payload;
    if (payload == null) {
      return const WenyouEditorClipboardResolution.noMatch();
    }
    if (clipboardText != payload.fallback) {
      _payload = null;
      return const WenyouEditorClipboardResolution.noMatch();
    }
    if (_now().difference(payload.capturedAt) > maximumAge) {
      _payload = null;
      return const WenyouEditorClipboardResolution.plainText();
    }

    final regenerateDice =
        payload.operation == WenyouEditorClipboardOperation.copy;
    final transformed = _transformDiceIdentity(
      payload.delta,
      regenerateDice: regenerateDice,
    );
    try {
      MarkdownDeltaCodec.encode(transformed);
    } on Object {
      _payload = null;
      return const WenyouEditorClipboardResolution.plainText();
    }
    if (payload.operation == WenyouEditorClipboardOperation.cut) {
      _payload = payload.asCopy(capturedAt: _now());
    }
    return WenyouEditorClipboardResolution.structured(transformed);
  }

  static Delta _transformDiceIdentity(
    Delta source, {
    required bool regenerateDice,
  }) {
    final json = source
        .toJson()
        .map((operation) {
          final copy = Map<String, dynamic>.from(operation);
          final insert = copy['insert'];
          if (!regenerateDice || insert is! Map) return copy;
          final insertMap = Map<String, dynamic>.from(insert);
          final rawPayload = insertMap[MarkdownDiceContract.embedType];
          if (rawPayload is! Map) return copy;
          final dicePayload = Map<String, dynamic>.from(rawPayload);
          dicePayload['nodeId'] = const Uuid().v4();
          insertMap[MarkdownDiceContract.embedType] = dicePayload;
          copy['insert'] = insertMap;
          return copy;
        })
        .toList(growable: false);
    return Delta.fromJson(json);
  }
}

final wenyouEditorClipboardStore = WenyouEditorClipboardStore();

class _EditorClipboardPayload {
  const _EditorClipboardPayload({
    required this.delta,
    required this.fallback,
    required this.operation,
    required this.capturedAt,
  });

  final Delta delta;
  final String fallback;
  final WenyouEditorClipboardOperation operation;
  final DateTime capturedAt;

  _EditorClipboardPayload asCopy({required DateTime capturedAt}) =>
      _EditorClipboardPayload(
        delta: delta,
        fallback: fallback,
        operation: WenyouEditorClipboardOperation.copy,
        capturedAt: capturedAt,
      );
}
