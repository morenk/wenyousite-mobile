import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum PublicUserContentPhase { idle, loading, ready, failed }

class PublicUserContentSection<T> {
  const PublicUserContentSection({
    this.phase = PublicUserContentPhase.idle,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final PublicUserContentPhase phase;
  final List<T> items;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingMore;
  final ApiFailure? failure;
}
