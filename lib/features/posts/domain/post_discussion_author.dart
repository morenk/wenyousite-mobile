import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

enum PostDiscussionAuthorRole {
  owner('楼主'),
  collaborator('协作者'),
  player('玩家'),
  participant('参与人');

  const PostDiscussionAuthorRole(this.label);

  final String label;
}

class PostDiscussionAuthor {
  const PostDiscussionAuthor({
    required this.userId,
    required this.username,
    required this.role,
    this.avatarUrl,
    this.rpIdentity,
  });

  final String userId;
  final String username;
  final String? avatarUrl;
  final RpIdentity? rpIdentity;
  String get displayName => username;
  String? get displayAvatarUrl => avatarUrl;
  String get supportingLabel => role.label;
  final PostDiscussionAuthorRole role;
}
