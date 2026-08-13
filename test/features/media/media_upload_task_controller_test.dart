import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  testWidgets('reads app-bound ports from a nested ProviderScope', (
    tester,
  ) async {
    final gateway = _FakeGateway()..completeOnStart = _image;
    await tester.pumpWidget(
      ProviderScope(
        child: ProviderScope(
          overrides: [
            editorImagePickerPortProvider.overrideWithValue(
              _FakePicker(_input),
            ),
            mediaUploadGatewayPortProvider.overrideWithValue(gateway),
          ],
          child: const _NestedScopeUploadProbe(),
        ),
      ),
    );

    await tester.tap(find.text('upload'));
    await tester.pump();
    await tester.pump();

    expect(find.text(_image.url), findsOneWidget);
    expect(gateway.starts, 1);
  });

  test(
    'cancelling image selection returns to idle without starting upload',
    () async {
      final gateway = _FakeGateway();
      final container = _container(
        picker: const _FakePicker(null),
        gateway: gateway,
      );
      addTearDown(container.dispose);
      final provider = mediaUploadTaskControllerProvider(Object());
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final result = await container.read(provider.notifier).pickAndUpload();

      expect(result, isNull);
      expect(container.read(provider).phase, MediaUploadTaskPhase.idle);
      expect(gateway.starts, 0);
    },
  );

  test('publishes progress and returns the completed image once', () async {
    final gateway = _FakeGateway();
    final container = _container(picker: _FakePicker(_input), gateway: gateway);
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final phases = <MediaUploadTaskPhase>[];
    final subscription = container.listen(
      provider,
      (_, next) => phases.add(next.phase),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final pending = container.read(provider.notifier).pickAndUpload();
    await Future<void>.value();
    gateway.progress(
      const MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: 2,
        totalBytes: 4,
      ),
    );
    expect(container.read(provider).progress?.fraction, .5);
    gateway.progress(
      const MediaUploadProgress(stage: MediaUploadStage.confirming),
    );
    gateway.progress(
      const MediaUploadProgress(stage: MediaUploadStage.processing),
    );
    gateway.complete(_image);

    expect(await pending, same(_image));
    expect(container.read(provider).phase, MediaUploadTaskPhase.idle);
    expect(
      phases,
      containsAllInOrder([
        MediaUploadTaskPhase.picking,
        MediaUploadTaskPhase.preparing,
        MediaUploadTaskPhase.uploading,
        MediaUploadTaskPhase.confirming,
        MediaUploadTaskPhase.processing,
        MediaUploadTaskPhase.idle,
      ]),
    );
  });

  test('ignores progress that arrives after a successful result', () async {
    final gateway = _FakeGateway();
    final container = _container(picker: _FakePicker(_input), gateway: gateway);
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    final pending = container.read(provider.notifier).pickAndUpload();
    await Future<void>.value();
    gateway.complete(_image);
    expect(await pending, same(_image));
    gateway.progress(
      const MediaUploadProgress(stage: MediaUploadStage.processing),
    );

    expect(container.read(provider).phase, MediaUploadTaskPhase.idle);
  });

  test('coalesces repeated taps while one upload is active', () async {
    final gateway = _FakeGateway();
    final container = _container(picker: _FakePicker(_input), gateway: gateway);
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final controller = container.read(provider.notifier);

    final first = controller.pickAndUpload();
    final second = controller.pickAndUpload();
    await Future<void>.value();

    expect(second, same(first));
    expect(gateway.starts, 1);
    gateway.complete(_image);
    expect(await first, same(_image));
  });

  test('preserves a safe failure and retries the selected bytes', () async {
    final gateway = _FakeGateway();
    final container = _container(picker: _FakePicker(_input), gateway: gateway);
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final controller = container.read(provider.notifier);

    final failed = controller.pickAndUpload();
    await Future<void>.value();
    gateway.fail(
      const ApiFailure(userMessage: '图片处理失败', requestId: 'request-one'),
    );
    expect(await failed, isNull);
    expect(container.read(provider).phase, MediaUploadTaskPhase.failed);
    expect(container.read(provider).failure?.userMessage, '图片处理失败');
    expect(container.read(provider).failure?.requestId, 'request-one');

    final retried = controller.retryUpload();
    await Future<void>.value();
    expect(gateway.starts, 2);
    expect(gateway.inputs, everyElement(same(_input)));
    gateway.complete(_image);
    expect(await retried, same(_image));
    expect(container.read(provider).phase, MediaUploadTaskPhase.idle);
  });

  test('ignores progress that arrives after a failed result', () async {
    final gateway = _FakeGateway();
    final container = _container(picker: _FakePicker(_input), gateway: gateway);
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    final pending = container.read(provider.notifier).pickAndUpload();
    await Future<void>.value();
    gateway.fail(const ApiFailure(userMessage: 'failed'));
    expect(await pending, isNull);
    gateway.progress(
      const MediaUploadProgress(stage: MediaUploadStage.processing),
    );

    expect(container.read(provider).phase, MediaUploadTaskPhase.failed);
    expect(container.read(provider).failure?.userMessage, 'failed');
  });

  test('fresh selection clears the previous retry input', () async {
    final picker = _SequencePicker([_input, null]);
    final gateway = _FakeGateway();
    final container = _container(picker: picker, gateway: gateway);
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final controller = container.read(provider.notifier);

    final failed = controller.pickAndUpload();
    await Future<void>.value();
    gateway.fail(const ApiFailure(userMessage: 'failed'));
    expect(await failed, isNull);
    expect(await controller.pickAndUpload(), isNull);
    expect(await controller.retryUpload(), isNull);

    expect(picker.calls, 2);
    expect(gateway.starts, 1);
    expect(container.read(provider).phase, MediaUploadTaskPhase.idle);
  });

  test('retry without a failed input does not open the picker', () async {
    final picker = _SequencePicker([_input]);
    final gateway = _FakeGateway();
    final container = _container(picker: picker, gateway: gateway);
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    expect(await container.read(provider.notifier).retryUpload(), isNull);
    expect(picker.calls, 0);
    expect(gateway.starts, 0);
  });

  test('cancel ignores progress and success that arrive late', () async {
    final gateway = _FakeGateway();
    final container = _container(picker: _FakePicker(_input), gateway: gateway);
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final controller = container.read(provider.notifier);

    final pending = controller.pickAndUpload();
    await Future<void>.value();
    controller.cancel();
    expect(gateway.lastOperation.cancelled, isTrue);
    expect(container.read(provider).phase, MediaUploadTaskPhase.idle);
    expect(await pending, isNull);

    gateway.progress(
      const MediaUploadProgress(stage: MediaUploadStage.processing),
    );
    gateway.complete(_image);
    await Future<void>.value();
    expect(container.read(provider).phase, MediaUploadTaskPhase.idle);
  });

  test('auto dispose cancels the active data operation', () async {
    final gateway = _FakeGateway();
    final container = _container(picker: _FakePicker(_input), gateway: gateway);
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    unawaited(container.read(provider.notifier).pickAndUpload());
    await Future<void>.value();

    subscription.close();
    await container.pump();

    expect(gateway.lastOperation.cancelled, isTrue);
  });
}

ProviderContainer _container({
  required EditorImagePicker picker,
  required MediaUploadGateway gateway,
}) {
  return ProviderContainer(
    overrides: [
      editorImagePickerPortProvider.overrideWithValue(picker),
      mediaUploadGatewayPortProvider.overrideWithValue(gateway),
    ],
  );
}

final _input = MediaUploadInput(
  filename: 'editor.png',
  declaredContentType: 'image/png',
  bytes: Uint8List.fromList(const [137, 80, 78, 71]),
);

const _image = UploadedEditorImage(
  mediaId: 'media-one',
  url: 'https://cdn.example.com/editor.png',
);

class _FakePicker implements EditorImagePicker {
  const _FakePicker(this.input);

  final MediaUploadInput? input;

  @override
  Future<MediaUploadInput?> pickFromGallery() async => input;
}

class _SequencePicker implements EditorImagePicker {
  _SequencePicker(this.inputs);

  final List<MediaUploadInput?> inputs;
  var calls = 0;

  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    final input = inputs[calls];
    calls += 1;
    return input;
  }
}

class _FakeGateway implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];
  final operations = <_FakeOperation>[];
  void Function(MediaUploadProgress progress)? _onProgress;
  UploadedEditorImage? completeOnStart;

  int get starts => operations.length;
  _FakeOperation get lastOperation => operations.last;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    _onProgress = onProgress;
    final operation = _FakeOperation();
    operations.add(operation);
    final immediate = completeOnStart;
    if (immediate != null) operation.complete(immediate);
    return operation;
  }

  void progress(MediaUploadProgress progress) => _onProgress?.call(progress);

  void complete(UploadedEditorImage image) => lastOperation.complete(image);

  void fail(Object error) => lastOperation.fail(error);
}

class _NestedScopeUploadProbe extends ConsumerStatefulWidget {
  const _NestedScopeUploadProbe();

  @override
  ConsumerState<_NestedScopeUploadProbe> createState() =>
      _NestedScopeUploadProbeState();
}

class _NestedScopeUploadProbeState
    extends ConsumerState<_NestedScopeUploadProbe> {
  final Object _taskId = Object();
  String? _result;

  @override
  Widget build(BuildContext context) {
    ref.watch(mediaUploadTaskControllerProvider(_taskId));
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          TextButton(
            onPressed: () async {
              final image = await ref
                  .read(mediaUploadTaskControllerProvider(_taskId).notifier)
                  .pickAndUpload();
              if (mounted) setState(() => _result = image?.url);
            },
            child: const Text('upload'),
          ),
          if (_result != null) Text(_result!),
        ],
      ),
    );
  }
}

class _FakeOperation implements MediaUploadOperation<UploadedEditorImage> {
  final _completer = Completer<UploadedEditorImage>();
  var cancelled = false;

  @override
  Future<UploadedEditorImage> get result => _completer.future;

  @override
  void cancel() => cancelled = true;

  void complete(UploadedEditorImage image) => _completer.complete(image);

  void fail(Object error) => _completer.completeError(error);
}
