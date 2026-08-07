// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_thread_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BookmarkThreadCountResponseDto extends BookmarkThreadCountResponseDto {
  @override
  final num members;
  @override
  final num posts;

  factory _$BookmarkThreadCountResponseDto([
    void Function(BookmarkThreadCountResponseDtoBuilder)? updates,
  ]) => (BookmarkThreadCountResponseDtoBuilder()..update(updates))._build();

  _$BookmarkThreadCountResponseDto._({
    required this.members,
    required this.posts,
  }) : super._();
  @override
  BookmarkThreadCountResponseDto rebuild(
    void Function(BookmarkThreadCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarkThreadCountResponseDtoBuilder toBuilder() =>
      BookmarkThreadCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarkThreadCountResponseDto &&
        members == other.members &&
        posts == other.posts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, members.hashCode);
    _$hash = $jc(_$hash, posts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BookmarkThreadCountResponseDto')
          ..add('members', members)
          ..add('posts', posts))
        .toString();
  }
}

class BookmarkThreadCountResponseDtoBuilder
    implements
        Builder<
          BookmarkThreadCountResponseDto,
          BookmarkThreadCountResponseDtoBuilder
        > {
  _$BookmarkThreadCountResponseDto? _$v;

  num? _members;
  num? get members => _$this._members;
  set members(num? members) => _$this._members = members;

  num? _posts;
  num? get posts => _$this._posts;
  set posts(num? posts) => _$this._posts = posts;

  BookmarkThreadCountResponseDtoBuilder() {
    BookmarkThreadCountResponseDto._defaults(this);
  }

  BookmarkThreadCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _members = $v.members;
      _posts = $v.posts;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BookmarkThreadCountResponseDto other) {
    _$v = other as _$BookmarkThreadCountResponseDto;
  }

  @override
  void update(void Function(BookmarkThreadCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarkThreadCountResponseDto build() => _build();

  _$BookmarkThreadCountResponseDto _build() {
    final _$result =
        _$v ??
        _$BookmarkThreadCountResponseDto._(
          members: BuiltValueNullFieldError.checkNotNull(
            members,
            r'BookmarkThreadCountResponseDto',
            'members',
          ),
          posts: BuiltValueNullFieldError.checkNotNull(
            posts,
            r'BookmarkThreadCountResponseDto',
            'posts',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
