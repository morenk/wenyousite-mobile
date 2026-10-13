import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';

class ToolboxPage extends StatelessWidget {
  const ToolboxPage({super.key});

  @override
  Widget build(BuildContext context) => WenyouSettingsTypography(
    child: Scaffold(
      backgroundColor: wenyouPersonalPageBackground(context),
      appBar: AppBar(
        backgroundColor: wenyouPersonalPageBackground(context),
        title: const Text('工具箱'),
      ),
      body: WenyouSettingsBody(
        children: [
          WenyouSettingsGroup(
            title: '文字处理',
            children: [
              for (final tool in TextTool.values)
                WenyouSettingsLink(
                  key: ValueKey('toolbox-${tool.id}'),
                  icon: switch (tool) {
                    TextTool.vertical => WenyouIconIds.actionSort,
                    TextTool.morse => WenyouIconIds.editorInlineCode,
                    TextTool.fancy => WenyouIconIds.editorItalic,
                    TextTool.names => WenyouIconIds.identityMember,
                  },
                  title: tool.title,
                  onTap: () => context.pushNamed(
                    AppRouteNames.textTool,
                    pathParameters: {'toolId': tool.id},
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
