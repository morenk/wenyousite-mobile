// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DraftResponseDto extends DraftResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final num slot;
  @override
  final String content;
  @override
  final num version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$DraftResponseDto([
    void Function(DraftResponseDtoBuilder)? updates,
  ]) => (DraftResponseDtoBuilder()..update(updates))._build();

  _$DraftResponseDto._({
    required this.id,
    required this.userId,
    required this.slot,
    required this.content,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();
  @override
  DraftResponseDto rebuild(void Function(DraftResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DraftResponseDtoBuilder toBuilder() =>
      DraftResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftResponseDto &&
        id == other.id &&
        userId == other.userId &&
        slot == other.slot &&
        content == other.content &&
        version == other.version &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DraftResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('slot', slot)
          ..add('content', content)
          ..add('version', version)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class DraftResponseDtoBuilder
    implements Builder<DraftResponseDto, DraftResponseDtoBuilder> {
  _$DraftResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  num? _slot;
  num? get slot => _$this._slot;
  set slot(num? slot) => _$this._slot = slot;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DraftResponseDtoBuilder() {
    DraftResponseDto._defaults(this);
  }

  DraftResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _slot = $v.slot;
      _content = $v.content;
      _version = $v.version;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DraftResponseDto other) {
    _$v = other as _$DraftResponseDto;
  }

  @override
  void update(void Function(DraftResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftResponseDto build() => _build();

  _$DraftResponseDto _build() {
    final _$result =
        _$v ??
        _$DraftResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'DraftResponseDto',
            'id',
          ),
          userId: BuiltValueNullFieldError.checkNotNull(
            userId,
            r'DraftResponseDto',
            'userId',
          ),
          slot: BuiltValueNullFieldError.checkNotNull(
            slot,
            r'DraftResponseDto',
            'slot',
          ),
          content: BuiltValueNullFieldError.checkNotNull(
            content,
            r'DraftResponseDto',
            'content',
          ),
          version: BuiltValueNullFieldError.checkNotNull(
            version,
            r'DraftResponseDto',
            'version',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'DraftResponseDto',
            'createdAt',
          ),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
            updatedAt,
            r'DraftResponseDto',
            'updatedAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
