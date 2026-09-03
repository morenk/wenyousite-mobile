import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/document_saver.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_management_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_export_sheet.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('完整导出设置生成 ZIP 并交给系统保存器', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _ExportRepository();
    final saver = _DocumentSaver();
    await _pumpSheet(tester, repository, saver);

    await tester.tap(find.text('导出'));
    await tester.pumpAndSettle();
    expect(find.text('生成 ZIP 后，由你选择保存位置。'), findsNothing);
    expect(find.text('包含内容'), findsOneWidget);
    expect(find.text('无法取得的图片会列在档案说明中。'), findsOneWidget);
    await expectLater(
      find.byType(BottomSheet),
      matchesGoldenFile('goldens/thread_export_sheet_360.png'),
    );
    await tester.tap(
      find.byKey(const ValueKey('thread-export-format-markdown')),
    );
    await tester.tap(find.byKey(const ValueKey('thread-export-source-links')));
    await tester.ensureVisible(
      find.byKey(const ValueKey('thread-export-media')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('thread-export-media')));
    await tester.tap(find.byKey(const Key('thread-export-submit')));
    await tester.pumpAndSettle();

    expect(repository.options?.format, ThreadArchiveFormat.markdown);
    expect(repository.options?.includeAuthors, isTrue);
    expect(repository.options?.includeTimestamps, isTrue);
    expect(repository.options?.includeFloorNumbers, isTrue);
    expect(repository.options?.includeReplyTargets, isTrue);
    expect(repository.options?.includeSourceLinks, isTrue);
    expect(repository.options?.includeMedia, isFalse);
    expect(saver.fileName, '星海.zip');
    expect(saver.mimeType, 'application/zip');
    expect(find.text('导出主题档案'), findsNothing);
  });

  testWidgets('两倍字号下导出设置可滚动且无布局溢出', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await _pumpSheet(
      tester,
      _ExportRepository(),
      _DocumentSaver(),
      textScaler: const TextScaler.linear(2),
    );

    await tester.tap(find.text('导出'));
    await tester.pumpAndSettle();
    final submit = find.byKey(const Key('thread-export-submit'));
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(submit, findsOneWidget);
  });
}

Future<void> _pumpSheet(
  WidgetTester tester,
  ThreadManagementRepository repository,
  DocumentSaver saver, {
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        threadManagementRepositoryProvider.overrideWithValue(repository),
        documentSaverProvider.overrideWithValue(saver),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () =>
                  showThreadExportSheet(context: context, threadId: 'thread-1'),
              child: const Text('导出'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _ExportRepository implements ThreadManagementRepository {
  ThreadArchiveOptions? options;

  @override
  Future<ThreadArchive> exportArchive(
    String threadId,
    ThreadArchiveOptions options,
  ) async {
    this.options = options;
    return (
      bytes: Uint8List.fromList([0x50, 0x4b, 0x03, 0x04, 1]),
      fileName: '星海.zip',
    );
  }

  @override
  Future<ThreadManagementBootstrap> load(String threadId) =>
      throw UnsupportedError('unused');

  @override
  Future<void> remove(String threadId) => throw UnsupportedError('unused');

  @override
  Future<ThreadManagementSnapshot> update({
    required ThreadManagementSnapshot current,
    required ThreadManagementDraft draft,
  }) => throw UnsupportedError('unused');
}

class _DocumentSaver implements DocumentSaver {
  String? fileName;
  String? mimeType;

  @override
  bool get isSupported => true;

  @override
  Future<bool> save({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    this.fileName = fileName;
    this.mimeType = mimeType;
    return true;
  }
}
