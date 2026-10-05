/// 账号始终是权限和动作目标，RP 只承载本次已授权的展示投影。
class RpIdentity {
  const RpIdentity({required this.id, required this.nickname, this.avatarUrl});

  final String id;
  final String nickname;
  final String? avatarUrl;
}

enum PostIdentityMode { account, rp }

String? validateThreadIdentityNickname(String value) {
  final nickname = value.trim();
  if (nickname.runes.length > 24) return '帖内昵称最多 24 个字符。';
  if (RegExp(r'[\[\]\\<>\p{Cc}\p{Cf}]', unicode: true).hasMatch(nickname)) {
    return '帖内昵称不能包含方括号、反斜线、尖括号或不可见控制字符。';
  }
  return null;
}

class ThreadIdentityUpdate {
  const ThreadIdentityUpdate({
    this.nickname,
    this.avatarMediaId,
    this.clearNickname = false,
    this.clearAvatar = false,
    this.version,
    this.profilePostId,
    this.clearProfilePost = false,
  });

  final String? nickname;
  final String? avatarMediaId;
  final bool clearNickname;
  final bool clearAvatar;
  final int? version;
  final String? profilePostId;
  final bool clearProfilePost;
}

/// 同一发表会话保留新建角色输入，网络结果不明时可先返回身份列表核对。
class ThreadIdentityEditorDraft {
  String nickname = '';
  String profileLink = '';
  String? avatarMediaId;
  String? avatarUrl;
  bool uncertain = false;
  void clear() {
    nickname = '';
    profileLink = '';
    avatarMediaId = null;
    avatarUrl = null;
    uncertain = false;
  }
}
