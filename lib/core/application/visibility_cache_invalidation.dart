import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';

/// Content readers follow this revision; unsent editor drafts do not.
class ContentVisibilityRevision extends Notifier<int> {
  @override
  int build() => 0;

  void advance() => state += 1;
}

final contentVisibilityRevisionProvider =
    NotifierProvider<ContentVisibilityRevision, int>(
      ContentVisibilityRevision.new,
    );

typedef ViewerScope = ({SessionScope session, int visibilityRevision});

/// Access-token rotation preserves the viewer. Login/logout or a visibility
/// mutation replaces cached projections before another reader can reuse them.
final viewerScopeProvider = Provider<ViewerScope>(
  (ref) => (
    session: ref.watch(sessionScopeProvider),
    visibilityRevision: ref.watch(contentVisibilityRevisionProvider),
  ),
);

final visibilityCacheInvalidatorProvider = Provider<void Function()>(
  (ref) =>
      () => ref.read(contentVisibilityRevisionProvider.notifier).advance(),
);
