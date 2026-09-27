import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_notice_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update_notice.dart';

class MemoryNoticeStore implements MobileUpdateNoticeStore {
  final records = <MobileClientPlatform, MobileUpdateNoticeRecord>{};
  bool failRead = false;
  bool failWrite = false;
  @override
  Future<MobileUpdateNoticeRecord?> read(MobileClientPlatform platform) async {
    if (failRead) throw StateError('read failed');
    return records[platform];
  }

  @override
  Future<void> write(
    MobileClientPlatform platform,
    MobileUpdateNoticeRecord record,
  ) async {
    if (failWrite) throw StateError('write failed');
    records[platform] = record;
  }
}
