// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchResultResponseDto extends SearchResultResponseDto {
  @override
  final BuiltList<SearchUserResponseDto> users;
  @override
  final BuiltList<SearchThreadResponseDto> threads;
  @override
  final BuiltList<SearchPostResponseDto> posts;

  factory _$SearchResultResponseDto([
    void Function(SearchResultResponseDtoBuilder)? updates,
  ]) => (SearchResultResponseDtoBuilder()..update(updates))._build();

  _$SearchResultResponseDto._({
    required this.users,
    required this.threads,
    required this.posts,
  }) : super._();
  @override
  SearchResultResponseDto rebuild(
    void Function(SearchResultResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchResultResponseDtoBuilder toBuilder() =>
      SearchResultResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchResultResponseDto &&
        users == other.users &&
        threads == other.threads &&
        posts == other.posts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, users.hashCode);
    _$hash = $jc(_$hash, threads.hashCode);
    _$hash = $jc(_$hash, posts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchResultResponseDto')
          ..add('users', users)
          ..add('threads', threads)
          ..add('posts', posts))
        .toString();
  }
}

class SearchResultResponseDtoBuilder
    implements
        Builder<SearchResultResponseDto, SearchResultResponseDtoBuilder> {
  _$SearchResultResponseDto? _$v;

  ListBuilder<SearchUserResponseDto>? _users;
  ListBuilder<SearchUserResponseDto> get users =>
      _$this._users ??= ListBuilder<SearchUserResponseDto>();
  set users(ListBuilder<SearchUserResponseDto>? users) => _$this._users = users;

  ListBuilder<SearchThreadResponseDto>? _threads;
  ListBuilder<SearchThreadResponseDto> get threads =>
      _$this._threads ??= ListBuilder<SearchThreadResponseDto>();
  set threads(ListBuilder<SearchThreadResponseDto>? threads) =>
      _$this._threads = threads;

  ListBuilder<SearchPostResponseDto>? _posts;
  ListBuilder<SearchPostResponseDto> get posts =>
      _$this._posts ??= ListBuilder<SearchPostResponseDto>();
  set posts(ListBuilder<SearchPostResponseDto>? posts) => _$this._posts = posts;

  SearchResultResponseDtoBuilder() {
    SearchResultResponseDto._defaults(this);
  }

  SearchResultResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _users = $v.users.toBuilder();
      _threads = $v.threads.toBuilder();
      _posts = $v.posts.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchResultResponseDto other) {
    _$v = other as _$SearchResultResponseDto;
  }

  @override
  void update(void Function(SearchResultResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchResultResponseDto build() => _build();

  _$SearchResultResponseDto _build() {
    _$SearchResultResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SearchResultResponseDto._(
            users: users.build(),
            threads: threads.build(),
            posts: posts.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'users';
        users.build();
        _$failedField = 'threads';
        threads.build();
        _$failedField = 'posts';
        posts.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SearchResultResponseDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
