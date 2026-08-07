// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_list_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadListCountResponseDto extends ThreadListCountResponseDto {
  @override
  final num members;
  @override
  final num players;
  @override
  final num posts;

  factory _$ThreadListCountResponseDto([
    void Function(ThreadListCountResponseDtoBuilder)? updates,
  ]) => (ThreadListCountResponseDtoBuilder()..update(updates))._build();

  _$ThreadListCountResponseDto._({
    required this.members,
    required this.players,
    required this.posts,
  }) : super._();
  @override
  ThreadListCountResponseDto rebuild(
    void Function(ThreadListCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadListCountResponseDtoBuilder toBuilder() =>
      ThreadListCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadListCountResponseDto &&
        members == other.members &&
        players == other.players &&
        posts == other.posts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, members.hashCode);
    _$hash = $jc(_$hash, players.hashCode);
    _$hash = $jc(_$hash, posts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadListCountResponseDto')
          ..add('members', members)
          ..add('players', players)
          ..add('posts', posts))
        .toString();
  }
}

class ThreadListCountResponseDtoBuilder
    implements
        Builder<ThreadListCountResponseDto, ThreadListCountResponseDtoBuilder> {
  _$ThreadListCountResponseDto? _$v;

  num? _members;
  num? get members => _$this._members;
  set members(num? members) => _$this._members = members;

  num? _players;
  num? get players => _$this._players;
  set players(num? players) => _$this._players = players;

  num? _posts;
  num? get posts => _$this._posts;
  set posts(num? posts) => _$this._posts = posts;

  ThreadListCountResponseDtoBuilder() {
    ThreadListCountResponseDto._defaults(this);
  }

  ThreadListCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _members = $v.members;
      _players = $v.players;
      _posts = $v.posts;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadListCountResponseDto other) {
    _$v = other as _$ThreadListCountResponseDto;
  }

  @override
  void update(void Function(ThreadListCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadListCountResponseDto build() => _build();

  _$ThreadListCountResponseDto _build() {
    final _$result =
        _$v ??
        _$ThreadListCountResponseDto._(
          members: BuiltValueNullFieldError.checkNotNull(
            members,
            r'ThreadListCountResponseDto',
            'members',
          ),
          players: BuiltValueNullFieldError.checkNotNull(
            players,
            r'ThreadListCountResponseDto',
            'players',
          ),
          posts: BuiltValueNullFieldError.checkNotNull(
            posts,
            r'ThreadListCountResponseDto',
            'posts',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
