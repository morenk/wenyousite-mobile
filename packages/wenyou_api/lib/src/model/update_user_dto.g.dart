// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateUserDto extends UpdateUserDto {
  @override
  final String? username;
  @override
  final String? bio;
  @override
  final bool? showRecentReplies;
  @override
  final bool? showPlayerBadges;
  @override
  final bool? showBookmarks;

  factory _$UpdateUserDto([void Function(UpdateUserDtoBuilder)? updates]) =>
      (UpdateUserDtoBuilder()..update(updates))._build();

  _$UpdateUserDto._({
    this.username,
    this.bio,
    this.showRecentReplies,
    this.showPlayerBadges,
    this.showBookmarks,
  }) : super._();
  @override
  UpdateUserDto rebuild(void Function(UpdateUserDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateUserDtoBuilder toBuilder() => UpdateUserDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateUserDto &&
        username == other.username &&
        bio == other.bio &&
        showRecentReplies == other.showRecentReplies &&
        showPlayerBadges == other.showPlayerBadges &&
        showBookmarks == other.showBookmarks;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, showRecentReplies.hashCode);
    _$hash = $jc(_$hash, showPlayerBadges.hashCode);
    _$hash = $jc(_$hash, showBookmarks.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateUserDto')
          ..add('username', username)
          ..add('bio', bio)
          ..add('showRecentReplies', showRecentReplies)
          ..add('showPlayerBadges', showPlayerBadges)
          ..add('showBookmarks', showBookmarks))
        .toString();
  }
}

class UpdateUserDtoBuilder
    implements Builder<UpdateUserDto, UpdateUserDtoBuilder> {
  _$UpdateUserDto? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  bool? _showRecentReplies;
  bool? get showRecentReplies => _$this._showRecentReplies;
  set showRecentReplies(bool? showRecentReplies) =>
      _$this._showRecentReplies = showRecentReplies;

  bool? _showPlayerBadges;
  bool? get showPlayerBadges => _$this._showPlayerBadges;
  set showPlayerBadges(bool? showPlayerBadges) =>
      _$this._showPlayerBadges = showPlayerBadges;

  bool? _showBookmarks;
  bool? get showBookmarks => _$this._showBookmarks;
  set showBookmarks(bool? showBookmarks) =>
      _$this._showBookmarks = showBookmarks;

  UpdateUserDtoBuilder() {
    UpdateUserDto._defaults(this);
  }

  UpdateUserDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _bio = $v.bio;
      _showRecentReplies = $v.showRecentReplies;
      _showPlayerBadges = $v.showPlayerBadges;
      _showBookmarks = $v.showBookmarks;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateUserDto other) {
    _$v = other as _$UpdateUserDto;
  }

  @override
  void update(void Function(UpdateUserDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateUserDto build() => _build();

  _$UpdateUserDto _build() {
    final _$result =
        _$v ??
        _$UpdateUserDto._(
          username: username,
          bio: bio,
          showRecentReplies: showRecentReplies,
          showPlayerBadges: showPlayerBadges,
          showBookmarks: showBookmarks,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
