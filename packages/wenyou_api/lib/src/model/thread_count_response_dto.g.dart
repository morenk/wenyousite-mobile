// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadCountResponseDto extends ThreadCountResponseDto {
  @override
  final num members;
  @override
  final num posts;
  @override
  final num players;

  factory _$ThreadCountResponseDto([
    void Function(ThreadCountResponseDtoBuilder)? updates,
  ]) => (ThreadCountResponseDtoBuilder()..update(updates))._build();

  _$ThreadCountResponseDto._({
    required this.members,
    required this.posts,
    required this.players,
  }) : super._();
  @override
  ThreadCountResponseDto rebuild(
    void Function(ThreadCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadCountResponseDtoBuilder toBuilder() =>
      ThreadCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadCountResponseDto &&
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
    return (newBuiltValueToStringHelper(r'ThreadCountResponseDto')
          ..add('members', members)
          ..add('posts', posts)
          ..add('players', players))
        .toString();
  }
}

class ThreadCountResponseDtoBuilder
    implements Builder<ThreadCountResponseDto, ThreadCountResponseDtoBuilder> {
  _$ThreadCountResponseDto? _$v;

  num? _members;
  num? get members => _$this._members;
  set members(num? members) => _$this._members = members;

  num? _posts;
  num? get posts => _$this._posts;
  set posts(num? posts) => _$this._posts = posts;

  num? _players;
  num? get players => _$this._players;
  set players(num? players) => _$this._players = players;

  ThreadCountResponseDtoBuilder() {
    ThreadCountResponseDto._defaults(this);
  }

  ThreadCountResponseDtoBuilder get _$this {
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
  void replace(ThreadCountResponseDto other) {
    _$v = other as _$ThreadCountResponseDto;
  }

  @override
  void update(void Function(ThreadCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadCountResponseDto build() => _build();

  _$ThreadCountResponseDto _build() {
    final _$result =
        _$v ??
        _$ThreadCountResponseDto._(
          members: BuiltValueNullFieldError.checkNotNull(
            members,
            r'ThreadCountResponseDto',
            'members',
          ),
          posts: BuiltValueNullFieldError.checkNotNull(
            posts,
            r'ThreadCountResponseDto',
            'posts',
          ),
          players: BuiltValueNullFieldError.checkNotNull(
            players,
            r'ThreadCountResponseDto',
            'players',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
