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
  test('不支持颜色时保留草稿并在调用网络之前拒绝写入', () async {
    final api = _PostsApi();
    final repository = ApiPostRepository(api, textColorSupported: false);
    const content = '<span data-wenyou-color-v1="#123456">文字</span>';
    final failure = throwsA(
      isA<ApiFailure>()
          .having((value) => value.businessCode, 'code', 40016)
          .having((value) => value.reason, 'reason', FailureReason.validation)
          .having(
            (value) => value.recoveryAction,
            'recovery',
            FailureRecoveryAction.keepDraft,
          ),
    );
    await expectLater(
      repository.create(
        const PostCreateInput(
          subthreadId: 'subthread',
          content: content,
          identityMode: PostIdentityMode.account,
          clientRequestId: '123e4567-e89b-42d3-a456-426614174000',
        ),
      ),
      failure,
    );
    await expectLater(
      repository.update(postId: 'post', content: content, version: 1),
      failure,
    );
    await expectLater(
      repository.upsertBody(
        subthreadId: 'subthread',
        content: content,
        version: 1,
        identityMode: PostIdentityMode.account,
      ),
      failure,
    );
    verifyZeroInteractions(api);
  });

  test('旧服务本地拒绝已恢复彩色草稿，能力缺失不发送有损正文', () {
    const source = '<span data-wenyou-color-v1="#123456">文字</span>';
    expect(
      () => requireTextColorWriteSupport(source, supported: false),
      throwsA(
        isA<ApiFailure>()
            .having((e) => e.businessCode, 'code', 40016)
            .having((e) => e.reason, 'reason', FailureReason.validation)
            .having(
              (e) => e.recoveryAction,
              'recovery',
              FailureRecoveryAction.keepDraft,
            )
            .having((e) => e.effectiveSource, 'source', FailureSource.expected)
            .having((e) => e.legacyUserMessage, 'no transport copy', isNull)
            .having(
              (e) => UserFacingFailure.fromApi(e).message,
              'presentation',
              '暂时无法保存文字颜色，草稿已保留。',
            )
            .having(
              (e) => UserFacingFailure.fromApi(e).retainContent,
              'retain draft',
              isTrue,
            ),
      ),
    );
    expect(
      () => requireTextColorWriteSupport(source, supported: true),
      returnsNormally,
    );
    expect(
      () => requireTextColorWriteSupport('`$source`', supported: false),
      returnsNormally,
    );
    expect(
      () => requireTextColorWriteSupport('```\n$source\n```', supported: false),
      returnsNormally,
    );
    for (final link in ['[网站](https://example.com "标题")', '[网站](/about)']) {
      expect(
        () => requireTextColorWriteSupport(
          '<span data-wenyou-color-v1="#123456">$link</span>',
          supported: false,
        ),
        throwsA(isA<ApiFailure>()),
      );
    }
  });
}
