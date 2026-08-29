// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latest_thread_post_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LatestThreadPostResponseDto extends LatestThreadPostResponseDto {
  @override
  final String id;
  @override
  final String threadId;
  @override
  final String subthreadId;
  @override
  final String? parentPostId;
  @override
  final DateTime createdAt;

  factory _$LatestThreadPostResponseDto([
    void Function(LatestThreadPostResponseDtoBuilder)? updates,
  ]) => (LatestThreadPostResponseDtoBuilder()..update(updates))._build();

  _$LatestThreadPostResponseDto._({
    required this.id,
    required this.threadId,
    required this.subthreadId,
    this.parentPostId,
    required this.createdAt,
  }) : super._();
  @override
  LatestThreadPostResponseDto rebuild(
    void Function(LatestThreadPostResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  LatestThreadPostResponseDtoBuilder toBuilder() =>
      LatestThreadPostResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LatestThreadPostResponseDto &&
        id == other.id &&
        threadId == other.threadId &&
        subthreadId == other.subthreadId &&
        parentPostId == other.parentPostId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, subthreadId.hashCode);
    _$hash = $jc(_$hash, parentPostId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LatestThreadPostResponseDto')
          ..add('id', id)
          ..add('threadId', threadId)
          ..add('subthreadId', subthreadId)
          ..add('parentPostId', parentPostId)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class LatestThreadPostResponseDtoBuilder
    implements
        Builder<
          LatestThreadPostResponseDto,
          LatestThreadPostResponseDtoBuilder
        > {
  _$LatestThreadPostResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _subthreadId;
  String? get subthreadId => _$this._subthreadId;
  set subthreadId(String? subthreadId) => _$this._subthreadId = subthreadId;

  String? _parentPostId;
  String? get parentPostId => _$this._parentPostId;
  set parentPostId(String? parentPostId) => _$this._parentPostId = parentPostId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  LatestThreadPostResponseDtoBuilder() {
    LatestThreadPostResponseDto._defaults(this);
  }

  LatestThreadPostResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _threadId = $v.threadId;
      _subthreadId = $v.subthreadId;
      _parentPostId = $v.parentPostId;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LatestThreadPostResponseDto other) {
    _$v = other as _$LatestThreadPostResponseDto;
  }

  @override
  void update(void Function(LatestThreadPostResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LatestThreadPostResponseDto build() => _build();

  _$LatestThreadPostResponseDto _build() {
    final _$result =
        _$v ??
        _$LatestThreadPostResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'LatestThreadPostResponseDto',
            'id',
          ),
          threadId: BuiltValueNullFieldError.checkNotNull(
            threadId,
            r'LatestThreadPostResponseDto',
            'threadId',
          ),
          subthreadId: BuiltValueNullFieldError.checkNotNull(
            subthreadId,
            r'LatestThreadPostResponseDto',
            'subthreadId',
          ),
          parentPostId: parentPostId,
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'LatestThreadPostResponseDto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
