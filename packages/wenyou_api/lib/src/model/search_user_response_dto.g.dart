// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_user_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchUserResponseDto extends SearchUserResponseDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final String? avatar;
  @override
  final String? bio;

  factory _$SearchUserResponseDto([
    void Function(SearchUserResponseDtoBuilder)? updates,
  ]) => (SearchUserResponseDtoBuilder()..update(updates))._build();

  _$SearchUserResponseDto._({
    required this.id,
    required this.username,
    this.avatar,
    this.bio,
  }) : super._();
  @override
  SearchUserResponseDto rebuild(
    void Function(SearchUserResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchUserResponseDtoBuilder toBuilder() =>
      SearchUserResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchUserResponseDto &&
        id == other.id &&
        username == other.username &&
        avatar == other.avatar &&
        bio == other.bio;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchUserResponseDto')
          ..add('id', id)
          ..add('username', username)
          ..add('avatar', avatar)
          ..add('bio', bio))
        .toString();
  }
}

class SearchUserResponseDtoBuilder
    implements Builder<SearchUserResponseDto, SearchUserResponseDtoBuilder> {
  _$SearchUserResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  SearchUserResponseDtoBuilder() {
    SearchUserResponseDto._defaults(this);
  }

  SearchUserResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _avatar = $v.avatar;
      _bio = $v.bio;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchUserResponseDto other) {
    _$v = other as _$SearchUserResponseDto;
  }

  @override
  void update(void Function(SearchUserResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchUserResponseDto build() => _build();

  _$SearchUserResponseDto _build() {
    final _$result =
        _$v ??
        _$SearchUserResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'SearchUserResponseDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'SearchUserResponseDto',
            'username',
          ),
          avatar: avatar,
          bio: bio,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
