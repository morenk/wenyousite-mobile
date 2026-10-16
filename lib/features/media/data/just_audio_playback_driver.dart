import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wenyousite_mobile/core/application/audio_playback.dart';

class JustAudioPlaybackDriver implements AudioPlaybackDriver {
  JustAudioPlaybackDriver() {
    _subscriptions.add(_player.playerStateStream.listen((_) => _emit()));
    _subscriptions.add(_player.positionStream.listen((_) => _emit()));
    _subscriptions.add(_player.durationStream.listen((_) => _emit()));
  }

  final _player = AudioPlayer(handleInterruptions: false);
  final _states = StreamController<AudioPlaybackStatus>.broadcast();
  final _interruptions = StreamController<void>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  Future<void>? _session;
  bool _disposed = false;
  int _loadGeneration = 0;

  @override
  Stream<AudioPlaybackStatus> get states => _states.stream;
  @override
  Stream<void> get interruptions => _interruptions.stream;

  void _emit() {
    if (_disposed) return;
    final processing = _player.processingState;
    _states.add(
      AudioPlaybackStatus(
        playing: _player.playing && processing != ProcessingState.completed,
        loading:
            processing == ProcessingState.loading ||
            processing == ProcessingState.buffering,
        completed: processing == ProcessingState.completed,
        position: _player.position,
        duration: _player.duration,
      ),
    );
  }

  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    if (_disposed) return;
    await session.configure(const AudioSessionConfiguration.music());
    if (_disposed) return;
    _subscriptions.add(
      session.interruptionEventStream.listen((event) {
        if (event.begin) _interruptions.add(null);
      }),
    );
    _subscriptions.add(
      session.becomingNoisyEventStream.listen((_) {
        _interruptions.add(null);
      }),
    );
  }

  @override
  Future<void> load(String url) async {
    final generation = ++_loadGeneration;
    await (_session ??= _configureSession());
    if (!_disposed && generation == _loadGeneration) await _player.setUrl(url);
  }

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() {
    _loadGeneration++;
    return _player.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() async {
    _disposed = true;
    _loadGeneration++;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _player.dispose();
    await _states.close();
    await _interruptions.close();
  }
}

final deviceAudioPlaybackProvider = Provider<AudioPlaybackController>((ref) {
  final controller = AudioPlaybackController(JustAudioPlaybackDriver.new);
  ref.onDispose(controller.dispose);
  return controller;
});
