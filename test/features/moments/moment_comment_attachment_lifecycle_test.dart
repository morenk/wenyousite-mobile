import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_comment_composer.dart';

void main() {
  testWidgets('320dp双倍字下更换图片及单图说明可见且无布局溢出', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 760);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _Fixture().pump(tester);
    expect(find.text('更换图片'), findsOneWidget);
    expect(find.text('仅支持一张图片'), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const Key('moment-comment-replace-image')))
          .height,
      greaterThanOrEqualTo(48),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('未开放表情能力时评论不显示表情入口', (tester) async {
    await _Fixture().pump(tester);
    expect(find.byKey(const Key('moment-comment-sticker')), findsNothing);
  });
  testWidgets('相册打开时重复调用选择回调只启动一次', (tester) async {
    final fixture = _Fixture();
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
    final fixture = _Fixture();
    await fixture.pump(tester);
    await fixture.pick(tester);
    await tester.binding.handlePopRoute();
    fixture.picker.result.completeError(StateError('picker failed late'));
    await tester.pumpAndSettle();
    expect(find.text('选择图片失败'), findsNothing);
    expect(fixture.gateway.operations, isEmpty);
  });
  testWidgets('已有图片明确更换且相册打开起锁定入口和发送', (tester) async {
    final fixture = _Fixture();
    await fixture.pump(tester);
    expect(find.byTooltip('更换图片（仅支持一张）'), findsOneWidget);
    expect(find.text('更换图片'), findsOneWidget);
    expect(find.text('仅支持一张图片'), findsOneWidget);
    await fixture.pick(tester);
    expect(fixture.picker.calls, 1);
    final image = tester.widget<IconButton>(find.byKey(_imageKey));
    expect(image.onPressed, isNull);
    expect(
      tester.widget<WenyouComposerSubmitButton>(find.byKey(_sendKey)).enabled,
      isFalse,
    );
    fixture.picker.result.complete(null);
    await tester.pumpAndSettle();
    expect(fixture.draft.image?.mediaId, 'old');
    expect(fixture.gateway.operations, isEmpty);
  });

  testWidgets('更换上传成功才替换，失败保留原图文字，重试绑定同一输入', (tester) async {
    final fixture = _Fixture();
    await fixture.pump(tester);
    await fixture.pick(tester);
    fixture.picker.result.complete(_input);
    await tester.pump();
    expect(fixture.draft.image?.mediaId, 'old');
    fixture.gateway.operations.single.resultCompleter.completeError(
      const ApiFailure(userMessage: '测试上传失败'),
    );
    await tester.pumpAndSettle();
    expect(fixture.draft.image?.mediaId, 'old');
    expect(fixture.draft.content, '保留文字');
    await tester.tap(find.byKey(const Key('moment-comment-retry-upload')));
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

  testWidgets('打开相册后移除附件，迟到选择不能启动上传或恢复附件', (tester) async {
    final fixture = _Fixture();
    await fixture.pump(tester);
    await fixture.pick(tester);
    await tester.tap(find.byTooltip('移除附件'));
    await tester.pump();
    fixture.picker.result.complete(_input);
    await tester.pumpAndSettle();
    expect(fixture.gateway.operations, isEmpty);
    expect(fixture.draft.image, isNull);
  });

  testWidgets('替换上传中移除，取消任务且迟到结果不恢复附件', (tester) async {
    final fixture = _Fixture();
    await fixture.pump(tester);
    await fixture.pick(tester);
    fixture.picker.result.complete(_input);
    await tester.pump();
    await tester.tap(find.byTooltip('移除附件'));
    await tester.pump();
    expect(fixture.gateway.operations.single.cancelled, isTrue);
    fixture.gateway.operations.single.resultCompleter.complete(_newImage);
    await tester.pumpAndSettle();
    expect(fixture.draft.image, isNull);
    expect(find.byKey(const Key('moment-comment-retry-upload')), findsNothing);
  });

  testWidgets('选择器打开时关闭，迟到选择不上传且保留旧草稿', (tester) async {
    final fixture = _Fixture();
    await fixture.pump(tester);
    await fixture.pick(tester);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(fixture.closeCalls, 1);
    fixture.picker.result.complete(_input);
    await tester.pumpAndSettle();
    expect(fixture.gateway.operations, isEmpty);
    expect(fixture.draft.image?.mediaId, 'old');
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

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          editorImagePickerPortProvider.overrideWithValue(picker),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MomentCommentComposer(
              replyTo: null,
              isSending: false,
              initialDraft: draft,
              onCancelReply: () {},
              onClose: () => closeCalls++,
              onDraftChanged: (value) => draft = value,
              onSend: (_) async {
                sendCalls++;
                return sendResult == null ? false : await sendResult!.future;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
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
