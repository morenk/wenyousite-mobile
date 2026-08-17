import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';

void main() {
  testWidgets('等级徽标使用 Foundation 等级档位且拒绝无效等级', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [WenyouLevelBadge(level: 4), WenyouLevelBadge(level: 0)],
        ),
      ),
    );

    expect(find.text('Lv.4'), findsOneWidget);
    expect(find.text('Lv.0'), findsNothing);
    final decoration =
        tester
                .widget<Container>(
                  find.ancestor(
                    of: find.text('Lv.4'),
                    matching: find.byType(Container),
                  ),
                )
                .decoration!
            as BoxDecoration;
    final tier = WenyouLevelContract.resolve(4)!;
    expect(decoration.color, tier.surface);
    expect(decoration.border, Border.all(color: tier.border));
  });
}
