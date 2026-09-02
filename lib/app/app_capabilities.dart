import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppCapabilities {
  const AppCapabilities({
    this.stickers = false,
    this.directMessages = false,
    this.pushNotifications = false,
    this.markdownAlignment = false,
    this.markdownImageAlignment = false,
  });

  final bool stickers;
  final bool directMessages;
  final bool pushNotifications;
  final bool markdownAlignment;
  final bool markdownImageAlignment;
}

/// Application composition supplies the server-advertised capability set.
///
/// Feature modules depend on this pure contract instead of reaching back into
/// app-shell startup state. Isolated feature tests may override their local
/// boolean provider without bootstrapping the whole application.
final appCapabilitiesProvider = Provider<AppCapabilities>(
  (ref) => const AppCapabilities(),
);
