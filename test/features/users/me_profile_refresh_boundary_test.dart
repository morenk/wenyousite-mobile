import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_profile_refresh_boundary.dart';

void main() {
  testWidgets('返回保活的我的页和前台恢复会重读经验，隐藏页与卸载后不请求', (tester) async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [meProfileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    addTearDown(
      () => tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      ),
    );
    Widget app(bool active) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: TickerMode(
          enabled: active,
          child: MeProfileRefreshBoundary(
            child: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(meProfileControllerProvider);
                return Text('${state.profile?.experience ?? 0}');
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(app(true));
    await tester.pumpAndSettle();
    expect(repository.calls, 1);
    expect(find.text('10'), findsOneWidget);
    repository.experience = 42;
    await tester.pumpWidget(app(false));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(repository.calls, 1);
    await tester.pumpWidget(app(true));
    await tester.pumpAndSettle();
    expect(repository.calls, 2);
    expect(find.text('42'), findsOneWidget);
    await tester.pumpWidget(app(true));
    await tester.pumpAndSettle();
    expect(repository.calls, 2);
    repository.experience = 45;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(repository.calls, 3);
    expect(find.text('45'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(repository.calls, 3);
  });
}

class _Repository extends Fake implements MeProfileRepository {
  int calls = 0;
  int experience = 10;

  @override
  Future<MeProfileModel> fetchMe() async {
    calls++;
    return MeProfileModel(
      id: 'user-1',
      email: 'tester@example.com',
      username: '测试员',
      level: 2,
      experience: experience,
      currentLevelExperience: 10,
      nextLevelExperience: 50,
      receivedTipTotal: '0',
      receivedTipCount: 0,
      showRecentReplies: true,
      showPlayedThreads: true,
      showBookmarks: true,
      followingCount: 0,
      followerCount: 0,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }
}
