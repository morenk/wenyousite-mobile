import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';

abstract interface class MobileReleaseRepository {
  Future<MobileRelease?> fetch(MobileReleaseTarget target);
}

final mobileReleaseRepositoryProvider = Provider<MobileReleaseRepository>(
  (ref) => throw StateError('MobileReleaseRepository 尚未在应用组合根绑定。'),
);
