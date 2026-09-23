import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_composer_sheet.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/media_ui.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_comment_composer.dart';

import '../../support/memory_pending_media_file_store.dart';

void main() {
  for (final sample in [
    (size: const Size(320, 760), scale: 2.0, keyboard: 280.0),
    (size: const Size(390, 844), scale: 1.0, keyboard: 340.0),
    (size: const Size(320, 760), scale: 2.0, keyboard: 460.0),
    (size: const Size(760, 390), scale: 1.0, keyboard: 150.0),
  ]) {
    testWidgets('真实评论弹层单图提示可见：$sample', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = sample.size;
      tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 34);
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 34);
      tester.platformDispatcher.textScaleFactorTestValue = sample.scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final fixture = _Fixture();
      await fixture.pump(tester, sheet: true);
      tester.view.viewInsets = FakeViewPadding(bottom: sample.keyboard);
      tester.view.padding = const FakeViewPadding(top: 24);
      await tester.pump();
      expect(find.text('更换图片'), findsNothing);
      expect(find.text('仅支持一张图片'), findsNothing);
      final focus = FocusManager.instance.primaryFocus;
      await tester.tap(find.byKey(_imageKey));
      await tester.tap(find.byKey(_imageKey));
      await tester.pump();
      expect(find.text('评论只能添加一张图片'), findsOneWidget);
      expect(fixture.picker.calls, 0);
      expect(fixture.gateway.operations, isEmpty);
      expect(fixture.draft.image?.mediaId, 'old');
      expect(fixture.draft.content, '保留文字');
      expect(FocusManager.instance.primaryFocus, same(focus));
      final hint = find.byKey(const Key('moment-comment-image-limit-hint'));
      void expectVisible(double keyboard) {
        final rect = tester.getRect(hint);
        expect(rect.left, greaterThanOrEqualTo(16));
        expect(rect.right, lessThanOrEqualTo(sample.size.width - 16));
        expect(rect.top, greaterThanOrEqualTo(24));
        expect(rect.bottom, lessThanOrEqualTo(sample.size.height - keyboard));
        expect(tester.takeException(), isNull);
      }

      expectVisible(sample.keyboard);
      // 键盘尺寸变化必须随真实 modal 重新定位，而非缓存初始坐标。
      tester.view.viewInsets = FakeViewPadding(bottom: sample.keyboard - 40);
      await tester.pump();
      expectVisible(sample.keyboard - 40);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('评论只能添加一张图片'), findsNothing);
      expect(fixture.closeCalls, 1);
      await tester.pump(wenyouBriefSnackBarDuration);
      expect(find.text('评论只能添加一张图片'), findsNothing);
    });
  }
  testWidgets('未开放表情能力时评论不显示表情入口', (tester) async {
    await _Fixture().pump(tester);
    expect(find.byKey(const Key('moment-comment-sticker')), findsNothing);
  });
  testWidgets('相册打开时重复调用选择回调只启动一次', (tester) async {
    final fixture = _Fixture()
      ..draft = const MomentCommentDraft(content: '保留文字');
    await fixture.pump(tester);
    final pick = tester.widget<IconButton>(find.byKey(_imageKey)).onPressed!;
    pick();
    pick();
    await tester.pump();
    expect(fixture.picker.calls, 1);
    fixture.picker.result.complete(null);
    await tester.pumpAndSettle();
  });

  testWidgets('发送同步锁阻止重复发送及移除，失败保留附件文字', (tester) async {
    final fixture = _Fixture()..sendResult = Completer<bool>();
    await fixture.pump(tester);
    final send = tester
        .widget<WenyouComposerSubmitButton>(find.byKey(_sendKey))
        .onPressed!;
    send();
    send();
    await tester.pump();
    expect(fixture.sendCalls, 1);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) => widget is IconButton && widget.tooltip == '移除附件',
            ),
          )
          .onPressed,
      isNull,
    );
    expect(tester.widget<IconButton>(find.byKey(_imageKey)).onPressed, isNull);
    fixture.sendResult!.complete(false);
    await tester.pumpAndSettle();
    expect(fixture.draft.image?.mediaId, 'old');
    expect(fixture.draft.content, '保留文字');
  });

  testWidgets('关闭后相册迟到错误不弹选择失败对话框', (tester) async {
    final fixture = _Fixture()
      ..draft = const MomentCommentDraft(content: '保留文字');
    await fixture.pump(tester);
    await fixture.pick(tester);
    await tester.binding.handlePopRoute();
    fixture.picker.result.completeError(StateError('picker failed late'));
    await tester.pumpAndSettle();
    expect(find.text('选择图片失败'), findsNothing);
    expect(fixture.gateway.operations, isEmpty);
  });
  testWidgets('已有图片重复点击仅短提示，移除后才打开一次相册', (tester) async {
    final fixture = _Fixture();
    await fixture.pump(tester, sheet: true);
    await fixture.pick(tester);
    await fixture.pick(tester);
    expect(fixture.picker.calls, 0);
    expect(fixture.gateway.operations, isEmpty);
    expect(find.text('评论只能添加一张图片'), findsOneWidget);
    await tester.pump(wenyouBriefSnackBarDuration);
    expect(find.text('评论只能添加一张图片'), findsNothing);
    await fixture.pick(tester);
    await tester.tap(find.byTooltip('移除附件'));
    await tester.pump();
    expect(find.text('评论只能添加一张图片'), findsNothing);
    await fixture.pick(tester);
    expect(fixture.picker.calls, 1);
    expect(tester.widget<IconButton>(find.byKey(_imageKey)).onPressed, isNull);
    expect(
      tester.widget<WenyouComposerSubmitButton>(find.byKey(_sendKey)).enabled,
      isFalse,
    );
    fixture.picker.result.complete(null);
    await tester.pumpAndSettle();
    expect(fixture.draft.image, isNull);
    expect(fixture.draft.content, '保留文字');
    expect(fixture.gateway.operations, isEmpty);
  });

  testWidgets('移除旧图后上传失败保留文字，重试绑定同一输入', (tester) async {
    final fixture = _Fixture();
    await fixture.pump(tester);
    await tester.tap(find.byTooltip('移除附件'));
    await tester.pump();
    await fixture.pick(tester);
    fixture.picker.result.complete(_input);
    await tester.pump();
    expect(fixture.draft.image, isNull);
    await tester.pump(const Duration(milliseconds: 100));
    fixture.gateway.operations.single.resultCompleter.completeError(
      const ApiFailure(userMessage: '测试上传失败'),
    );
    await tester.pumpAndSettle();
    expect(fixture.draft.image, isNull);
    expect(fixture.draft.content, '保留文字');
    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is PendingImageOverlay && widget.failed,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('重试'));
    await tester.pump();
    expect(fixture.picker.calls, 1);
    expect(fixture.gateway.inputs.map((i) => i.filename), [
      'new.png',
      'new.png',
    ]);
    fixture.gateway.operations.last.resultCompleter.complete(_newImage);
    await tester.pumpAndSettle();
    expect(fixture.draft.image?.mediaId, 'new');
    expect(fixture.draft.content, '保留文字');
  });

  testWidgets('移除后新上传可取消，迟到结果不恢复附件', (tester) async {
    final fixture = _Fixture();
    await fixture.pump(tester);
    await tester.tap(find.byTooltip('移除附件'));
    await tester.pump();
    await fixture.pick(tester);
    fixture.picker.result.complete(_input);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byTooltip('移除图片 1'));
    await tester.pump();
    expect(fixture.gateway.operations.single.cancelled, isTrue);
    fixture.gateway.operations.single.resultCompleter.complete(_newImage);
    await tester.pumpAndSettle();
    expect(fixture.draft.image, isNull);
    expect(find.byKey(const Key('moment-comment-retry-upload')), findsNothing);
  });

  testWidgets('选择器打开时关闭，迟到选择不上传且保留旧草稿', (tester) async {
    final fixture = _Fixture()
      ..draft = const MomentCommentDraft(content: '保留文字');
    await fixture.pump(tester);
    await fixture.pick(tester);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(fixture.closeCalls, 1);
    fixture.picker.result.complete(_input);
    await tester.pumpAndSettle();
    expect(fixture.gateway.operations, isEmpty);
    expect(fixture.draft.image, isNull);
    expect(fixture.draft.content, '保留文字');
  });
}

const _imageKey = Key('moment-comment-image');
const _sendKey = Key('moment-comment-send');
const _oldImage = UploadedEditorImage(
  mediaId: 'old',
  url: 'https://example.com/old.png',
);
const _newImage = UploadedEditorImage(
  mediaId: 'new',
  url: 'https://example.com/new.png',
);
final _input = MediaUploadInput(
  filename: 'new.png',
  bytes: Uint8List.fromList([1]),
);

class _Fixture {
  final picker = _Picker();
  final gateway = _Gateway();
  var closeCalls = 0;
  var sendCalls = 0;
  Completer<bool>? sendResult;
  var draft = const MomentCommentDraft(content: '保留文字', image: _oldImage);

  Future<void> pump(WidgetTester tester, {bool sheet = false}) async {
    Widget composer(BuildContext context) => MomentCommentComposer(
      replyTo: null,
      isSending: false,
      initialDraft: draft,
      onCancelReply: () {},
      onClose: () {
        closeCalls++;
        if (sheet) Navigator.of(context).pop();
      },
      onDraftChanged: (value) => draft = value,
      onSend: (_) async {
        sendCalls++;
        return sendResult == null ? false : await sendResult!.future;
      },
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'owner',
          ),
          memoryPendingMediaFileStoreOverride(),
          editorImagePickerPortProvider.overrideWithValue(picker),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => sheet
                  ? TextButton(
                      onPressed: () => showWenyouComposerSheet<void>(
                        context: context,
                        builder: (context) => Align(
                          alignment: Alignment.bottomCenter,
                          heightFactor: 1,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: SizedBox(
                              width: double.infinity,
                              child: composer(context),
                            ),
                          ),
                        ),
                      ),
                      child: const Text('打开评论'),
                    )
                  : composer(context),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (sheet) {
      await tester.tap(find.text('打开评论'));
      await tester.pumpAndSettle();
    }
  }

  Future<void> pick(WidgetTester tester) async {
    await tester.tap(find.byKey(_imageKey));
    await tester.pump();
  }
}

class _Picker implements EditorImagePicker {
  var calls = 0;
  final result = Completer<MediaUploadInput?>();
  @override
  Future<MediaUploadInput?> pickFromGallery() {
    calls++;
    return result.future;
  }
}

class _Gateway implements MediaUploadGateway {
  final operations = <_Operation>[];
  final inputs = <MediaUploadInput>[];
  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    final operation = _Operation();
    operations.add(operation);
    return operation;
  }
}

class _Operation implements MediaUploadOperation<UploadedEditorImage> {
  final resultCompleter = Completer<UploadedEditorImage>();
  var cancelled = false;
  @override
  Future<UploadedEditorImage> get result => resultCompleter.future;
  @override
  void cancel() => cancelled = true;
}
