enum MentionCandidateRelation { following, player, unknown }

class MentionCandidate {
  const MentionCandidate({
    required this.id,
    required this.username,
    required this.relation,
  });

  final String id;
  final String username;
  final MentionCandidateRelation relation;

  String get label => '@$username';

  String get relationLabel => switch (relation) {
    MentionCandidateRelation.following => '我关注的人',
    MentionCandidateRelation.player => '帖内玩家',
    MentionCandidateRelation.unknown => '可提及用户',
  };
}

class MentionCandidatesResult {
  const MentionCandidatesResult({
    required this.users,
    required this.canMentionAllPlayers,
  });

  const MentionCandidatesResult.empty()
    : users = const [],
      canMentionAllPlayers = false;

  final List<MentionCandidate> users;
  final bool canMentionAllPlayers;
}

class ActiveMentionQuery {
  const ActiveMentionQuery({
    required this.start,
    required this.end,
    required this.query,
  });

  final int start;
  final int end;
  final String query;

  int get length => end - start;

  @override
  bool operator ==(Object other) =>
      other is ActiveMentionQuery &&
      other.start == start &&
      other.end == end &&
      other.query == query;

  @override
  int get hashCode => Object.hash(start, end, query);
}

final _mentionQueryPattern = RegExp(r'^[A-Za-z0-9\u4e00-\u9fff]{0,24}$');
final _mentionWordPattern = RegExp(r'[A-Za-z0-9\u4e00-\u9fff]');

ActiveMentionQuery? detectActiveMentionQuery(String plainText, int cursor) {
  if (cursor < 0 || cursor > plainText.length) return null;
  final prefix = plainText.substring(0, cursor);
  final at = prefix.lastIndexOf('@');
  if (at < 0) return null;
  if (at > 0) {
    final previous = prefix[at - 1];
    if (previous == r'\' || _mentionWordPattern.hasMatch(previous)) {
      return null;
    }
  }
  final query = prefix.substring(at + 1);
  if (!_mentionQueryPattern.hasMatch(query)) return null;
  return ActiveMentionQuery(start: at, end: cursor, query: query);
}
