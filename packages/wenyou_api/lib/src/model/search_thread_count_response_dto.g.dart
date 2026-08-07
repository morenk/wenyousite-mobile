// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_thread_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchThreadCountResponseDto extends SearchThreadCountResponseDto {
  @override
  final num members;
  @override
  final num posts;
  @override
  final num players;

  factory _$SearchThreadCountResponseDto([
    void Function(SearchThreadCountResponseDtoBuilder)? updates,
  ]) => (SearchThreadCountResponseDtoBuilder()..update(updates))._build();

  _$SearchThreadCountResponseDto._({
    required this.members,
    required this.posts,
    required this.players,
  }) : super._();
  @override
  SearchThreadCountResponseDto rebuild(
    void Function(SearchThreadCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchThreadCountResponseDtoBuilder toBuilder() =>
      SearchThreadCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchThreadCountResponseDto &&
        members == other.members &&
        posts == other.posts &&
        players == other.players;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, members.hashCode);
    _$hash = $jc(_$hash, posts.hashCode);
    _$hash = $jc(_$hash, players.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchThreadCountResponseDto')
          ..add('members', members)
          ..add('posts', posts)
          ..add('players', players))
        .toString();
  }
}

class SearchThreadCountResponseDtoBuilder
    implements
        Builder<
          SearchThreadCountResponseDto,
          SearchThreadCountResponseDtoBuilder
        > {
  _$SearchThreadCountResponseDto? _$v;

  num? _members;
  num? get members => _$this._members;
  set members(num? members) => _$this._members = members;

  num? _posts;
  num? get posts => _$this._posts;
  set posts(num? posts) => _$this._posts = posts;

  num? _players;
  num? get players => _$this._players;
  set players(num? players) => _$this._players = players;

  SearchThreadCountResponseDtoBuilder() {
    SearchThreadCountResponseDto._defaults(this);
  }

  SearchThreadCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _members = $v.members;
      _posts = $v.posts;
      _players = $v.players;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchThreadCountResponseDto other) {
    _$v = other as _$SearchThreadCountResponseDto;
  }

  @override
  void update(void Function(SearchThreadCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchThreadCountResponseDto build() => _build();

  _$SearchThreadCountResponseDto _build() {
    final _$result =
        _$v ??
        _$SearchThreadCountResponseDto._(
          members: BuiltValueNullFieldError.checkNotNull(
            members,
            r'SearchThreadCountResponseDto',
            'members',
          ),
          posts: BuiltValueNullFieldError.checkNotNull(
            posts,
            r'SearchThreadCountResponseDto',
            'posts',
          ),
          players: BuiltValueNullFieldError.checkNotNull(
            players,
            r'SearchThreadCountResponseDto',
            'players',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
