// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_folder_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BookmarkFolderResponseDto extends BookmarkFolderResponseDto {
  @override
  final String id;
  @override
  final String name;
  @override
  final bool isDefault;
  @override
  final num bookmarkCount;
  @override
  final DateTime createdAt;

  factory _$BookmarkFolderResponseDto([
    void Function(BookmarkFolderResponseDtoBuilder)? updates,
  ]) => (BookmarkFolderResponseDtoBuilder()..update(updates))._build();

  _$BookmarkFolderResponseDto._({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.bookmarkCount,
    required this.createdAt,
  }) : super._();
  @override
  BookmarkFolderResponseDto rebuild(
    void Function(BookmarkFolderResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarkFolderResponseDtoBuilder toBuilder() =>
      BookmarkFolderResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarkFolderResponseDto &&
        id == other.id &&
        name == other.name &&
        isDefault == other.isDefault &&
        bookmarkCount == other.bookmarkCount &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, isDefault.hashCode);
    _$hash = $jc(_$hash, bookmarkCount.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BookmarkFolderResponseDto')
          ..add('id', id)
          ..add('name', name)
          ..add('isDefault', isDefault)
          ..add('bookmarkCount', bookmarkCount)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class BookmarkFolderResponseDtoBuilder
    implements
        Builder<BookmarkFolderResponseDto, BookmarkFolderResponseDtoBuilder> {
  _$BookmarkFolderResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _isDefault;
  bool? get isDefault => _$this._isDefault;
  set isDefault(bool? isDefault) => _$this._isDefault = isDefault;

  num? _bookmarkCount;
  num? get bookmarkCount => _$this._bookmarkCount;
  set bookmarkCount(num? bookmarkCount) =>
      _$this._bookmarkCount = bookmarkCount;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  BookmarkFolderResponseDtoBuilder() {
    BookmarkFolderResponseDto._defaults(this);
  }

  BookmarkFolderResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _isDefault = $v.isDefault;
      _bookmarkCount = $v.bookmarkCount;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BookmarkFolderResponseDto other) {
    _$v = other as _$BookmarkFolderResponseDto;
  }

  @override
  void update(void Function(BookmarkFolderResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarkFolderResponseDto build() => _build();

  _$BookmarkFolderResponseDto _build() {
    final _$result =
        _$v ??
        _$BookmarkFolderResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'BookmarkFolderResponseDto',
            'id',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'BookmarkFolderResponseDto',
            'name',
          ),
          isDefault: BuiltValueNullFieldError.checkNotNull(
            isDefault,
            r'BookmarkFolderResponseDto',
            'isDefault',
          ),
          bookmarkCount: BuiltValueNullFieldError.checkNotNull(
            bookmarkCount,
            r'BookmarkFolderResponseDto',
            'bookmarkCount',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'BookmarkFolderResponseDto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
