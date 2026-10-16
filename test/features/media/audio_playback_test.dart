import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/audio_playback.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';

import '../../support/audio_driver.dart';

MediaAudio audio(String id) => MediaAudio.parse({
  'sourceUrl': 'https://storage.example/$id.mp3',
  'mediaId': id,
  'contentType': 'audio/mpeg',
  'size': 16000,
  'durationMs': 1000,
})!;

void main() {
  test('首次点击前不创建播放器；暂停后显式点击恢复且不重复请求', () async {
    final driver = Driver();
    var creates = 0;
    final controller = AudioPlaybackController(() {
      creates++;
      return driver;
    });
    final owner = Object();
    expect(creates, 0);
    await controller.toggle(owner, audio('one'));
    expect(creates, 1);
    expect(driver.loads, hasLength(1));
    expect(driver.plays, 1);
    await controller.toggle(owner, audio('one'));
    expect(controller.status.playing, isFalse);
    await controller.toggle(owner, audio('one'));
    expect(driver.loads, hasLength(1));
    expect(driver.plays, 2);
    controller.dispose();
  });
  test('快速切换时旧加载完成不得抢播', () async {
    final driver = Driver()..wait = true;
    final controller = AudioPlaybackController(() => driver);
    final old = controller.toggle(Object(), audio('one'));
    await Future<void>.delayed(Duration.zero);
    final owner = Object();
    final current = controller.toggle(owner, audio('two'));
    await Future<void>.delayed(Duration.zero);
    driver.waiting.first.complete();
    await old;
    expect(driver.plays, 0);
    expect(driver.stops, 1);
    driver.waiting.last.complete();
    await current;
    expect(driver.plays, 1);
    expect(controller.owns(owner), isTrue);
    controller.dispose();
  });
  test('加载期间离开或中断后，完成不自动播放', () async {
    final driver = Driver()..wait = true;
    final controller = AudioPlaybackController(() => driver);
    final owner = Object();
    final load = controller.toggle(owner, audio('one'));
    await Future<void>.delayed(Duration.zero);
    driver.interruption.add(null);
    driver.waiting.single.complete();
    await load;
    expect(driver.plays, 0);
    expect(driver.stops, 1);
    controller.release(owner);
    expect(controller.owns(owner), isFalse);
    controller.dispose();
  });
  test('播完后显式重播从零开始', () async {
    final driver = Driver();
    final controller = AudioPlaybackController(() => driver);
    final owner = Object();
    await controller.toggle(owner, audio('one'));
    driver.state.add(const AudioPlaybackStatus(completed: true));
    await controller.toggle(owner, audio('one'));
    expect(driver.seeks, 1);
    expect(driver.plays, 2);
    controller.dispose();
  });
  test('暂停后点继续保持进度；离页停止请求并不自动恢复', () async {
    final driver = Driver();
    final controller = AudioPlaybackController(() => driver);
    final owner = Object();
    await controller.toggle(owner, audio('one'));
    driver.state.add(
      const AudioPlaybackStatus(
        playing: true,
        position: Duration(milliseconds: 400),
      ),
    );
    await controller.pause(owner);
    driver.state.add(
      const AudioPlaybackStatus(position: Duration(milliseconds: 400)),
    );
    final snapshots = <Duration>[];
    controller.addListener(() => snapshots.add(controller.status.position));
    final resume = controller.toggle(owner, audio('one'));
    expect(snapshots.first, const Duration(milliseconds: 400));
    await resume;
    controller.release(owner);
    await Future<void>.delayed(Duration.zero);
    expect(driver.stops, 1);
    expect(driver.loads, hasLength(1));
    controller.dispose();
  });
}
