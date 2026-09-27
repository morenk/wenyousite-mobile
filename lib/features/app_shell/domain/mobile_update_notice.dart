import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

enum MobileUpdateNoticeKind { beforeUpdate, afterUpdate }

class MobileUpdateNoticeRecord {
  const MobileUpdateNoticeRecord({
    this.lastInstalledBuild,
    this.firstInstallMillis,
    this.pendingInstalledBuild,
    this.pendingFromInstallationEvidence = false,
    this.recommendedShown = const {},
    this.installedShown = const {},
  });

  final int? lastInstalledBuild;
  final int? firstInstallMillis;
  final int? pendingInstalledBuild;
  final bool pendingFromInstallationEvidence;
  final Set<int> recommendedShown;
  final Set<int> installedShown;

  MobileUpdateNoticeRecord observe(InstalledAppInfo installed) {
    final first = installed.firstInstallTime?.millisecondsSinceEpoch;
    final validFirst = first != null && first > 0 ? first : null;
    final differentInstallation =
        firstInstallMillis != null &&
        validFirst != null &&
        firstInstallMillis != validFirst;
    final previousBuild = lastInstalledBuild;
    int? pending;
    var migration = false;
    if (!differentInstallation) {
      if (previousBuild == null) {
        // 旧客户端没有 build 基线；系统覆盖安装证据只用于首次迁移，
        // 不据此虚构旧版本或声称 build 递增。
        if (installed.hasReplacementEvidence) {
          pending = installed.build;
          migration = true;
        }
      } else if (installed.build > previousBuild) {
        pending = installed.build;
      } else if (installed.build == previousBuild) {
        pending = pendingInstalledBuild;
        migration = pendingFromInstallationEvidence;
      }
    }
    if (installedShown.contains(pending)) pending = null;
    return MobileUpdateNoticeRecord(
      lastInstalledBuild: installed.build,
      firstInstallMillis: validFirst ?? firstInstallMillis,
      pendingInstalledBuild: pending,
      pendingFromInstallationEvidence: pending != null && migration,
      recommendedShown: recommendedShown,
      installedShown: installedShown,
    );
  }

  MobileUpdateNoticeRecord presented(MobileUpdateNoticeKind phase, int build) =>
      MobileUpdateNoticeRecord(
        lastInstalledBuild: lastInstalledBuild,
        firstInstallMillis: firstInstallMillis,
        pendingInstalledBuild:
            phase == MobileUpdateNoticeKind.afterUpdate &&
                pendingInstalledBuild == build
            ? null
            : pendingInstalledBuild,
        pendingFromInstallationEvidence:
            phase == MobileUpdateNoticeKind.afterUpdate &&
                pendingInstalledBuild == build
            ? false
            : pendingFromInstallationEvidence,
        recommendedShown: phase == MobileUpdateNoticeKind.beforeUpdate
            ? Set.unmodifiable({...recommendedShown, build})
            : recommendedShown,
        installedShown: phase == MobileUpdateNoticeKind.afterUpdate
            ? Set.unmodifiable({...installedShown, build})
            : installedShown,
      );

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'lastInstalledBuild': lastInstalledBuild,
    'firstInstallMillis': firstInstallMillis,
    'pendingInstalledBuild': pendingInstalledBuild,
    'pendingFromInstallationEvidence': pendingFromInstallationEvidence,
    'recommendedShown': recommendedShown.toList()..sort(),
    'installedShown': installedShown.toList()..sort(),
  };

  factory MobileUpdateNoticeRecord.fromJson(Object? value) {
    if (value is! Map<String, Object?> || value['schemaVersion'] != 1) {
      throw const FormatException('Invalid update notice record.');
    }
    int? build(Object? input) {
      if (input == null) return null;
      if (input is! int || input < 1 || input > 2100000000) {
        throw const FormatException('Invalid update notice build.');
      }
      return input;
    }

    Set<int> builds(Object? input) {
      if (input is! List) {
        throw const FormatException('Invalid update notice builds.');
      }
      return Set.unmodifiable(
        input.map((item) {
          final result = build(item);
          if (result == null) {
            throw const FormatException('Missing update notice build.');
          }
          return result;
        }),
      );
    }

    final first = value['firstInstallMillis'];
    final migration = value['pendingFromInstallationEvidence'];
    if (migration != null && migration is! bool) {
      throw const FormatException(
        'Invalid update notice installation evidence.',
      );
    }
    if (first != null && (first is! int || first < 1)) {
      throw const FormatException('Invalid update notice installation.');
    }
    return MobileUpdateNoticeRecord(
      lastInstalledBuild: build(value['lastInstalledBuild']),
      firstInstallMillis: first as int?,
      pendingInstalledBuild: build(value['pendingInstalledBuild']),
      pendingFromInstallationEvidence: migration == true,
      recommendedShown: builds(value['recommendedShown']),
      installedShown: builds(value['installedShown']),
    );
  }
}
