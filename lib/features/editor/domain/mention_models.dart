enum MentionCandidateRelation { following, player, owner, collaborator }

class MentionCandidate {
  const MentionCandidate({
    required this.id,
    required this.username,
    required this.relation,
    this.rpNickname,
  });

  final String id;
  final String username;
  final MentionCandidateRelation relation;
  final String? rpNickname;

  String get displayName => rpNickname ?? username;
  String get label => '@$displayName';
  String get supportingLabel =>
      rpNickname == null ? relationLabel : '$username · $relationLabel';

  String get relationLabel => switch (relation) {
    MentionCandidateRelation.following => '我关注的人',
    MentionCandidateRelation.player => '帖内玩家',
    MentionCandidateRelation.owner => '楼主',
    MentionCandidateRelation.collaborator => '协作者',
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

final _mentionQueryPattern = RegExp(r'^[^\[\]\\<>\x00-\x1f\x7f]{0,48}$');
final _mentionWordPattern = RegExp(r'[A-Za-z0-9\u4e00-\u9fff]');

ActiveMentionQuery? detectActiveMentionQuery(String plainText, int cursor) {
  if (cursor < 0 || cursor > plainText.length) return null;
  final prefix = plainText.substring(0, cursor);
  final starts = RegExp('@')
      .allMatches(prefix)
      .map((match) => match.start)
      .where(
        (at) =>
            at == 0 ||
            (prefix[at - 1] != r'\' &&
                !_mentionWordPattern.hasMatch(prefix[at - 1])),
      );
  if (starts.isEmpty) return null;
  final at = starts.last;
  final query = prefix.substring(at + 1);
  if (!_mentionQueryPattern.hasMatch(query) || query.runes.length > 24) {
    return null;
  }
  return ActiveMentionQuery(start: at, end: cursor, query: query);
}
