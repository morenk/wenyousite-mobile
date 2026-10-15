import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

/// 同一登录会话的后台读取与自动续期共享失败预算，不排队重发业务操作。
class NetworkRecovery {
  NetworkRecovery({Duration Function()? elapsed, Random? random})
    : _elapsed = elapsed ?? _monotonicClock(),
      _random = random ?? Random.secure();

  final Duration Function() _elapsed;
  final Random _random;
  static const _delays = [30, 60, 120, 240, 300];
  int _revision = 0;
  int _failures = 0;
  Duration? _notBefore;

  int get ticket => _revision;

  Duration get remaining {
    final deadline = _notBefore;
    if (deadline == null) return Duration.zero;
    final value = deadline - _elapsed();
    return value.isNegative ? Duration.zero : value;
  }

  bool get isCoolingDown => remaining > Duration.zero;

  /// 冷却中的调用尚未发送请求，不沿用旧请求编号或底层异常。
  ApiFailure get deferredFailure => ApiFailure(
    source: FailureSource.expected,
    reason: FailureReason.cancelled,
    recoveryAction: FailureRecoveryAction.none,
    diagnosticCode: 'network.recoveryCooldown',
    retryAfter: remaining,
  );

  void failed(int ticket, Object error) {
    if (ticket != _revision || !_isTransient(error)) return;
    _revision++;
    final seconds = _delays[min(_failures, _delays.length - 1)];
    _failures = min(_failures + 1, _delays.length);
    // 有限抖动避免恢复时整批设备同时发送；含抖动的上限为五分钟。
    final milliseconds = min(
      300000,
      seconds * 1000 + _random.nextInt(seconds * 100 + 1),
    );
    _notBefore = _elapsed() + Duration(milliseconds: milliseconds);
  }

  void succeeded(int ticket) {
    // 较早的成功不能解除之后另一请求建立的失败冷却。
    if (ticket != _revision) return;
    _clear();
  }

  void resetSession() {
    _revision++;
    _clear();
  }

  void _clear() {
    _failures = 0;
    _notBefore = null;
  }

  static Duration Function() _monotonicClock() {
    final watch = Stopwatch()..start();
    return () => watch.elapsed;
  }
}

/// 仅标记定时与后台工作；普通前台请求不受后台冷却限制。
T runAutomaticNetworkRequests<T>(T Function() action) =>
    runZoned(action, zoneValues: {_automaticKey: true});

bool get isAutomaticNetworkRequest => Zone.current[_automaticKey] == true;

final _automaticKey = Object();

bool _isTransient(Object? error) {
  if (error is DioException) return _isTransient(ApiFailure.fromDio(error));
  if (error is AsyncError) return _isTransient(error.error);
  if (error is ApiFailure) {
    return !error.isCancellation &&
        (error.effectiveSource == FailureSource.network ||
            (error.httpStatus ?? 0) >= 500 ||
            error.businessCode == 50000 ||
            _isUnansweredHttpTransport(error));
  }
  // Dart 的并行读取保留各分支异常；只对已证实的传输/服务瞬时失败退避。
  if (error is ParallelWaitError) {
    final errors = error.errors;
    final values = switch (errors) {
      (final Object? a, final Object? b) => [a, b],
      (final Object? a, final Object? b, final Object? c) => [a, b, c],
      (final Object? a, final Object? b, final Object? c, final Object? d) => [
        a,
        b,
        c,
        d,
      ],
      Iterable<Object?> values => values,
      _ => const <Object?>[],
    };
    return values.any(_isTransient);
  }
  return false;
}

bool _isUnansweredHttpTransport(ApiFailure failure) {
  final cause = failure.cause;
  // HttpClient 尚未取得响应的协议/连接失败也需有界调度；保留 unknown
  // 诊断，不能凭异常文案把未核验故障改标断网或服务端错误。
  return failure.effectiveSource == FailureSource.unknown &&
      cause is DioException &&
      cause.type == DioExceptionType.unknown &&
      cause.response == null &&
      cause.error is HttpException;
}
