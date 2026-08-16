import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/models/paging.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_states.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';

export 'package:wenyousite_mobile/features/users/application/public_user_states.dart';

enum PublicUserPhase { loading, ready, failed }

enum PublicUserActivityPhase { idle, loading, ready, failed }

class PublicUserState {
  const PublicUserState({
    this.phase = PublicUserPhase.loading,
    this.profile,
    this.failure,
    this.activityPhase = PublicUserActivityPhase.idle,
    this.activitySummary,
    this.activityFailure,
    this.activeTab = PublicUserContentTab.created,
    this.created = const PublicUserContentSection(),
    this.played = const PublicUserContentSection(),
    this.replies = const PublicUserContentSection(),
    this.bookmarks = const PublicUserContentSection(),
  });

  final PublicUserPhase phase;
  final PublicUserProfileModel? profile;
  final ApiFailure? failure;
  final PublicUserActivityPhase activityPhase;
  final PublicUserActivitySummary? activitySummary;
  final ApiFailure? activityFailure;
  final PublicUserContentTab activeTab;
  final PublicUserContentSection<PublicUserThreadModel> created;
  final PublicUserContentSection<PublicUserThreadModel> played;
  final PublicUserContentSection<PublicUserReplyModel> replies;
  final PublicUserContentSection<PublicUserThreadModel> bookmarks;

  List<PublicUserContentTab> get availableTabs =>
      profile?.availableContentTabs ?? const [PublicUserContentTab.created];

  PublicUserState copyWith({
    PublicUserPhase? phase,
    PublicUserProfileModel? profile,
    ApiFailure? failure,
    PublicUserActivityPhase? activityPhase,
    PublicUserActivitySummary? activitySummary,
    ApiFailure? activityFailure,
    PublicUserContentTab? activeTab,
    PublicUserContentSection<PublicUserThreadModel>? created,
    PublicUserContentSection<PublicUserThreadModel>? played,
    PublicUserContentSection<PublicUserReplyModel>? replies,
    PublicUserContentSection<PublicUserThreadModel>? bookmarks,
  }) {
    return PublicUserState(
      phase: phase ?? this.phase,
      profile: profile ?? this.profile,
      failure: failure,
      activityPhase: activityPhase ?? this.activityPhase,
      activitySummary: activitySummary ?? this.activitySummary,
      activityFailure: activityFailure,
      activeTab: activeTab ?? this.activeTab,
      created: created ?? this.created,
      played: played ?? this.played,
      replies: replies ?? this.replies,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}

class PublicUserController extends StateNotifier<PublicUserState> {
  PublicUserController(this._repository, this.userId, {bool autoStart = true})
    : super(const PublicUserState()) {
    if (autoStart) unawaited(load());
  }

  final PublicUserRepository _repository;
  final String userId;
  int _profileEpoch = 0;
  final _sectionEpochs = <PublicUserContentTab, int>{};

  Future<void> load() async {
    final epoch = ++_profileEpoch;
    final previousTab = state.activeTab;
    state = PublicUserState(activeTab: previousTab);
    try {
      final profile = await _repository.fetchUser(userId);
      if (!_isProfileCurrent(epoch)) return;
      final availableTabs = profile.availableContentTabs;
      final activeTab = availableTabs.contains(previousTab)
          ? previousTab
          : PublicUserContentTab.created;
      state = PublicUserState(
        phase: PublicUserPhase.ready,
        profile: profile,
        activeTab: activeTab,
      );
      if (!profile.isDeactivated) {
        await Future.wait([
          _loadActivitySummary(epoch),
          _loadTab(activeTab, epoch),
        ]);
      }
    } on Object catch (error) {
      if (!_isProfileCurrent(epoch)) return;
      state = PublicUserState(
        phase: PublicUserPhase.failed,
        activeTab: previousTab,
        failure: _asFailure(error, '用户资料没有加载完成，请稍后重试。'),
      );
    }
  }

  Future<void> retryActivitySummary() {
    if (state.phase != PublicUserPhase.ready ||
        state.profile?.isDeactivated != false ||
        state.activityPhase == PublicUserActivityPhase.loading) {
      return Future.value();
    }
    return _loadActivitySummary(_profileEpoch);
  }

  Future<void> selectTab(PublicUserContentTab tab) async {
    if (state.phase != PublicUserPhase.ready ||
        !state.availableTabs.contains(tab)) {
      return;
    }
    if (state.activeTab != tab) state = state.copyWith(activeTab: tab);
    if (_sectionPhase(tab) == PublicUserContentPhase.idle) {
      await _loadTab(tab, _profileEpoch);
    }
  }

  Future<void> retryActive() {
    if (state.phase != PublicUserPhase.ready) return Future.value();
    return _loadTab(state.activeTab, _profileEpoch);
  }

  Future<void> loadMoreActive() async {
    if (state.phase != PublicUserPhase.ready ||
        state.activeTab == PublicUserContentTab.replies) {
      return;
    }
    final tab = state.activeTab;
    final section = _threadSection(tab);
    if (section.phase != PublicUserContentPhase.ready ||
        section.isLoadingMore ||
        !section.hasMore) {
      return;
    }
    final epoch = _profileEpoch;
    final sectionEpoch = _nextSectionEpoch(tab);
    _setThreadSection(
      tab,
      PublicUserContentSection(
        phase: section.phase,
        items: section.items,
        cursor: section.cursor,
        hasMore: section.hasMore,
        isLoadingMore: true,
      ),
    );
    try {
      final page = await _fetchThreadPage(tab, cursor: section.cursor);
      if (!_isSectionCurrent(epoch, tab, sectionEpoch)) return;
      _setThreadSection(
        tab,
        PublicUserContentSection(
          phase: PublicUserContentPhase.ready,
          items: mergeUniqueBy(
            section.items,
            page.items,
            keyOf: (item) => item.id,
          ),
          cursor: page.cursor,
          hasMore: page.hasMore,
        ),
      );
    } on ApiFailure catch (failure) {
      if (!_isSectionCurrent(epoch, tab, sectionEpoch)) return;
      if (failure.isInvalidCursor) {
        await _loadThreadTab(tab, epoch);
        return;
      }
      _setThreadSection(
        tab,
        PublicUserContentSection(
          phase: section.phase,
          items: section.items,
          cursor: section.cursor,
          hasMore: section.hasMore,
          failure: failure,
        ),
      );
    } on Object catch (error) {
      if (!_isSectionCurrent(epoch, tab, sectionEpoch)) return;
      _setThreadSection(
        tab,
        PublicUserContentSection(
          phase: section.phase,
          items: section.items,
          cursor: section.cursor,
          hasMore: section.hasMore,
          failure: _asFailure(error, '加载更多用户内容失败，请重试。'),
        ),
      );
    }
  }

  Future<void> _loadTab(PublicUserContentTab tab, int profileEpoch) {
    if (tab == PublicUserContentTab.replies) {
      return _loadReplies(profileEpoch);
    }
    return _loadThreadTab(tab, profileEpoch);
  }

  Future<void> _loadActivitySummary(int profileEpoch) async {
    state = state.copyWith(
      activityPhase: PublicUserActivityPhase.loading,
      activityFailure: null,
    );
    try {
      final summary = await _repository.fetchActivitySummary(userId);
      if (!_isProfileCurrent(profileEpoch)) return;
      state = state.copyWith(
        activityPhase: PublicUserActivityPhase.ready,
        activitySummary: summary,
        activityFailure: null,
      );
    } on Object catch (error) {
      if (!_isProfileCurrent(profileEpoch)) return;
      state = state.copyWith(
        activityPhase: PublicUserActivityPhase.failed,
        activityFailure: _asFailure(error, '创作活动汇总没有加载完成，请稍后重试。'),
      );
    }
  }

  Future<void> _loadThreadTab(
    PublicUserContentTab tab,
    int profileEpoch,
  ) async {
    final sectionEpoch = _nextSectionEpoch(tab);
    _setThreadSection(
      tab,
      const PublicUserContentSection(phase: PublicUserContentPhase.loading),
    );
    try {
      final page = await _fetchThreadPage(tab);
      if (!_isSectionCurrent(profileEpoch, tab, sectionEpoch)) return;
      _setThreadSection(
        tab,
        PublicUserContentSection(
          phase: PublicUserContentPhase.ready,
          items: page.items,
          cursor: page.cursor,
          hasMore: page.hasMore,
        ),
      );
    } on Object catch (error) {
      if (!_isSectionCurrent(profileEpoch, tab, sectionEpoch)) return;
      _setThreadSection(
        tab,
        PublicUserContentSection(
          phase: PublicUserContentPhase.failed,
          failure: _asFailure(error, _failureMessage(tab)),
        ),
      );
    }
  }

  Future<void> _loadReplies(int profileEpoch) async {
    const tab = PublicUserContentTab.replies;
    final sectionEpoch = _nextSectionEpoch(tab);
    state = state.copyWith(
      replies: const PublicUserContentSection(
        phase: PublicUserContentPhase.loading,
      ),
    );
    try {
      final items = await _repository.fetchRecentReplies(userId);
      if (!_isSectionCurrent(profileEpoch, tab, sectionEpoch)) return;
      state = state.copyWith(
        replies: PublicUserContentSection(
          phase: PublicUserContentPhase.ready,
          items: items,
        ),
      );
    } on Object catch (error) {
      if (!_isSectionCurrent(profileEpoch, tab, sectionEpoch)) return;
      state = state.copyWith(
        replies: PublicUserContentSection(
          phase: PublicUserContentPhase.failed,
          failure: _asFailure(error, _failureMessage(tab)),
        ),
      );
    }
  }

  Future<CursorPage<PublicUserThreadModel>> _fetchThreadPage(
    PublicUserContentTab tab, {
    String? cursor,
  }) {
    return switch (tab) {
      PublicUserContentTab.created => _repository.fetchCreatedThreads(
        userId,
        cursor: cursor,
      ),
      PublicUserContentTab.played => _repository.fetchPlayedThreads(
        userId,
        cursor: cursor,
      ),
      PublicUserContentTab.bookmarks => _repository.fetchBookmarks(
        userId,
        cursor: cursor,
      ),
      PublicUserContentTab.replies => throw StateError('回复列表不使用游标分页'),
    };
  }

  PublicUserContentPhase _sectionPhase(PublicUserContentTab tab) {
    return switch (tab) {
      PublicUserContentTab.created => state.created.phase,
      PublicUserContentTab.played => state.played.phase,
      PublicUserContentTab.replies => state.replies.phase,
      PublicUserContentTab.bookmarks => state.bookmarks.phase,
    };
  }

  PublicUserContentSection<PublicUserThreadModel> _threadSection(
    PublicUserContentTab tab,
  ) {
    return switch (tab) {
      PublicUserContentTab.created => state.created,
      PublicUserContentTab.played => state.played,
      PublicUserContentTab.bookmarks => state.bookmarks,
      PublicUserContentTab.replies => throw StateError('回复列表不是主题列表'),
    };
  }

  void _setThreadSection(
    PublicUserContentTab tab,
    PublicUserContentSection<PublicUserThreadModel> section,
  ) {
    state = switch (tab) {
      PublicUserContentTab.created => state.copyWith(created: section),
      PublicUserContentTab.played => state.copyWith(played: section),
      PublicUserContentTab.bookmarks => state.copyWith(bookmarks: section),
      PublicUserContentTab.replies => throw StateError('回复列表不是主题列表'),
    };
  }

  int _nextSectionEpoch(PublicUserContentTab tab) {
    final next = (_sectionEpochs[tab] ?? 0) + 1;
    _sectionEpochs[tab] = next;
    return next;
  }

  bool _isProfileCurrent(int epoch) => mounted && epoch == _profileEpoch;

  bool _isSectionCurrent(
    int profileEpoch,
    PublicUserContentTab tab,
    int sectionEpoch,
  ) {
    return _isProfileCurrent(profileEpoch) &&
        _sectionEpochs[tab] == sectionEpoch;
  }

  ApiFailure _asFailure(Object error, String message) {
    return mapApplicationFailure(error, message);
  }

  String _failureMessage(PublicUserContentTab tab) => switch (tab) {
    PublicUserContentTab.created => '创建的主题没有加载完成，请稍后重试。',
    PublicUserContentTab.played => '参与的主题没有加载完成，请稍后重试。',
    PublicUserContentTab.replies => '最近回复没有加载完成，请稍后重试。',
    PublicUserContentTab.bookmarks => '收藏主题没有加载完成，请稍后重试。',
  };
}

final publicUserControllerProvider = StateNotifierProvider.autoDispose
    .family<PublicUserController, PublicUserState, String>((ref, userId) {
      return PublicUserController(
        ref.watch(publicUserRepositoryProvider),
        userId,
      );
    }, dependencies: [publicUserRepositoryProvider]);
