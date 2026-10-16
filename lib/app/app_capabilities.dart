import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/media/audio_upload_policy.dart';

class AppCapabilities {
  const AppCapabilities({
    this.audioUpload,
    this.stickers = false,
    this.directMessages = false,
    this.pushNotifications = false,
    this.markdownAlignment = false,
    this.markdownImageAlignment = false,
    this.legacySingleThreadIdentity = false,
    this.roleMentionsSupported = false,
    this.roleMentionsWriteEnabled = false,
    this.rpIdentityProfileSupported = false,
  });

  final bool stickers;
  final AudioUploadPolicy? audioUpload;
  final bool directMessages;
  final bool pushNotifications;
  final bool markdownAlignment;
  final bool markdownImageAlignment;
  final bool legacySingleThreadIdentity;
  final bool roleMentionsSupported;
  final bool roleMentionsWriteEnabled;
  final bool rpIdentityProfileSupported;
}

/// Application composition supplies the server-advertised capability set.
///
/// Feature modules depend on this pure contract instead of reaching back into
/// app-shell startup state. Isolated feature tests may override their local
/// boolean provider without bootstrapping the whole application.
final appCapabilitiesProvider = Provider<AppCapabilities>(
  (ref) => const AppCapabilities(),
);
