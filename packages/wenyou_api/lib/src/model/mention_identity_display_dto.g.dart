// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mention_identity_display_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MentionIdentityDisplayDto extends MentionIdentityDisplayDto {
  @override
  final String? sourceHref;
  @override
  final String? targetIdentityId;
  @override
  final String? threadId;
  @override
  final String userId;
  @override
  final String label;
  @override
  final String displayName;
  @override
  final String? identityId;

  factory _$MentionIdentityDisplayDto([
    void Function(MentionIdentityDisplayDtoBuilder)? updates,
  ]) => (MentionIdentityDisplayDtoBuilder()..update(updates))._build();

  _$MentionIdentityDisplayDto._({
    this.sourceHref,
    this.targetIdentityId,
    this.threadId,
    required this.userId,
    required this.label,
    required this.displayName,
    this.identityId,
  }) : super._();
  @override
  MentionIdentityDisplayDto rebuild(
    void Function(MentionIdentityDisplayDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MentionIdentityDisplayDtoBuilder toBuilder() =>
      MentionIdentityDisplayDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MentionIdentityDisplayDto &&
        sourceHref == other.sourceHref &&
        targetIdentityId == other.targetIdentityId &&
        threadId == other.threadId &&
        userId == other.userId &&
        label == other.label &&
        displayName == other.displayName &&
        identityId == other.identityId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sourceHref.hashCode);
    _$hash = $jc(_$hash, targetIdentityId.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, identityId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MentionIdentityDisplayDto')
          ..add('sourceHref', sourceHref)
          ..add('targetIdentityId', targetIdentityId)
          ..add('threadId', threadId)
          ..add('userId', userId)
          ..add('label', label)
          ..add('displayName', displayName)
          ..add('identityId', identityId))
        .toString();
  }
}

class MentionIdentityDisplayDtoBuilder
    implements
        Builder<MentionIdentityDisplayDto, MentionIdentityDisplayDtoBuilder> {
  _$MentionIdentityDisplayDto? _$v;

  String? _sourceHref;
  String? get sourceHref => _$this._sourceHref;
  set sourceHref(String? sourceHref) => _$this._sourceHref = sourceHref;

  String? _targetIdentityId;
  String? get targetIdentityId => _$this._targetIdentityId;
  set targetIdentityId(String? targetIdentityId) =>
      _$this._targetIdentityId = targetIdentityId;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _identityId;
  String? get identityId => _$this._identityId;
  set identityId(String? identityId) => _$this._identityId = identityId;

  MentionIdentityDisplayDtoBuilder() {
    MentionIdentityDisplayDto._defaults(this);
  }

  MentionIdentityDisplayDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sourceHref = $v.sourceHref;
      _targetIdentityId = $v.targetIdentityId;
      _threadId = $v.threadId;
      _userId = $v.userId;
      _label = $v.label;
      _displayName = $v.displayName;
      _identityId = $v.identityId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MentionIdentityDisplayDto other) {
    _$v = other as _$MentionIdentityDisplayDto;
  }

  @override
  void update(void Function(MentionIdentityDisplayDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MentionIdentityDisplayDto build() => _build();

  _$MentionIdentityDisplayDto _build() {
    final _$result =
        _$v ??
        _$MentionIdentityDisplayDto._(
          sourceHref: sourceHref,
          targetIdentityId: targetIdentityId,
          threadId: threadId,
          userId: BuiltValueNullFieldError.checkNotNull(
            userId,
            r'MentionIdentityDisplayDto',
            'userId',
          ),
          label: BuiltValueNullFieldError.checkNotNull(
            label,
            r'MentionIdentityDisplayDto',
            'label',
          ),
          displayName: BuiltValueNullFieldError.checkNotNull(
            displayName,
            r'MentionIdentityDisplayDto',
            'displayName',
          ),
          identityId: identityId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
