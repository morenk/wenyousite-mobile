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
    final repository = _ExportRepository();
    final saver = _DocumentSaver();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          threadManagementRepositoryProvider.overrideWithValue(repository),
          documentSaverProvider.overrideWithValue(saver),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showThreadExportSheet(
                  context: context,
                  threadId: 'thread-1',
                ),
                child: const Text('导出'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('导出'));
    await tester.pumpAndSettle();
    expect(find.text('生成 ZIP 后，由你选择保存位置。'), findsOneWidget);
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
