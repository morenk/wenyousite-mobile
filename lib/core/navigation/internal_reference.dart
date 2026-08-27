const internalReferenceDefaultLabel = '传送门';
const internalReferenceProductionOrigin = 'https://wenyou.site';

enum InternalReferenceKind {
  thread,
  subthread,
  floor,
  discussion,
  reply,
  invite,
}

class InternalReference {
  const InternalReference({required this.kind, required this.location});

  final InternalReferenceKind kind;
  final Uri location;
}

class InternalReferencePaste {
  const InternalReferencePaste({required this.label, required this.reference});

  final String label;
  final InternalReference reference;

  String get serialized =>
      '[${_escapeInternalReferenceLabel(label)}](${reference.location})';
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

class InternalReferencePortalMatch {
  const InternalReferencePortalMatch({
    required this.start,
    required this.end,
    required this.portal,
  });

  final int start;
  final int end;
  final InternalReferencePortal portal;
}

final _idPattern = RegExp(r'^[a-z0-9]{20,32}$', unicode: true);
final _inviteTokenPattern = RegExp(r'^[A-Za-z0-9_-]{16}$', unicode: true);
final _threadPathPattern = RegExp(r'^/threads/([^/]+)$', unicode: true);
final _discussionPathPattern = RegExp(
  r'^/threads/([^/]+)/posts/([^/]+)/replies$',
  unicode: true,
);
final _invitePathPattern = RegExp(r'^/join/([^/]+)$', unicode: true);
final _candidatePattern = RegExp(
  r'\[((?:\\[\\\[\]]|[^\[\]\\\r\n])+)\]\(([^)\r\n]+)\)|https://(?:www\.)?wenyou\.site/(?:threads/[a-z0-9_-]+(?:/posts/[a-z0-9_-]+/replies)?|join/[a-z0-9_-]+)(?:\?[^\s<>\])}.,!;:，。！？；：、]+)?|/(?:threads/[a-z0-9_-]+(?:/posts/[a-z0-9_-]+/replies)?|join/[a-z0-9_-]+)(?:\?[^\s<>\])}.,!;:，。！？；：、]+)?',
  caseSensitive: false,
  unicode: true,
);
final _trailingPunctuationPattern = RegExp(r'[.,!?;:，。！？；：、]+$', unicode: true);
final _bareLeftBoundaryPattern = RegExp(
  r'''[\s([{\u0022'，。！？；：、]''',
  unicode: true,
);
final _bareRightBoundaryPattern = RegExp(
  r'''[\s)\]}\u0022'.,!?;:，。！？；：、]''',
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
          !_isProductionHost(uri.host) ||
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
    if (postId != null) {
      if (!_hasOnlyQueries(uri, {
            'post',
            if (subthreadId != null) 'subthread',
          }) ||
          !_idPattern.hasMatch(postId) ||
          (subthreadId != null && !_idPattern.hasMatch(subthreadId))) {
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
    if (subthreadId != null) {
      if (!_hasOnlyQueries(uri, {'subthread'}) ||
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
    if (!_hasOnlyQuery(uri, null)) return null;
    return InternalReference(
      kind: InternalReferenceKind.thread,
      location: Uri(path: '/threads/$threadId'),
    );
  }

  final inviteMatch = _invitePathPattern.firstMatch(uri.path);
  if (inviteMatch != null) {
    final token = _decodedInviteToken(inviteMatch.group(1));
    if (token == null || !_hasOnlyQuery(uri, null)) return null;
    return InternalReference(
      kind: InternalReferenceKind.invite,
      location: Uri(path: '/join/$token'),
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

/// Resolves the editor's whole-clipboard paste contract shared with Web.
///
/// Only a clipboard value that consists entirely of one legal internal URL is
/// handled. Existing selected text becomes its label; otherwise the Foundation
/// default label is used. Everything else falls through to Quill's normal paste.
InternalReferencePaste? resolveInternalReferencePaste({
  required String clipboardText,
  required String selectedText,
}) {
  final reference = parseInternalReference(clipboardText.trim());
  if (reference == null) return null;
  final selectedLabel = selectedText.trim();
  final candidateLabel = selectedLabel.isEmpty
      ? internalReferenceDefaultLabel
      : selectedLabel;
  final label = resolveInternalReferenceLabel(
    label: candidateLabel,
    reference: reference,
  );
  if (label.contains('\n') || label.contains('\r')) {
    return null;
  }
  return InternalReferencePaste(label: label, reference: reference);
}

/// Returns the effective label for displaying or creating an internal
/// reference. Existing persisted source remains untouched by this resolver.
///
/// Older editor input paths could save a copied internal URL as both the
/// Markdown label and target. Treat that self-label as the default portal
/// label while preserving every genuine custom name.
String resolveInternalReferenceLabel({
  required String label,
  required InternalReference reference,
}) {
  final candidate = label.trim();
  if (candidate.isEmpty) return internalReferenceDefaultLabel;
  final labelReference = parseInternalReference(candidate);
  if (labelReference != null &&
      labelReference.kind == reference.kind &&
      labelReference.location.toString() == reference.location.toString()) {
    return internalReferenceDefaultLabel;
  }
  return label;
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
    final resolved = _resolveInternalReferenceCandidate(value, match);
    if (resolved == null) {
      segments.add(InternalReferencePlainText(match.group(0)!));
    } else {
      segments.add(resolved.portal);
      if (resolved.trailing.isNotEmpty) {
        segments.add(InternalReferencePlainText(resolved.trailing));
      }
    }
    offset = match.end;
  }
  if (offset < value.length) {
    segments.add(InternalReferencePlainText(value.substring(offset)));
  }
  return segments.isEmpty ? [InternalReferencePlainText(value)] : segments;
}

/// Resolves one portal beginning exactly at [offset].
///
/// Markdown renderers and clipboard projections use this to share the same
/// production-host, boundary, label and trailing-punctuation rules without
/// reimplementing the internal-reference contract.
InternalReferencePortalMatch? matchInternalReferencePortalAt(
  String value,
  int offset,
) {
  if (offset < 0 || offset >= value.length) return null;
  if (offset > 0 && (value[offset - 1] == '!' || value[offset - 1] == r'\')) {
    return null;
  }
  final match = _candidatePattern.matchAsPrefix(value, offset);
  if (match == null) return null;
  final resolved = _resolveInternalReferenceCandidate(value, match);
  if (resolved == null) return null;
  return InternalReferencePortalMatch(
    start: match.start,
    end: match.end - resolved.trailing.length,
    portal: resolved.portal,
  );
}

String formatInternalReferencePreview(String value) {
  return tokenizeInternalReferenceText(value).map((segment) {
    return switch (segment) {
      InternalReferencePlainText(:final value) => value,
      InternalReferencePortal(:final label) => label,
    };
  }).join();
}

({InternalReferencePortal portal, String trailing})?
_resolveInternalReferenceCandidate(String source, Match match) {
  final candidate = match.group(0)!;
  final rawLabel = match.group(1)?.trim();
  final label = rawLabel == null
      ? null
      : _unescapeInternalReferenceLabel(rawLabel);
  final markdownLocation = match.group(2)?.trim();
  final trailing = markdownLocation == null
      ? _trailingPunctuationPattern.firstMatch(candidate)?.group(0) ?? ''
      : '';
  final location =
      markdownLocation ??
      (trailing.isEmpty
          ? candidate
          : candidate.substring(0, candidate.length - trailing.length));
  final hasBareBoundaries =
      markdownLocation != null ||
      _hasBareBoundaries(source, match.start, match.end);
  final reference = hasBareBoundaries ? parseInternalReference(location) : null;
  if (reference == null) return null;
  final candidateLabel = label?.isNotEmpty == true
      ? label!
      : internalReferenceDefaultLabel;
  return (
    portal: InternalReferencePortal(
      label: resolveInternalReferenceLabel(
        label: candidateLabel,
        reference: reference,
      ),
      reference: reference,
    ),
    trailing: trailing,
  );
}

bool _isProductionHost(String host) {
  final normalized = host.toLowerCase();
  return normalized == 'wenyou.site' || normalized == 'www.wenyou.site';
}

bool _hasBareBoundaries(String source, int start, int end) {
  if (start > 0 && !_bareLeftBoundaryPattern.hasMatch(source[start - 1])) {
    return false;
  }
  if (end < source.length && !_bareRightBoundaryPattern.hasMatch(source[end])) {
    return false;
  }
  return true;
}

String _escapeInternalReferenceLabel(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll('[', r'\[')
      .replaceAll(']', r'\]');
}

String _unescapeInternalReferenceLabel(String value) {
  final output = StringBuffer();
  for (var index = 0; index < value.length; index++) {
    final character = value[index];
    if (character == r'\' && index + 1 < value.length) {
      final escaped = value[index + 1];
      if (escaped == r'\' || escaped == '[' || escaped == ']') {
        output.write(escaped);
        index += 1;
        continue;
      }
    }
    output.write(character);
  }
  return output.toString();
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

String? _decodedInviteToken(String? value) {
  if (value == null) return null;
  try {
    final decoded = Uri.decodeComponent(value);
    return _inviteTokenPattern.hasMatch(decoded) ? decoded : null;
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

bool _hasOnlyQueries(Uri uri, Set<String> allowed) {
  return uri.queryParametersAll.length == allowed.length &&
      uri.queryParametersAll.entries.every(
        (entry) => allowed.contains(entry.key) && entry.value.length == 1,
      );
}
