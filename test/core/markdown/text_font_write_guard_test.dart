import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_write_guard.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

class _PostsApi extends Mock implements PostsApi {}

void main() {
  final retained = throwsA(
    isA<ApiFailure>()
        .having((e) => e.businessCode, 'code', 40019)
        .having((e) => e.reason, 'reason', FailureReason.validation)
        .having(
          (e) => e.recoveryAction,
          'recovery',
          FailureRecoveryAction.keepDraft,
        )
        .having(
          (e) => UserFacingFailure.fromApi(e).retainContent,
          'retain',
          isTrue,
        ),
  );
  test('旧服务拒绝已知和未来字体，字面代码不误报', () {
    for (final id in ['wenkai', 'future-font']) {
      final source = '<span data-wenyou-font-v1="$id">文字</span>';
      expect(
        () => requireTextFontWriteSupport(source, supported: false),
        retained,
      );
      expect(
        () => requireTextFontWriteSupport(source, supported: true),
        returnsNormally,
      );
      expect(
        () => requireTextFontWriteSupport('`$source`', supported: false),
        returnsNormally,
      );
      expect(
        () =>
            requireTextFontWriteSupport('```\n$source\n```', supported: false),
        returnsNormally,
      );
    }
  });
  test('创建、更新与正文 upsert 在网络前拒绝字体并保留内容', () async {
    final api = _PostsApi();
    final repository = ApiPostRepository(api);
    const content = '<span data-wenyou-font-v1="wenkai">文字</span>';
    await expectLater(
      repository.create(
        const PostCreateInput(
          subthreadId: 'subthread',
          content: content,
          identityMode: PostIdentityMode.account,
          clientRequestId: '123e4567-e89b-42d3-a456-426614174000',
        ),
      ),
      retained,
    );
    await expectLater(
      repository.update(postId: 'post', content: content, version: 1),
      retained,
    );
    await expectLater(
      repository.upsertBody(
        subthreadId: 'subthread',
        content: content,
        version: 1,
        identityMode: PostIdentityMode.account,
      ),
      retained,
    );
    verifyZeroInteractions(api);
  });
}
