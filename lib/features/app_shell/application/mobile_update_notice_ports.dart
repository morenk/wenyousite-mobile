import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update_notice.dart';

abstract interface class MobileUpdateNoticeStore {
  Future<MobileUpdateNoticeRecord?> read(MobileClientPlatform platform);
  Future<void> write(
    MobileClientPlatform platform,
    MobileUpdateNoticeRecord record,
  );
}

final mobileUpdateNoticeStoreProvider = Provider<MobileUpdateNoticeStore>(
  (ref) => throw StateError('MobileUpdateNoticeStore 尚未在应用组合根绑定。'),
);
