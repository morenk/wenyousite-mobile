import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';

class AudioPlaybackStatus {
  const AudioPlaybackStatus({
    this.playing = false,
    this.loading = false,
    this.completed = false,
    this.position = Duration.zero,
    this.duration,
  });
  final bool playing;
  final bool loading;
  final bool completed;
  final Duration position;
  final Duration? duration;
}

abstract interface class AudioPlaybackDriver {
  Stream<AudioPlaybackStatus> get states;
  Stream<void> get interruptions;
  Future<void> load(String url);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> dispose();
}

/// 全应用一个播放器；直到用户点击才创建原生播放器和请求音频。
class AudioPlaybackController extends ChangeNotifier {
  AudioPlaybackController(this._createDriver);
  final AudioPlaybackDriver Function() _createDriver;
  AudioPlaybackDriver? _driver;
  StreamSubscription<AudioPlaybackStatus>? _states;
  StreamSubscription<void>? _interruptions;
  Object? _owner;
  String? _url;
  bool _loaded = false;
  bool _requesting = false;
  bool _disposed = false;
  int _generation = 0;
  String? error;
  AudioPlaybackStatus status = const AudioPlaybackStatus();

  bool owns(Object owner) => identical(_owner, owner);

  Future<void> toggle(Object owner, MediaAudio audio) async {
    if (_disposed) return;
    if (owns(owner) && (status.playing || _requesting)) {
      await pause(owner);
      return;
    }
    final generation = ++_generation;
    final replay = _url == audio.sourceUrl && status.completed;
    final previousPosition = _url == audio.sourceUrl && !replay
        ? status.position
        : Duration.zero;
    _requesting = true;
    _owner = owner;
    error = null;
    status = AudioPlaybackStatus(
      loading: true,
      position: previousPosition,
      duration: Duration(milliseconds: audio.durationMs),
    );
    notifyListeners();
    try {
      final driver = _driver ??= _initializeDriver();
      if (_url != null && _url != audio.sourceUrl) {
        await driver.stop();
      } else {
        await driver.pause();
      }
      if (!_current(generation)) return;
      if (_url != audio.sourceUrl || !_loaded) {
        _url = audio.sourceUrl;
        _loaded = false;
        await driver.load(audio.sourceUrl);
        if (!_current(generation)) return;
        _loaded = true;
      } else if (replay) {
        await driver.seek(Duration.zero);
      }
      if (!_current(generation)) return;
      _requesting = false;
      // just_audio.play 在停止/播完才完成，不将它串入页面操作的等待链。
      unawaited(
        driver.play().catchError((Object _) {
          if (_current(generation)) _fail();
        }),
      );
    } on Object {
      if (_current(generation)) _fail();
    }
  }

  AudioPlaybackDriver _initializeDriver() {
    final driver = _createDriver();
    _states = driver.states.listen(
      (value) {
        if (_disposed || _owner == null || _requesting) return;
        status = value;
        notifyListeners();
      },
      onError: (Object _) {
        if (!_disposed) _fail();
      },
    );
    _interruptions = driver.interruptions.listen(
      (_) => unawaited(deactivate()),
    );
    return driver;
  }

  bool _current(int generation) => !_disposed && _generation == generation;

  void _fail() {
    _requesting = false;
    error = '音频播放失败，点击重试。';
    _loaded = false;
    status = AudioPlaybackStatus(
      position: status.position,
      duration: status.duration,
    );
    notifyListeners();
  }

  Future<void> pause([Object? owner]) async {
    if (_disposed || (owner != null && !owns(owner))) return;
    if (_requesting) {
      await deactivate(owner);
      return;
    }
    ++_generation;
    _requesting = false;
    status = AudioPlaybackStatus(
      position: status.position,
      duration: status.duration,
      completed: status.completed,
    );
    notifyListeners();
    try {
      await _driver?.pause();
    } on Object {
      /* 暂停仍保留显式重试入口。 */
    }
  }

  /// 离页、后台及系统中断会释放缓冲/中止在途加载；恢复前台不自动请求。
  Future<void> deactivate([Object? owner]) async {
    if (_disposed || (owner != null && !owns(owner))) return;
    ++_generation;
    _requesting = false;
    _loaded = false;
    status = AudioPlaybackStatus(
      position: status.position,
      duration: status.duration,
    );
    notifyListeners();
    try {
      await _driver?.stop();
    } on Object {
      /* 保持停止意图，不自动重试。 */
    }
  }

  Future<void> seek(Object owner, Duration position) async {
    if (_disposed || !owns(owner) || !_loaded) return;
    try {
      await _driver?.seek(position);
    } on Object {
      _fail();
    }
  }

  void release(Object owner) {
    if (!owns(owner)) return;
    unawaited(deactivate(owner));
    _owner = null;
  }

  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    unawaited(_states?.cancel());
    unawaited(_interruptions?.cancel());
    unawaited(_driver?.dispose());
    super.dispose();
  }
}
