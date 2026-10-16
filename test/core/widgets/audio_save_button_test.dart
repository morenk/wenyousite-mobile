import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/audio_download.dart';
import 'package:wenyousite_mobile/core/application/audio_playback.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_audio_player.dart';

import '../../support/audio_download.dart';
import '../../support/audio_driver.dart';

void main() {
  testWidgets('保存独立于播放，进行中可取消、失败可重试，卸载取消', (tester) async {
    final download = FakeAudioDownload();
    final driver = Driver();
    final playback = AudioPlaybackController(() => driver);
    addTearDown(playback.dispose);
    final audio = MediaAudio.parse({
      'sourceUrl': 'https://storage.example/a.mp3',
      'mediaId': 'a',
      'contentType': 'audio/mpeg',
      'size': 6,
      'durationMs': 1000,
    })!;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioDownloadProvider.overrideWithValue(download),
          audioPlaybackProvider.overrideWithValue(playback),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WenyouAudioPlayer(audio: audio, label: '原声.wav'),
          ),
        ),
      ),
    );
    expect(download.operations, isEmpty);
    final button = find.byTooltip('保存到本地');
    expect(tester.getSize(button), const Size(48, 48));
    await tester.tap(button);
    await tester.pump();
    expect(download.labels, ['原声.wav']);
    expect(driver.loads, isEmpty);
    await tester.tap(find.byTooltip('取消保存'));
    await tester.pump();
    expect(download.operations.single.cancelled, isTrue);
    expect(find.text('保存失败，请重试'), findsNothing);
    await tester.tap(button);
    await tester.pump();
    download.operations.last.completion.completeError(
      const AudioSaveException(),
    );
    await tester.pump();
    expect(find.text('保存失败，请重试'), findsOneWidget);
    await tester.tap(button);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(download.operations.last.cancelled, isTrue);
    expect(driver.loads, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
