import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_render_geometry.dart';

void main() {
  testWidgets('真实渲染几何包含屏幕坐标、可见比例、约束和滚动范围', (tester) async {
    final targetKey = GlobalKey();
    final scrollController = ScrollController();
    late BuildContext pageContext;
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            pageContext = context;
            return Scaffold(
              body: Stack(
                children: [
                  ListView(
                    controller: scrollController,
                    children: const [SizedBox(height: 1200)],
                  ),
                  Positioned(
                    left: 20,
                    top: 100,
                    child: SizedBox(key: targetKey, width: 80, height: 40),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    final snapshot = buildDebugRenderGeometrySnapshot(
      context: pageContext,
      targets: {'fixedTarget': targetKey},
      scrollController: scrollController,
    );
    final targets = snapshot['targets']! as Map<String, Object?>;
    final target = targets['fixedTarget']! as Map<String, Object?>;
    final rect = target['globalRect']! as Map<String, Object>;
    final constraints = target['constraints']! as Map<String, Object?>;
    final scroll = snapshot['scroll']! as Map<String, Object?>;

    expect(target['present'], isTrue);
    expect(target['attached'], isTrue);
    expect(rect['left'], 20);
    expect(rect['top'], 100);
    expect(rect['width'], 80);
    expect(rect['height'], 40);
    expect(target['visibleFraction'], 1);
    expect(constraints['maxWidth'], 'infinity');
    expect(scroll['attached'], isTrue);
    expect(scroll['viewportDimension'], greaterThan(0));
    expect(scroll['maxScrollExtent'], greaterThan(0));
  });
}
