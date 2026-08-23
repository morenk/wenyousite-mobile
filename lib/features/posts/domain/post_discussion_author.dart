enum PostDiscussionAuthorRole {
  owner('楼主'),
  collaborator('协作者'),
  player('玩家');

  const PostDiscussionAuthorRole(this.label);

  final String label;
}

class PostDiscussionAuthor {
  const PostDiscussionAuthor({
    required this.userId,
    required this.username,
    required this.role,
    this.avatarUrl,
  });

  final String userId;
  final String username;
  final String? avatarUrl;
  final PostDiscussionAuthorRole role;
}
