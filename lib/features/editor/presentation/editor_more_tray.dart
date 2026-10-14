import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

class WenyouEditorMoreTray extends StatelessWidget {
  const WenyouEditorMoreTray({required this.entries, super.key});
  final List<Widget> entries;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Container(
      key: const Key('editor-more-tray'),
      constraints: const BoxConstraints(maxHeight: 152),
      padding: EdgeInsets.symmetric(vertical: tokens.space4),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: SingleChildScrollView(
        key: const Key('editor-more-tray-scroll'),
        padding: const EdgeInsets.symmetric(
          horizontal: WenyouEditorContract.toolbarHorizontalPadding,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (entries.isEmpty) return const SizedBox.shrink();
            final maximumColumns =
                (constraints.maxWidth /
                        WenyouEditorContract.minimumActionExtent)
                    .floor()
                    .clamp(1, 6);
            final rowCount = (entries.length / maximumColumns).ceil();
            final minimumRowLength = entries.length ~/ rowCount;
            final longerRows = entries.length % rowCount;
            final rows = <List<Widget>>[];
            var entryIndex = 0;
            for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) {
              final rowLength =
                  minimumRowLength + (rowIndex < longerRows ? 1 : 0);
              rows.add(entries.sublist(entryIndex, entryIndex += rowLength));
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (rowIndex, rowEntries) in rows.indexed)
                  Row(
                    key: Key('editor-more-row-$rowIndex'),
                    children: [
                      for (final entry in rowEntries)
                        Expanded(
                          child: Center(
                            child: SizedBox.square(
                              dimension:
                                  WenyouEditorContract.minimumActionExtent,
                              child: entry,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
