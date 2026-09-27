import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart'
    show wenyouHorizontalPagePadding;

/// 普通选择和管理抽屉：按内容收缩，长内容最多占可用高度的九成。
Future<T?> showWenyouSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  constraints: BoxConstraints(
    maxWidth: context.wenyouTokens.pageContentMaxWidth,
  ),
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints(maxHeight: constraints.maxHeight * .9),
          child: builder(context),
        ),
      ),
    ),
  ),
);

/// 标题和动作随内容一起滚动，键盘和大字号不会挤掉正文操作。
class WenyouSheetBody extends StatelessWidget {
  const WenyouSheetBody({
    required this.title,
    required this.slivers,
    this.actions = const [],
    this.scrollKey,
    super.key,
  });

  final String title;
  final List<Widget> slivers;
  final List<Widget> actions;
  final Key? scrollKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return LayoutBuilder(
      builder: (context, constraints) => CustomScrollView(
        key: scrollKey,
        shrinkWrap: true,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              wenyouHorizontalPagePadding(
                context,
                availableWidth: constraints.maxWidth,
              ),
              0,
              wenyouHorizontalPagePadding(
                context,
                availableWidth: constraints.maxWidth,
              ),
              tokens.space16,
            ),
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: tokens.space12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(
                              context,
                            ).textTheme.wenyouOverlayTitle,
                          ),
                        ),
                        ...actions,
                        IconButton(
                          tooltip: '关闭$title',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const WenyouIcon(WenyouIconIds.actionClose),
                        ),
                      ],
                    ),
                  ),
                ),
                ...slivers,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
