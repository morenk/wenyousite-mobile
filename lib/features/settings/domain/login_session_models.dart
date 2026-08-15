enum LoginSessionPlatform { web, mobile, unknown }

class LoginSessionModel {
  const LoginSessionModel({
    required this.id,
    required this.platform,
    required this.isCurrent,
    required this.signedInAt,
    required this.lastActiveAt,
    required this.expiresAt,
  });

  final String id;
  final LoginSessionPlatform platform;
  final bool isCurrent;
  final DateTime signedInAt;
  final DateTime lastActiveAt;
  final DateTime expiresAt;
}
