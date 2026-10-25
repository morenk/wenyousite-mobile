import 'package:wenyousite_mobile/core/network/network_recovery.dart';

/// 启用的未读查询全部成功才恢复频率，单个健康端点不能掩盖其他失败。
Future<void> refreshAutomaticUnreadCounts(
  NetworkRecovery recovery,
  List<Future<bool> Function()> reads,
) async {
  if (recovery.isCoolingDown || reads.isEmpty) return;
  final ticket = recovery.ticket;
  final results = await runAutomaticNetworkRequests(
    () => Future.wait(reads.map((read) => read())),
  );
  if (results.every((succeeded) => succeeded)) recovery.succeeded(ticket);
}
