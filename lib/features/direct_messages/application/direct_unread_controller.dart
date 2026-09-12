import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_repository_ports.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_states.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

class DirectUnreadController extends StateNotifier<DirectUnreadState> {
  DirectUnreadController(this._repository, {bool autoStart = true})
    : super(const DirectUnreadState()) {
    if (autoStart) unawaited(refresh());
  }

  final DirectMessageRepository _repository;
  final Set<String> _reading = {};
  var _epoch = 0;

  /// 返回只结算一次的回调；阅读消息不会接受请求，不能扣减请求角标。
  void Function(bool) beginRead(DirectConversation conversation) {
    if (!mounted || !_reading.add(conversation.id)) return (_) {};
    ++_epoch;
    final counts = state.counts;
    final amount = conversation.status == DirectConversationStatus.accepted
        ? conversation.unreadCount.clamp(0, counts.unreadMessages)
        : 0;
    state = DirectUnreadState(
      counts: DirectUnreadCounts(
        unreadMessages: counts.unreadMessages - amount,
        pendingRequests: counts.pendingRequests,
      ),
    );
    var settled = false;
    return (succeeded) {
      if (!mounted || settled) return;
      settled = true;
      _reading.remove(conversation.id);
      if (!succeeded) {
        state = DirectUnreadState(
          counts: DirectUnreadCounts(
            unreadMessages: state.counts.unreadMessages + amount,
            pendingRequests: state.counts.pendingRequests,
          ),
        );
      }
      if (_reading.isEmpty) unawaited(refresh());
    };
  }

  Future<void> refresh() async {
    if (!mounted || state.isLoading || _reading.isNotEmpty) return;
    final epoch = ++_epoch;
    state = DirectUnreadState(counts: state.counts, isLoading: true);
    try {
      final counts = await _repository.fetchUnreadCounts();
      if (!mounted || epoch != _epoch) return;
      state = DirectUnreadState(counts: counts);
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = DirectUnreadState(
        counts: state.counts,
        failure: mapApplicationFailure(error, '私聊未读数同步失败。'),
      );
    }
  }
}
