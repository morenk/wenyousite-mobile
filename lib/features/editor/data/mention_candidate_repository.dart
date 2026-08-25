import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/editor/application/mention_candidate_repository_ports.dart';
import 'package:wenyousite_mobile/features/editor/domain/mention_models.dart';

export 'package:wenyousite_mobile/features/editor/application/mention_candidate_repository_ports.dart'
    show MentionCandidateRepository, mentionCandidateRepositoryProvider;

class ApiMentionCandidateRepository implements MentionCandidateRepository {
  ApiMentionCandidateRepository(this._api);

  final UsersApi _api;

  static final _stableId = RegExp(r'^[A-Za-z0-9_-]+$');
  static final _username = RegExp(r'^[A-Za-z0-9\u4e00-\u9fff]{2,24}$');

  @override
  Future<MentionCandidatesResult> findCandidates({
    required String threadId,
    required String query,
  }) async {
    final normalizedThreadId = threadId.trim();
    final normalizedQuery = query.trim();
    if (normalizedThreadId.isEmpty) {
      throw const ApiFailure(userMessage: '缺少主题上下文，暂时无法加载可提及用户。');
    }
    try {
      final response = await _api.usersMentionCandidates(
        threadId: normalizedThreadId,
        q: normalizedQuery.isEmpty ? null : normalizedQuery,
      );
      final data = response.data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '可提及用户加载失败，请稍后重试。');
      }
      final seen = <String>{};
      final users = <MentionCandidate>[];
      for (final candidate in data.users) {
        final relation = switch (candidate.relation) {
          MentionCandidateDtoRelationEnum.FOLLOWING =>
            MentionCandidateRelation.following,
          MentionCandidateDtoRelationEnum.PLAYER =>
            MentionCandidateRelation.player,
          _ => null,
        };
        if (relation == null ||
            !_stableId.hasMatch(candidate.id) ||
            !_username.hasMatch(candidate.username) ||
            !seen.add(candidate.id)) {
          continue;
        }
        users.add(
          MentionCandidate(
            id: candidate.id,
            username: candidate.username,
            relation: relation,
          ),
        );
      }
      return MentionCandidatesResult(
        users: List.unmodifiable(users.take(20)),
        canMentionAllPlayers: data.canMentionAllPlayers,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final apiMentionCandidateRepositoryProvider =
    Provider<MentionCandidateRepository>(
      (ref) => ApiMentionCandidateRepository(
        ref.watch(wenyouApiProvider).getUsersApi(),
      ),
    );
