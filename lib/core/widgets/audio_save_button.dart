import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/application/audio_download.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_progress_indicator.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';

class AudioSaveButton extends ConsumerStatefulWidget {
  const AudioSaveButton({required this.audio, required this.label, super.key});
  final MediaAudio audio;
  final String label;
  @override
  ConsumerState<AudioSaveButton> createState() => _AudioSaveButtonState();
}

class _AudioSaveButtonState extends ConsumerState<AudioSaveButton> {
  AudioSaveOperation? _operation;
  @override
  void didUpdateWidget(covariant AudioSaveButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audio.sourceUrl != widget.audio.sourceUrl) {
      unawaited(_operation?.cancel());
      _operation = null;
    }
  }

  @override
  void dispose() {
    unawaited(_operation?.cancel());
    super.dispose();
  }

  Future<void> _save() async {
    if (_operation case final operation?) {
      await operation.cancel();
      return;
    }
    final operation = ref
        .read(audioDownloadProvider)
        .save(widget.audio, widget.label);
    setState(() => _operation = operation);
    String? message;
    try {
      if (await operation.result) message = '已保存到本地';
    } on AudioSaveException {
      message = '保存失败，请重试';
    }
    if (!mounted || !identical(_operation, operation)) return;
    setState(() => _operation = null);
    if (message != null) {
      showWenyouSnackBar(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(audioDownloadProvider).isSupported) {
      return const SizedBox.shrink();
    }
    return IconButton(
      tooltip: _operation == null ? '保存到本地' : '取消保存',
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      onPressed: _save,
      icon: _operation == null
          ? const WenyouIcon(WenyouIconIds.actionDownload, size: 20)
          : SizedBox(
              width: 18,
              height: 18,
              child: WenyouCircularProgressIndicator(strokeWidth: 2),
            ),
    );
  }
}
