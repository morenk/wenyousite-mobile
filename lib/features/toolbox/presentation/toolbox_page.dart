import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';

class ToolboxPage extends StatelessWidget {
  const ToolboxPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('温油工具箱')),
    body: WenyouPageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('文字处理', style: Theme.of(context).textTheme.wenyouSectionTitle),
          SizedBox(height: context.wenyouTokens.space12),
          WenyouPanel(
            child: Column(
              children: [
                for (final tool in TextTool.values)
                  ListTile(
                    key: ValueKey('toolbox-${tool.id}'),
                    title: Text(tool.title),
                    subtitle: Text(tool.description),
                    onTap: () => context.pushNamed(
                      AppRouteNames.textTool,
                      pathParameters: {'toolId': tool.id},
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.wenyouTokens.space12),
          const Text('首次打开需要联网。输入和结果仅在当前页面保留。'),
        ],
      ),
    ),
  );
}
