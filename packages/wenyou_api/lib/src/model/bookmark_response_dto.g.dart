// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BookmarkResponseDto extends BookmarkResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String threadId;
  @override
  final String folderId;
  @override
  final DateTime createdAt;

  factory _$BookmarkResponseDto([
    void Function(BookmarkResponseDtoBuilder)? updates,
  ]) => (BookmarkResponseDtoBuilder()..update(updates))._build();

  _$BookmarkResponseDto._({
    required this.id,
    required this.userId,
    required this.threadId,
    required this.folderId,
    required this.createdAt,
  }) : super._();
  @override
  BookmarkResponseDto rebuild(
    void Function(BookmarkResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarkResponseDtoBuilder toBuilder() =>
      BookmarkResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarkResponseDto &&
        id == other.id &&
        userId == other.userId &&
        threadId == other.threadId &&
        folderId == other.folderId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, folderId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BookmarkResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('threadId', threadId)
          ..add('folderId', folderId)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class BookmarkResponseDtoBuilder
    implements Builder<BookmarkResponseDto, BookmarkResponseDtoBuilder> {
  _$BookmarkResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _folderId;
  String? get folderId => _$this._folderId;
  set folderId(String? folderId) => _$this._folderId = folderId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  BookmarkResponseDtoBuilder() {
    BookmarkResponseDto._defaults(this);
  }

  BookmarkResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _threadId = $v.threadId;
      _folderId = $v.folderId;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BookmarkResponseDto other) {
    _$v = other as _$BookmarkResponseDto;
  }

  @override
  void update(void Function(BookmarkResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarkResponseDto build() => _build();

  _$BookmarkResponseDto _build() {
    final _$result =
        _$v ??
        _$BookmarkResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'BookmarkResponseDto',
            'id',
          ),
          userId: BuiltValueNullFieldError.checkNotNull(
            userId,
            r'BookmarkResponseDto',
            'userId',
          ),
          threadId: BuiltValueNullFieldError.checkNotNull(
            threadId,
            r'BookmarkResponseDto',
            'threadId',
          ),
          folderId: BuiltValueNullFieldError.checkNotNull(
            folderId,
            r'BookmarkResponseDto',
            'folderId',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'BookmarkResponseDto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
