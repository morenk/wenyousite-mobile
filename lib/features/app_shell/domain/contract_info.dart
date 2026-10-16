import 'package:wenyousite_mobile/core/media/audio_upload_policy.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

class ContractInfo {
  const ContractInfo({
    required this.contractVersion,
    required this.markdownContractVersion,
    this.buildSha,
    this.audioUpload,
    this.android = const MobilePlatformPolicy(),
    this.ios = const MobilePlatformPolicy(),
    this.stickersEnabled = false,
    this.directMessagesEnabled = false,
    this.pushNotificationsEnabled = false,
    this.roleMentionsSupported = false,
    this.roleMentionsWriteEnabled = false,
    this.rpIdentityProfileSupported = false,
  });

  final String contractVersion;
  final int markdownContractVersion;
  final String? buildSha;
  final AudioUploadPolicy? audioUpload;
  final MobilePlatformPolicy android;
  final MobilePlatformPolicy ios;
  final bool stickersEnabled;
  final bool directMessagesEnabled;
  final bool pushNotificationsEnabled;
  final bool roleMentionsSupported;
  final bool roleMentionsWriteEnabled;
  final bool rpIdentityProfileSupported;

  MobilePlatformPolicy policyFor(MobileClientPlatform platform) {
    return switch (platform) {
      MobileClientPlatform.android => android,
      MobileClientPlatform.ios => ios,
      MobileClientPlatform.unsupported => const MobilePlatformPolicy(),
    };
  }
}
