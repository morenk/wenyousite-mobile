import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

const releaseTarget = (
  platform: MobileClientPlatform.android,
  build: 100,
  version: '0.9.0',
);

MobileRelease releaseFixture({
  MobileReleaseTarget target = releaseTarget,
  String summary = '阅读更顺手，更新前先看看这次的变化。',
  List<String> items = const [
    '优化主题帖阅读体验。',
    '修复长段落在大字号下的显示问题。',
    '**这是纯文本** <b>不会作为 HTML 显示</b>',
  ],
}) => MobileRelease(
  target: target,
  summary: summary,
  items: items,
  publishedAt: DateTime.utc(2026, 9, 27),
  revision: 1,
);

class TestReleaseRepository implements MobileReleaseRepository {
  MobileRelease? release = releaseFixture();
  int detailCalls = 0;
  final cursors = <String?>[];
  Object? detailError;
  Future<MobileReleasePage> Function(String? cursor)? onPage;

  @override
  Future<MobileRelease?> fetch(MobileReleaseTarget target) async {
    detailCalls++;
    if (detailError != null) throw detailError!;
    return release;
  }

  @override
  Future<MobileReleasePage> fetchPage({
    required MobileClientPlatform platform,
    String? cursor,
  }) async {
    cursors.add(cursor);
    return onPage?.call(cursor) ?? MobileReleasePage(items: [releaseFixture()]);
  }
}
