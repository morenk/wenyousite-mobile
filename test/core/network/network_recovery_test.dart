import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_recovery.dart';

void main() {
  test('冷却拒绝没有发出请求，不生成诊断或未知写入事件', () async {
    final recovery = NetworkRecovery();
    recovery.failed(recovery.ticket, _offline);
    final failure = recovery.deferredFailure;
    final diagnostics = FailureDiagnostics();
    for (final operation in DiagnosticOperation.values) {
      expect(shouldSendDiagnostic(failure, operation), isFalse);
      diagnostics.capture(failure, failure: failure, operation: operation);
    }
    await diagnostics.settled;
    expect(diagnostics.records, isEmpty);
    expect(failure.hasUnknownWriteOutcome, isFalse);
  });

  test('权限、解析、本地与不带传输证据的 HttpException 不计入冷却', () {
    final recovery = NetworkRecovery();
    for (final failure in [
      const ApiFailure(httpStatus: 403, businessCode: 40300),
      const ApiFailure.invalidResponse(diagnosticCode: 'test.invalid'),
      const ApiFailure.localWrite(diagnosticCode: 'test.storage'),
      const HttpException('outside transport'),
      ApiFailure.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          error: const FormatException('invalid response'),
        ),
      ),
      ApiFailure.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response<Object?>(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 200,
          ),
          error: const HttpException('already answered'),
        ),
      ),
      StateError('local test'),
    ]) {
      recovery.failed(recovery.ticket, failure);
      expect(recovery.isCoolingDown, isFalse);
    }
  });

  test('无响应 Dio unknown HttpException 只增加调度冷却且保留未知诊断', () {
    final recovery = NetworkRecovery(elapsed: () => Duration.zero);
    final failure = ApiFailure.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: const HttpException('unverified transport'),
      ),
    );
    recovery.failed(recovery.ticket, failure);
    expect(recovery.remaining.inSeconds, inInclusiveRange(30, 33));
    expect(failure.effectiveSource, FailureSource.unknown);
    expect(failure.reason, FailureReason.unknown);
    expect(shouldSendDiagnostic(failure, DiagnosticOperation.apiRead), isTrue);
  });

  test('并行两路与四路读取中的传输失败只占一次预算', () async {
    for (final action in [
      () => (Future<void>.error(_offline), Future<void>.value()).wait,
      () => (
        Future<void>.value(),
        Future<void>.error(_offline),
        Future<void>.value(),
        Future<void>.value(),
      ).wait,
    ]) {
      final recovery = NetworkRecovery();
      try {
        await action();
        fail('应保留并行读取失败');
      } on Object catch (error) {
        recovery.failed(recovery.ticket, error);
      }
      expect(recovery.remaining.inSeconds, inInclusiveRange(29, 33));
    }
  });

  test('连续失败按指数退避，包含有限抖动且最多五分钟', () {
    var elapsed = Duration.zero;
    final recovery = NetworkRecovery(elapsed: () => elapsed, random: Random(1));
    for (final seconds in [30, 60, 120, 240, 300, 300, 300]) {
      recovery.failed(recovery.ticket, _offline);
      expect(
        recovery.remaining.inMilliseconds,
        greaterThanOrEqualTo(seconds * 1000),
      );
      expect(
        recovery.remaining.inMilliseconds,
        lessThanOrEqualTo(min(seconds * 1100, 300000)),
      );
      elapsed += recovery.remaining;
      expect(recovery.isCoolingDown, isFalse);
    }
    recovery.succeeded(recovery.ticket);
    recovery.failed(recovery.ticket, _offline);
    expect(recovery.remaining.inSeconds, inInclusiveRange(30, 33));
  });

  test('相同失败的多层观察只计一次，旧成功不能解除新冷却', () {
    final recovery = NetworkRecovery(elapsed: () => Duration.zero);
    final ticket = recovery.ticket;
    recovery.failed(ticket, _offline);
    final remaining = recovery.remaining;
    recovery.failed(ticket, _offline);
    recovery.succeeded(ticket);
    expect(recovery.remaining, remaining);
    final failure = recovery.deferredFailure;
    expect(failure.reason, FailureReason.cancelled);
    expect(failure.requestId, isNull);
    expect(failure.cause, isNull);
  });

  test('账号边界使旧成功失败无效，取消不创建冷却', () {
    final recovery = NetworkRecovery(elapsed: () => Duration.zero);
    final ticket = recovery.ticket;
    recovery.failed(ticket, _offline);
    recovery.resetSession();
    recovery.failed(ticket, _offline);
    expect(recovery.isCoolingDown, isFalse);
    recovery.failed(
      recovery.ticket,
      const ApiFailure(reason: FailureReason.cancelled),
    );
    expect(recovery.isCoolingDown, isFalse);
  });

  test('自动请求意图沿异步回调保留且不影响其他请求', () async {
    expect(isAutomaticNetworkRequest, isFalse);
    await runAutomaticNetworkRequests(() async {
      await Future<void>.value();
      expect(isAutomaticNetworkRequest, isTrue);
    });
    expect(isAutomaticNetworkRequest, isFalse);
  });
}

const _offline = ApiFailure(
  source: FailureSource.network,
  reason: FailureReason.offline,
);
