import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_notice.dart';

void main() {
  testWidgets('私聊反馈浮在输入区上方而不是贴底遮挡', (tester) async {
    late BuildContext pageContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              pageContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    showDirectMessageNotice(pageContext, '已接受消息请求。');
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.behavior, SnackBarBehavior.floating);
    expect(
      (snackBar.margin! as EdgeInsets).bottom,
      greaterThanOrEqualTo(directMessageNoticeComposerClearance),
    );
    expect(find.text('已接受消息请求。'), findsOneWidget);
  });
}
