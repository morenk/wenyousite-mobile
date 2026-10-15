import 'dart:async';

import 'package:wenyousite_mobile/features/media/application/audio_playback.dart';

class Driver implements AudioPlaybackDriver {
  final state = StreamController<AudioPlaybackStatus>.broadcast(sync: true);
  final interruption = StreamController<void>.broadcast(sync: true);
  final loads = <String>[];
  final waiting = <Completer<void>>[];
  int plays = 0;
  int pauses = 0;
  int stops = 0;
  int seeks = 0;
  bool wait = false;
  @override
  Stream<AudioPlaybackStatus> get states => state.stream;
  @override
  Stream<void> get interruptions => interruption.stream;
  @override
  Future<void> load(String url) async {
    loads.add(url);
    if (wait) {
      final pending = Completer<void>();
      waiting.add(pending);
      await pending.future;
    }
  }

  @override
  Future<void> play() async {
    plays++;
    state.add(const AudioPlaybackStatus(playing: true));
  }

  @override
  Future<void> pause() async {
    pauses++;
    state.add(const AudioPlaybackStatus());
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> seek(Duration position) async {
    seeks++;
  }

  @override
  Future<void> dispose() async {
    await state.close();
    await interruption.close();
  }
}
