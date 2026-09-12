import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClipboardNavigationSnapshot {
  const ClipboardNavigationSnapshot({
    required this.text,
    required this.changeToken,
  });

  final String text;
  final String? changeToken;
}

class HandledClipboardNavigation {
  const HandledClipboardNavigation({
    required this.changeToken,
    required this.fingerprint,
  });

  final String? changeToken;
  final String fingerprint;
}

abstract interface class ClipboardNavigationGateway {
  Future<String?> readChangeToken();

  Future<ClipboardNavigationSnapshot?> readSnapshot();
}

abstract interface class HandledClipboardNavigationStore {
  Future<HandledClipboardNavigation?> read();

  Future<void> write(HandledClipboardNavigation value);
}

final clipboardNavigationGatewayProvider = Provider<ClipboardNavigationGateway>(
  (ref) => const _UnavailableClipboardNavigationGateway(),
);

final handledClipboardNavigationStoreProvider =
    Provider<HandledClipboardNavigationStore>(
      (ref) => _MemoryHandledClipboardNavigationStore(),
    );

class _UnavailableClipboardNavigationGateway
    implements ClipboardNavigationGateway {
  const _UnavailableClipboardNavigationGateway();

  @override
  Future<String?> readChangeToken() async => null;

  @override
  Future<ClipboardNavigationSnapshot?> readSnapshot() async => null;
}

class _MemoryHandledClipboardNavigationStore
    implements HandledClipboardNavigationStore {
  HandledClipboardNavigation? _value;

  @override
  Future<HandledClipboardNavigation?> read() async => _value;

  @override
  Future<void> write(HandledClipboardNavigation value) async {
    _value = value;
  }
}
