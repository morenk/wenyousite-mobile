import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef DiscussionAuthorFilterSnapshot<Author> = ({
  String? selectedAuthorId,
  AsyncValue<List<Author>> authors,
});

class DiscussionAuthorFilterRestoreCoordinator<Author> {
  DiscussionAuthorFilterRestoreCoordinator({required this.authorIdOf});

  final String Function(Author author) authorIdOf;
  String? _pendingSignature;

  void scheduleIfMissing({
    required String? scopeId,
    required String? selectedAuthorId,
    required AsyncValue<List<Author>> authors,
    required DiscussionAuthorFilterSnapshot<Author> Function() readCurrent,
    required Future<void> Function() clearAuthor,
    required bool Function() isMounted,
  }) {
    final loadedAuthors = authors.valueOrNull;
    if (scopeId == null ||
        selectedAuthorId == null ||
        authors.isLoading ||
        authors.hasError ||
        loadedAuthors == null ||
        _containsAuthor(loadedAuthors, selectedAuthorId)) {
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
          _containsAuthor(currentValues, selectedAuthorId)) {
        _release(signature);
        return;
      }
      await clearAuthor();
      _release(signature);
    });
  }

  bool _containsAuthor(List<Author> authors, String selectedAuthorId) {
    return authors.any((author) => authorIdOf(author) == selectedAuthorId);
  }

  void _release(String signature) {
    if (_pendingSignature == signature) _pendingSignature = null;
  }
}
