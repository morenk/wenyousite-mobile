import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_ports.dart';

class DeviceClipboardNavigationGateway implements ClipboardNavigationGateway {
  const DeviceClipboardNavigationGateway();

  static const _channel = MethodChannel('site.wenyou.app/clipboard_navigation');

  @override
  Future<String?> readChangeToken() async {
    try {
      return _normalizeToken(
        await _channel.invokeMethod<String>('getChangeToken'),
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<ClipboardNavigationSnapshot?> readSnapshot() async {
    try {
      final value = await _channel.invokeMapMethod<String, Object?>(
        'readSnapshot',
      );
      final text = value?['text'];
      if (text is! String) return null;
      final changeToken = value?['changeToken'];
      return ClipboardNavigationSnapshot(
        text: text,
        changeToken: changeToken is String
            ? _normalizeToken(changeToken)
            : null,
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  String? _normalizeToken(String? value) {
    final token = value?.trim();
    if (token == null || token.isEmpty || token.length > 160) return null;
    return token;
  }
}

final deviceClipboardNavigationGatewayProvider =
    Provider<ClipboardNavigationGateway>(
      (ref) => const DeviceClipboardNavigationGateway(),
    );
