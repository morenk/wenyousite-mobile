import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_widgets.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class DiagnosticSettingsPage extends ConsumerWidget {
  const DiagnosticSettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnostics = ref.watch(failureDiagnosticsProvider);
    final page = Scaffold(
      appBar: AppBar(title: const Text('故障诊断')),
      body: AnimatedBuilder(
        animation: diagnostics,
        builder: (context, _) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('自动发送故障诊断'),
                subtitle: const Text('帮助定位故障。不包含正文、图片、链接和账号信息。'),
                value: diagnostics.automaticSending,
                onChanged: diagnostics.setAutomaticSending,
              ),
              if (!diagnostics.remoteAvailable)
                const ListTile(title: Text('当前版本仅保留本机记录，可复制后反馈。')),
              if (!diagnostics.storageAvailable)
                const ListTile(title: Text('记录保存失败，请在退出应用前复制需要反馈的问题。')),
              const ListTile(subtitle: Text('最多保留 7 天内的 50 条记录。退出账号或切换账号时清除。')),
              ListTile(
                title: const Text('清除本机记录'),
                enabled: diagnostics.records.isNotEmpty,
                onTap: diagnostics.clear,
              ),
              if (diagnostics.records.isEmpty)
                const ListTile(title: Text('暂无故障记录')),
              for (final record in diagnostics.records)
                WenyouStatusBanner(
                  message: diagnosticOperationLabel(record.operation),
                  detail:
                      '${record.createdAt.toLocal()}\n${wenyouProblemDetailFromId(record.id)}',
                  action: CopyDiagnosticButton(diagnosticId: record.id),
                ),
            ],
          );
        },
      ),
    );
    return WenyouSettingsTypography(child: page);
  }
}
