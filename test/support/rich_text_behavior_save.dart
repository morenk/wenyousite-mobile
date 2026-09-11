import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_targets.dart';

import 'rich_text_behavior_projection.dart';

class _Repository extends Mock implements PostRepository {}

/// 真实提交控制器与仓储边界，使用专用内存假服务；不宣称真实 API。
Future<BehaviorJson> saveBehaviorMarkdown(String markdown) async {
  final repository = _Repository();
  String? requested;
  final initial = PostItem(
    id: 'post',
    threadId: 'thread',
    subthreadId: 'subthread',
    author: const PostAuthor(id: 'author', username: '测试', level: 1),
    content: '保存前正文',
    version: 1,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    isBody: false,
    isDeleted: false,
  );
  PostItem? persisted;
  when(
    () => repository.update(
      postId: 'post',
      content: any(named: 'content'),
      version: 1,
    ),
  ).thenAnswer((invocation) async {
    requested = invocation.namedArguments[#content] as String;
    persisted = PostItem(
      id: 'post',
      threadId: 'thread',
      subthreadId: 'subthread',
      author: initial.author,
      content: requested!,
      version: 2,
      createdAt: initial.createdAt,
      updatedAt: initial.updatedAt,
      isBody: false,
      isDeleted: false,
    );
    return persisted!;
  });
  final controller = PostComposerController(
    repository,
    postEditTarget(initial, '编辑正文'),
  );
  try {
    controller.updateContent(markdown);
    expect(await controller.submit(), isNotNull);
    return {
      'requestMarkdown': requested,
      'persistedMarkdown': persisted?.content,
      'dirty': controller.state.content != persisted?.content,
    };
  } finally {
    controller.dispose();
  }
}
