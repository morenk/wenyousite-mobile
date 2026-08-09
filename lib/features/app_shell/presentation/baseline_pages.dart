import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class ComposeBaselinePage extends StatelessWidget {
  const ComposeBaselinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建主题')),
      body: const WenyouPageBody(
        maxWidth: 600,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: Icons.edit_note_rounded,
            title: '创建入口已就绪',
            message: '编辑器、草稿和图片上传将在对应垂直切片接入。',
          ),
        ),
      ),
    );
  }
}
