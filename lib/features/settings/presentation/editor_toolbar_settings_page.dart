import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_preference.dart';
import 'package:wenyousite_mobile/core/widgets/editor_tool_icon.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class EditorToolbarSettingsPage extends ConsumerWidget {
  const EditorToolbarSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorToolbarPreferenceControllerProvider);
    final controller = ref.read(
      editorToolbarPreferenceControllerProvider.notifier,
    );
    final tokens = context.wenyouTokens;
    return WenyouSettingsTypography(
      child: Scaffold(
        backgroundColor: wenyouPersonalPageBackground(context),
        appBar: AppBar(
          backgroundColor: wenyouPersonalPageBackground(context),
          title: const Text('编辑器工具栏'),
        ),
        body: WenyouSettingsBody(
          children: [
            if (state.failureMessage case final message?)
              WenyouSettingsFailure(
                message: message,
                retryKey: const Key('editor-toolbar-layout-retry'),
                onRetry: state.isSaving
                    ? null
                    : () => unawaited(controller.retry()),
              ),
            for (final group in EditorToolbarGroup.values)
              WenyouSettingsGroup(
                title: group == EditorToolbarGroup.primary ? '主栏' : '展开栏',
                children: [
                  if (state.layout.toolsIn(group).isEmpty)
                    Padding(
                      padding: EdgeInsets.all(tokens.space16),
                      child: Text(
                        group == EditorToolbarGroup.primary
                            ? '工具均放在展开栏'
                            : '工具均放在主栏',
                      ),
                    )
                  else
                    ReorderableListView.builder(
                      key: ValueKey('toolbar-layout-${group.name}'),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      buildDefaultDragHandles: false,
                      itemCount: state.layout.toolsIn(group).length,
                      onReorderItem: (oldIndex, newIndex) {
                        if (state.isSaving) return;
                        final tool = state.layout.toolsIn(group)[oldIndex];
                        unawaited(
                          controller.select(
                            state.layout.move(tool, group, newIndex),
                          ),
                        );
                      },
                      itemBuilder: (context, index) {
                        final items = state.layout.toolsIn(group);
                        final tool = items[index];
                        final otherGroup = group == EditorToolbarGroup.primary
                            ? EditorToolbarGroup.expanded
                            : EditorToolbarGroup.primary;
                        void move(EditorToolbarGroup target, int position) =>
                            unawaited(
                              controller.select(
                                state.layout.move(tool, target, position),
                              ),
                            );
                        return Material(
                          key: ValueKey('toolbar-layout-${tool.id}'),
                          color: tokens.panel,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: tokens.space16,
                              right: tokens.space4,
                            ),
                            child: Row(
                              children: [
                                ExcludeSemantics(
                                  child: WenyouIcon(editorToolIconId(tool)),
                                ),
                                SizedBox(width: tokens.space12),
                                Expanded(child: Text(tool.label)),
                                ReorderableDragStartListener(
                                  index: index,
                                  enabled: !state.isSaving,
                                  child: Tooltip(
                                    message: '拖动排序',
                                    child: SizedBox.square(
                                      dimension: tokens.minimumTouchTarget,
                                      child: const Center(
                                        child: ExcludeSemantics(
                                          child: WenyouIcon(
                                            WenyouIconIds.actionReorder,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  key: ValueKey(
                                    'toolbar-layout-menu-${tool.id}',
                                  ),
                                  enabled: !state.isSaving,
                                  tooltip: '调整${tool.label}',
                                  icon: const WenyouIcon(
                                    WenyouIconIds.editorMore,
                                  ),
                                  onSelected: (action) {
                                    switch (action) {
                                      case 'up':
                                        move(group, index - 1);
                                      case 'down':
                                        move(group, index + 1);
                                      case 'group':
                                        move(
                                          otherGroup,
                                          state.layout
                                              .toolsIn(otherGroup)
                                              .length,
                                        );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'up',
                                      enabled: index > 0,
                                      child: const Text('上移'),
                                    ),
                                    PopupMenuItem(
                                      value: 'down',
                                      enabled: index < items.length - 1,
                                      child: const Text('下移'),
                                    ),
                                    PopupMenuItem(
                                      value: 'group',
                                      child: Text(
                                        otherGroup == EditorToolbarGroup.primary
                                            ? '移到主栏'
                                            : '移到展开栏',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.space16),
              child: const Text('主栏放不下的按钮会移入展开栏。'),
            ),
            Center(
              child: TextButton(
                key: const Key('editor-toolbar-layout-reset'),
                onPressed:
                    state.isSaving ||
                        (state.layout.isDefault && !state.readFailed)
                    ? null
                    : () => unawaited(
                        controller.select(const EditorToolbarLayout.defaults()),
                      ),
                child: const Text('恢复默认'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
