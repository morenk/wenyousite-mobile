import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';

typedef PostDiscussionAuthorSnapshot = ({
  String? selectedAuthorId,
  AsyncValue<List<PostDiscussionAuthor>> authors,
});

class PostDiscussionAuthorFilterRestoreCoordinator {
  String? _pendingSignature;

  void scheduleIfMissing({
    required String? scopeId,
    required String? selectedAuthorId,
    required AsyncValue<List<PostDiscussionAuthor>> authors,
    required PostDiscussionAuthorSnapshot Function() readCurrent,
    required Future<void> Function() clearAuthor,
    required bool Function() isMounted,
  }) {
    final loadedAuthors = authors.valueOrNull;
    if (scopeId == null ||
        selectedAuthorId == null ||
        authors.isLoading ||
        authors.hasError ||
        loadedAuthors == null ||
        loadedAuthors.any((author) => author.userId == selectedAuthorId)) {
      return;
    }
    final signature = '$scopeId:$selectedAuthorId';
    if (_pendingSignature == signature) return;
    _pendingSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!isMounted()) {
        _release(signature);
        return;
      }
      final current = readCurrent();
      final currentAuthors = current.authors;
      final currentValues = currentAuthors.valueOrNull;
      if (current.selectedAuthorId != selectedAuthorId ||
          currentAuthors.isLoading ||
          currentAuthors.hasError ||
          currentValues == null ||
          currentValues.any((author) => author.userId == selectedAuthorId)) {
        _release(signature);
        return;
      }
      await clearAuthor();
      _release(signature);
    });
  }

  void _release(String signature) {
    if (_pendingSignature == signature) _pendingSignature = null;
  }
}
