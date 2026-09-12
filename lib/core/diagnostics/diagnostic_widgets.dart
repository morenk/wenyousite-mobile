import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';

class CopyDiagnosticButton extends StatefulWidget {
  const CopyDiagnosticButton({this.failure, this.diagnosticId, super.key});
  final Object? failure;
  final String? diagnosticId;
  @override
  State<CopyDiagnosticButton> createState() => _CopyDiagnosticButtonState();
}

class _CopyDiagnosticButtonState extends State<CopyDiagnosticButton> {
  String _label = '复制问题详情';
  @override
  void didUpdateWidget(CopyDiagnosticButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.failure != widget.failure ||
        oldWidget.diagnosticId != widget.diagnosticId) {
      _label = '复制问题详情';
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnostics = FailureDiagnostics.instance;
    return AnimatedBuilder(
      animation: diagnostics,
      builder: (context, _) {
        final id = widget.diagnosticId ?? diagnostics.idFor(widget.failure);
        if (id == null || !diagnostics.records.any((r) => r.id == id)) {
          return const SizedBox.shrink();
        }
        return TextButton(
          onPressed: () async {
            try {
              await Clipboard.setData(
                ClipboardData(text: diagnostics.export(id: id)),
              );
              if (mounted) setState(() => _label = '已复制');
            } on Object {
              if (mounted) setState(() => _label = '复制失败，重试');
            }
          },
          child: Text(_label),
        );
      },
    );
  }
}

String diagnosticOperationLabel(DiagnosticOperation operation) =>
    switch (operation) {
      DiagnosticOperation.postEdit => '楼层保存失败',
      DiagnosticOperation.postCreate => '楼层发布失败',
      DiagnosticOperation.bodySave => '正文保存失败',
      DiagnosticOperation.mediaUpload => '图片上传失败',
      DiagnosticOperation.editorEncode => '正文处理失败',
      DiagnosticOperation.apiRead => '内容加载失败',
      DiagnosticOperation.apiWrite => '操作失败',
      DiagnosticOperation.authRefresh => '登录续期失败',
      DiagnosticOperation.authLogout => '退出失败',
      DiagnosticOperation.flutterError ||
      DiagnosticOperation.dartError => '应用运行异常',
    };
