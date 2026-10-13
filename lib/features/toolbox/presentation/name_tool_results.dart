import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/toolbox/application/name_generator.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_controls.dart';

class NameToolResults extends StatelessWidget {
  const NameToolResults({
    required this.names,
    required this.requestedCount,
    required this.foreign,
    super.key,
  });
  final List<GeneratedName> names;
  final int requestedCount;
  final bool foreign;

  @override
  Widget build(BuildContext context) => ToolSection(
    children: [
      Wrap(
        spacing: context.wenyouTokens.space8,
        children: [
          if (foreign) ...[
            _copyButton(
              context,
              '复制原文',
              names.map((name) => name.original).join('\n'),
            ),
            _copyButton(
              context,
              '复制中文',
              names.map((name) => name.zh).join('\n'),
            ),
          ],
          _copyButton(
            context,
            '复制全部',
            names.map((name) => name.bilingual).join('\n'),
          ),
        ],
      ),
      if (names.length < requestedCount) Text('已生成 ${names.length} 个不同姓名'),
      for (final name in names)
        SelectableText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: name.original,
                style: Theme.of(
                  context,
                ).textTheme.wenyouBody.copyWith(fontWeight: FontWeight.w400),
              ),
              if (name.zh != name.original)
                TextSpan(
                  text: '\n${name.zh}',
                  style: Theme.of(context).textTheme.wenyouCompactBody.copyWith(
                    color: context.wenyouTokens.mutedText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
    ],
  );

  Widget _copyButton(BuildContext context, String label, String text) =>
      TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size(0, context.wenyouTokens.minimumTouchTarget),
          foregroundColor: context.wenyouTokens.mutedText,
        ),
        onPressed: () => copyToolText(context, text),
        child: Text(label),
      );
}
