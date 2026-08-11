const internalReferenceDefaultLabel = '传送门';
const internalReferenceProductionOrigin = 'https://wenyou.site';

enum InternalReferenceKind { thread, subthread, floor, discussion, reply }

class InternalReference {
  const InternalReference({required this.kind, required this.location});

  final InternalReferenceKind kind;
  final Uri location;
}

sealed class InternalReferenceTextSegment {
  const InternalReferenceTextSegment();
}

class InternalReferencePlainText extends InternalReferenceTextSegment {
  const InternalReferencePlainText(this.value);

  final String value;
}

class InternalReferencePortal extends InternalReferenceTextSegment {
  const InternalReferencePortal({required this.label, required this.reference});

  final String label;
  final InternalReference reference;
}

final _idPattern = RegExp(r'^[a-z0-9]{20,32}$', unicode: true);
final _threadPathPattern = RegExp(r'^/threads/([^/]+)$', unicode: true);
final _discussionPathPattern = RegExp(
  r'^/threads/([^/]+)/posts/([^/]+)/replies$',
  unicode: true,
);
final _candidatePattern = RegExp(
  r'\[([^\]\r\n]+)\]\(([^)\r\n]+)\)|https://wenyou\.site/threads/[a-z0-9_-]+(?:/posts/[a-z0-9_-]+/replies)?(?:\?[^\s<>\])}.,!;:，。！？；：、]+)?|/threads/[a-z0-9_-]+(?:/posts/[a-z0-9_-]+/replies)?(?:\?[^\s<>\])}.,!;:，。！？；：、]+)?',
  caseSensitive: false,
  unicode: true,
);
final _trailingPunctuationPattern = RegExp(r'[.,!?;:，。！？；：、]+$', unicode: true);
final _relativeBoundaryPattern = RegExp(
  r'''[\s([{\u0022'，。！？；：、]''',
  unicode: true,
);

InternalReference? parseInternalReference(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty || trimmed.contains('#')) return null;
  final relative = trimmed.startsWith('/') && !trimmed.startsWith('//');
  final Uri uri;
  try {
    uri = relative
        ? Uri.parse(trimmed)
        : Uri.parse(internalReferenceProductionOrigin).resolve(trimmed);
  } on FormatException {
    return null;
  }
  if (!relative &&
      (uri.scheme != 'https' ||
          uri.host.toLowerCase() != 'wenyou.site' ||
          (uri.hasPort && uri.port != 443) ||
          uri.userInfo.isNotEmpty)) {
    return null;
  }
  if (relative && (uri.hasScheme || uri.hasAuthority)) return null;

  final threadMatch = _threadPathPattern.firstMatch(uri.path);
  if (threadMatch != null) {
    final threadId = _decodedId(threadMatch.group(1));
    if (threadId == null) return null;
    final subthreadId = _singleQueryValue(uri, 'subthread');
    final postId = _singleQueryValue(uri, 'post');
    if (subthreadId != null) {
      if (!_hasOnlyQuery(uri, 'subthread') ||
          !_idPattern.hasMatch(subthreadId)) {
        return null;
      }
      return InternalReference(
        kind: InternalReferenceKind.subthread,
        location: Uri(
          path: '/threads/$threadId',
          queryParameters: {'subthread': subthreadId},
        ),
      );
    }
    if (postId != null) {
      if (!_hasOnlyQuery(uri, 'post') || !_idPattern.hasMatch(postId)) {
        return null;
      }
      return InternalReference(
        kind: InternalReferenceKind.floor,
        location: Uri(
          path: '/threads/$threadId',
          queryParameters: {'post': postId},
        ),
      );
    }
    if (!_hasOnlyQuery(uri, null)) return null;
    return InternalReference(
      kind: InternalReferenceKind.thread,
      location: Uri(path: '/threads/$threadId'),
    );
  }

  final discussionMatch = _discussionPathPattern.firstMatch(uri.path);
  if (discussionMatch == null) return null;
  final threadId = _decodedId(discussionMatch.group(1));
  final floorPostId = _decodedId(discussionMatch.group(2));
  if (threadId == null || floorPostId == null) return null;
  final postId = _singleQueryValue(uri, 'post');
  final path = '/threads/$threadId/posts/$floorPostId/replies';
  if (postId != null) {
    if (!_hasOnlyQuery(uri, 'post') || !_idPattern.hasMatch(postId)) {
      return null;
    }
    return InternalReference(
      kind: InternalReferenceKind.reply,
      location: Uri(path: path, queryParameters: {'post': postId}),
    );
  }
  if (!_hasOnlyQuery(uri, null)) return null;
  return InternalReference(
    kind: InternalReferenceKind.discussion,
    location: Uri(path: path),
  );
}

List<InternalReferenceTextSegment> tokenizeInternalReferenceText(String value) {
  final segments = <InternalReferenceTextSegment>[];
  var offset = 0;
  for (final match in _candidatePattern.allMatches(value)) {
    if (match.start > offset) {
      segments.add(
        InternalReferencePlainText(value.substring(offset, match.start)),
      );
    }
    final candidate = match.group(0)!;
    final label = match.group(1)?.trim();
    final markdownLocation = match.group(2)?.trim();
    final trailing = markdownLocation == null
        ? _trailingPunctuationPattern.firstMatch(candidate)?.group(0) ?? ''
        : '';
    final location =
        markdownLocation ??
        (trailing.isEmpty
            ? candidate
            : candidate.substring(0, candidate.length - trailing.length));
    final previousCharacter = match.start == 0 ? '' : value[match.start - 1];
    final hasRelativeBoundary =
        !candidate.startsWith('/') ||
        previousCharacter.isEmpty ||
        _relativeBoundaryPattern.hasMatch(previousCharacter);
    final reference = hasRelativeBoundary
        ? parseInternalReference(location)
        : null;
    if (reference == null) {
      segments.add(InternalReferencePlainText(candidate));
    } else {
      segments.add(
        InternalReferencePortal(
          label: label?.isNotEmpty == true
              ? label!
              : internalReferenceDefaultLabel,
          reference: reference,
        ),
      );
      if (trailing.isNotEmpty) {
        segments.add(InternalReferencePlainText(trailing));
      }
    }
    offset = match.end;
  }
  if (offset < value.length) {
    segments.add(InternalReferencePlainText(value.substring(offset)));
  }
  return segments.isEmpty ? [InternalReferencePlainText(value)] : segments;
}

String formatInternalReferencePreview(String value) {
  return tokenizeInternalReferenceText(value).map((segment) {
    return switch (segment) {
      InternalReferencePlainText(:final value) => value,
      InternalReferencePortal(:final label) => label,
    };
  }).join();
}

String? _decodedId(String? value) {
  if (value == null) return null;
  try {
    final decoded = Uri.decodeComponent(value);
    return _idPattern.hasMatch(decoded) ? decoded : null;
  } on FormatException {
    return null;
  }
}

String? _singleQueryValue(Uri uri, String key) {
  final values = uri.queryParametersAll[key];
  return values?.length == 1 ? values!.single : null;
}

bool _hasOnlyQuery(Uri uri, String? allowed) {
  if (allowed == null) return uri.queryParametersAll.isEmpty;
  return uri.queryParametersAll.length == 1 &&
      uri.queryParametersAll[allowed]?.length == 1;
}
