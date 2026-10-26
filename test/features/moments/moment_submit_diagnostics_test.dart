import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/diagnostics/network_diagnostics.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_composer_controller.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';

import '../../support/moment_test_draft_store.dart';
import 'moment_pages_test_support.dart';

void main() {
  testWidgets('本地发布失败在原页面显示同编号并复制一条脱敏记录', (tester) async {
    final previous = FailureDiagnostics.instance;
    final diagnostics = FailureDiagnostics();
    FailureDiagnostics.instance = diagnostics;
    addTearDown(() {
      FailureDiagnostics.instance = previous;
      diagnostics.dispose();
    });
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            MomentPagesTestPageRepository(),
          ),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'user-1',
          ),
          momentDraftStoreProvider.overrideWithValue(_FailBeginStore()),
          failureDiagnosticsProvider.overrideWithValue(diagnostics),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MomentComposePage)),
    );
    await container
        .read(momentComposerControllerProvider(null).notifier)
        .submit(
          const MomentDraftInput(
            title: 'private-title',
            content: 'private-content',
            mediaIds: [],
          ),
        );
    await tester.pumpAndSettle();
    final id = diagnostics.records.single.id;
    expect(find.text('问题编号：$id'), findsOneWidget);
    await tester.ensureVisible(find.text('复制问题详情'));
    await tester.tap(find.text('复制问题详情'));
    await tester.pumpAndSettle();
    final records = (jsonDecode(copied!) as Map)['records'] as List;
    expect(records, hasLength(1));
    expect((records.single as Map)['id'], id);
    expect(copied, isNot(contains('private-title')));
    expect(copied, isNot(contains('private-content')));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  for (final status in [201, 503]) {
    test('真实 Dio 与生成器链路记录响应及解析阶段，明确重试保持幂等 $status', () async {
      final diagnostics = FailureDiagnostics();
      final adapter = _ResponseAdapter(status);
      final dio = Dio(BaseOptions(baseUrl: 'https://offline.invalid'))
        ..httpClientAdapter = adapter
        ..interceptors.add(
          NetworkDiagnosticInterceptor(diagnostics: diagnostics),
        );
      final controller = MomentComposerController(
        ApiMomentRepository(WenyouApi(dio: dio).getMomentsApi()),
        draftStore: MemoryMomentDraftStore(),
        resolveOwner: () async => 'private-owner',
        diagnostics: diagnostics,
        autoStart: false,
      );
      addTearDown(() async {
        controller.dispose();
        await diagnostics.settled;
        diagnostics.dispose();
        dio.close(force: true);
      });
      await controller.load();
      const input = MomentDraftInput(
        title: 'private-title',
        content: 'private-content',
        mediaIds: [],
      );
      expect(await controller.submit(input), isNull);
      final record = diagnostics.records.single;
      expect(record.operation, DiagnosticOperation.momentCreate);
      expect(
        record.stage,
        status == 201 ? DiagnosticStage.decode : DiagnosticStage.response,
      );
      expect(record.fields['responseReceived'], true);
      expect(record.fields['apiEnvelopeReceived'], true);
      expect(record.fields['httpStatus'], status);
      expect(record.fields['apiOperation'], 'momentsCreate');
      expect(record.fields['requestId'], isNotNull);
      expect(record.fields['stackOrigin'], 'caught');
      expect(diagnostics.idFor(controller.state.failure), record.id);
      expect(controller.state.awaitingConfirmation, true);
      expect(adapter.requestIds, hasLength(1));
      final exported = diagnostics.export();
      for (final secret in [
        'private-owner',
        'private-title',
        'private-content',
        'private-response',
        'offline.invalid',
        'secret-signature',
      ]) {
        expect(exported, isNot(contains(secret)));
      }
      // 只有用户再次明确提交才发送，失败重试使用同一载荷 ID。
      await controller.submit(input);
      expect(adapter.requestIds, hasLength(2));
      expect(adapter.requestIds.toSet(), hasLength(1));
      expect(diagnostics.records, hasLength(2));
      expect(
        diagnostics.records.map((r) => r.fields['attemptId']).toSet(),
        hasLength(2),
      );
    });
  }
}

class _FailBeginStore extends MemoryMomentDraftStore {
  @override
  Future<void> beginCreate(
    String ownerId,
    MomentLocalDraft value,
    PendingCreateOperation operation,
  ) async {
    throw StateError('private-path');
  }
}

class _ResponseAdapter implements HttpClientAdapter {
  _ResponseAdapter(this.status);
  final int status;
  final requestIds = <Object?>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestIds.add((options.data as Map)['clientRequestId']);
    return ResponseBody.fromString(
      jsonEncode({
        'code': status == 201 ? 0 : 50000,
        'message': 'private-response',
        'data': {'url': 'https://private.invalid?signature=secret-signature'},
      }),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
