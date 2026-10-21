import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_catalog.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';
import 'dynamic_font_fixture.dart';

void main() {
  late Directory directory;
  late DynamicFontCatalog catalog;
  late DynamicFontFixture first, second;
  late Duration now;
  late int calls;
  late Future<TextFontResponse?> Function(String, String?) reply;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('wenyou-font-catalog-');
    first = DynamicFontFixture();
    second = DynamicFontFixture(identity: 2);
    now = Duration.zero;
    calls = 0;
    reply = (path, etag) async => TextFontResponse(404, Uint8List(0));
    catalog = DynamicFontCatalog(
      directory: directory,
      elapsed: () => now,
      changed: () {},
      read: (path, {etag}) {
        calls++;
        return reply(path, etag);
      },
    );
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });
  test('不足 limit 的页面仍跟随游标，完整快照后才发布', () async {
    final secondPage = Completer<TextFontResponse>();
    reply = (path, etag) async {
      if (path.contains('cursor=')) return secondPage.future;
      return TextFontResponse(
        200,
        first.envelope(first.page(cursor: 'next')),
        etag: '"first"',
      );
    };
    final loading = catalog.refresh();
    while (calls < 2) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    expect(catalog.entries, isEmpty);
    secondPage.complete(
      TextFontResponse(
        200,
        second.envelope(second.page(items: [second.entry])),
      ),
    );
    await loading;
    expect(catalog.entries.map((e) => e.versionId), [first.id, second.id]);
  });
  test('游标不断失效保留旧完整目录，不混入半份新发布', () async {
    reply = (_, _) async => TextFontResponse(200, first.envelope(first.page()));
    await catalog.refresh();
    reply = (path, etag) async => path.contains('cursor=')
        ? TextFontResponse(409, Uint8List(0))
        : TextFontResponse(
            200,
            second.envelope(second.page(revision: 2, cursor: 'next')),
          );
    await catalog.refresh(force: true);
    expect(catalog.revision, 1);
    expect(catalog.entries.single.versionId, first.id);
    expect(calls, 5);
  });
  test('完整目录 ETag 命中304保留快照', () async {
    reply = (_, _) async =>
        TextFontResponse(200, first.envelope(first.page()), etag: '"first"');
    await catalog.refresh();
    reply = (path, etag) async {
      expect(etag, '"first"');
      return TextFontResponse(304, Uint8List(0));
    };
    await catalog.refresh(force: true);
    expect(catalog.entries.single.versionId, first.id);
  });
  test('未知点查合并且404仅负缓存30秒，完成回调不能自等待', () async {
    final response = Completer<TextFontResponse>();
    reply = (_, _) => response.future;
    final a = catalog.ensureVersion(first.id),
        b = catalog.ensureVersion(first.id);
    expect(calls, 1);
    response.complete(TextFontResponse(404, Uint8List(0)));
    await Future.wait([a, b]).timeout(const Duration(seconds: 2));
    await catalog.ensureVersion(first.id);
    expect(calls, 1);
    now = const Duration(seconds: 30);
    reply = (_, _) async =>
        TextFontResponse(200, first.envelope(first.descriptor()));
    await catalog.ensureVersion(first.id);
    expect(calls, 2);
    expect(catalog.canRender(first.id), isTrue);
  });
  test('新版发布移出旧版本目录，但历史描述符允许复制；停用阻止新增', () async {
    reply = (_, _) async =>
        TextFontResponse(200, second.envelope(second.page(revision: 2)));
    await catalog.refresh();
    catalog.acceptVersion(first.dto(revision: 2, current: false));
    expect(catalog.canSelect(first.id), isFalse);
    expect(catalog.canPaste(first.id), isTrue);
    expect(catalog.canRender(first.id), isTrue);
    catalog.acceptVersion(
      first.dto(revision: 3, current: false, enabled: false),
    );
    expect(catalog.canPaste(first.id), isFalse);
    expect(catalog.canRender(first.id), isTrue);
    catalog.acceptVersion(first.dto(revision: 2));
    expect(catalog.canPaste(first.id), isFalse);
  });
  test('撤回墓碑跨缓存恢复优先于旧描述符', () async {
    catalog.acceptVersion(first.dto());
    catalog.acceptVersion(first.dto(revision: 2, withdrawn: true));
    await catalog.persist();
    final restored = DynamicFontCatalog(
      read: (_, {etag}) async => null,
      elapsed: () => now,
      directory: directory,
      changed: () {},
    );
    await restored.restore();
    restored.acceptVersion(first.dto(revision: 99));
    expect(restored.canRender(first.id), isFalse);
    expect(restored.canPaste(first.id), isFalse);
  });
  test('新 ID 墓碑跨256描述符淘汰、目录轮换及离线恢复仍优先', () async {
    catalog.acceptVersion(first.dto());
    catalog.markWithdrawn(first.id);
    catalog.acceptVersion(second.dto());
    for (var i = 3; i < DynamicFontCatalog.maximumDescriptors + 5; i++) {
      catalog.acceptVersion(DynamicFontFixture(identity: i).dto());
    }
    expect(catalog.descriptor(second.id), isNull, reason: '详细描述符确实已淘汰');
    for (var revision = 1; revision <= 3; revision++) {
      reply = (_, _) async => TextFontResponse(
        200,
        second.envelope(second.page(revision: revision)),
      );
      await catalog.refresh(force: true);
    }
    // 目录即使再次宣称该 ID 可选，也不能覆盖独立撤回记忆。
    reply = (_, _) async =>
        TextFontResponse(200, first.envelope(first.page(revision: 99)));
    await catalog.refresh(force: true);
    catalog.acceptVersion(first.dto(revision: 999));
    expect(catalog.entries.where((e) => e.versionId == first.id), isEmpty);
    expect(catalog.canSelect(first.id), isFalse);
    expect(catalog.canPaste(first.id), isFalse);
    expect(catalog.canRender(first.id), isFalse);
    final before = calls;
    await catalog.ensureVersion(first.id, force: true);
    expect(calls, before, reason: '撤回后不再发点查以复活旧状态');
    await catalog.persist();
    final restored = DynamicFontCatalog(
      read: (_, {etag}) async => null,
      elapsed: () => now,
      directory: directory,
      changed: () {},
    );
    await restored.restore();
    restored.acceptVersion(first.dto(revision: 1000));
    expect(restored.canSelect(first.id), isFalse);
    expect(restored.canPaste(first.id), isFalse);
    expect(restored.canRender(first.id), isFalse);
  });
  test('墓碑饱和不淘汰，持久化拒绝状态阻止新增和旧字体复活', () async {
    for (var i = 1; i <= DynamicFontCatalog.maximumTombstones + 1; i++) {
      catalog.markWithdrawn('tfv_${i.toRadixString(16).padLeft(32, '0')}');
    }
    final unseen = DynamicFontFixture(identity: 99999);
    catalog.acceptVersion(unseen.dto());
    expect(catalog.canRender(unseen.id), isFalse);
    await catalog.persist();
    final persisted =
        jsonDecode(
              await File(
                '${directory.path}/dynamic-catalog.json',
              ).readAsString(),
            )
            as Map;
    expect(
      persisted['withdrawn'],
      hasLength(DynamicFontCatalog.maximumTombstones),
    );
    expect(persisted['denyAll'], isTrue);
    final restored = DynamicFontCatalog(
      read: (_, {etag}) async => null,
      elapsed: () => now,
      directory: directory,
      changed: () {},
    );
    await restored.restore();
    restored.acceptVersion(unseen.dto(revision: 999));
    expect(restored.canRender(unseen.id), isFalse);
    expect(restored.canPaste(unseen.id), isFalse);
    expect(restored.canSelect(unseen.id), isFalse);
  });
  test('未知语言或状态不授予权限且保留最近可信描述符', () async {
    catalog.acceptVersion(first.dto());
    for (final invalid in [
      {...first.descriptor(revision: 2), 'status': 'future'},
      {...first.descriptor(revision: 2), 'designLanguage': 'future'},
    ]) {
      reply = (_, _) async => TextFontResponse(200, first.envelope(invalid));
      await expectLater(
        catalog.ensureVersion(first.id, force: true),
        throwsFormatException,
      );
      expect(catalog.descriptor(first.id)!.revision, 1);
    }
  });
  test('相同版本不能通过更高修订替换资源', () async {
    catalog.acceptVersion(first.dto());
    final altered = {
      ...first.descriptor(revision: 2),
      'manifest': second.manifestAsset,
    };
    reply = (_, _) async => TextFontResponse(200, first.envelope(altered));
    await expectLater(
      catalog.ensureVersion(first.id, force: true),
      throwsFormatException,
    );
    expect(
      catalog.descriptor(first.id)!.manifest!.sha256,
      first.manifestAsset['sha256'],
    );
  });
}
