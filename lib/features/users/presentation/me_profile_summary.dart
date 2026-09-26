import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_profile_header.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

class MeProfileSummary extends StatelessWidget {
  const MeProfileSummary({
    required this.profile,
    required this.balance,
    super.key,
  });
  final MeProfileModel profile;
  final String? balance;

  @override
  Widget build(BuildContext context) => UserProfileHeader(
    key: const Key('me-profile-header'),
    username: profile.username,
    avatarUrl: profile.avatarUrl,
    profileCover: profile.profileCover,
    level: profile.level,
    bio: profile.bio,
    levelProgress: profile.levelProgress,
    levelProgressLabel: profile.nextLevelExperience == null
        ? '已达到当前最高等级'
        : '${profile.experience} / ${profile.nextLevelExperience} 经验',
    actionsBesideAvatar: true,
    actions: OutlinedButton(
      key: const Key('me-open-edit-profile'),
      onPressed: () => context.pushNamed('me-edit'),
      child: const Text('编辑资料'),
    ),
    stats: [
      UserProfileStatItem(
        key: const Key('me-open-following'),
        label: '关注',
        value: formatWenyouCompactCount(profile.followingCount),
        semanticValue: '${profile.followingCount}',
        onTap: () => context.pushNamed('me-following'),
      ),
      UserProfileStatItem(
        key: const Key('me-open-followers'),
        label: '粉丝',
        value: formatWenyouCompactCount(profile.followerCount),
        semanticValue: '${profile.followerCount}',
        onTap: () => context.pushNamed('me-followers'),
      ),
      UserProfileStatItem(
        key: const Key('me-open-balance'),
        label: '温油',
        value: balance == null ? '—' : '${WenyouAmount.format(balance!)} 升',
        onTap: () => context.pushNamed('wallet'),
      ),
    ],
  );
}
