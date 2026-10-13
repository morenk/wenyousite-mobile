import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/name_tool_panel.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_typography.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/transform_tool_panel.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/vertical_tool_panel.dart';

class TextToolPage extends StatefulWidget {
  const TextToolPage({required this.tool, super.key});
  final TextTool tool;
  @override
  State<TextToolPage> createState() => _TextToolPageState();
}

class _TextToolPageState extends State<TextToolPage> {
  void _returnToDirectory() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouteLocations.toolbox);
    }
  }

  @override
  Widget build(BuildContext context) => ToolTypography(
    child: Scaffold(
      backgroundColor: wenyouPersonalPageBackground(context),
      appBar: AppBar(
        backgroundColor: wenyouPersonalPageBackground(context),
        title: Text(widget.tool.title),
        leading: IconButton(
          tooltip: '返回工具箱',
          icon: const WenyouIcon(WenyouIconIds.navigationBack),
          onPressed: _returnToDirectory,
        ),
      ),
      body: WenyouSettingsBody(
        children: [
          switch (widget.tool) {
            TextTool.vertical => const VerticalToolPanel(),
            TextTool.morse || TextTool.fancy => TransformToolPanel(
              tool: widget.tool,
              key: ValueKey(widget.tool),
            ),
            TextTool.names => const NameToolPanel(),
          },
        ],
      ),
    ),
  );
}
