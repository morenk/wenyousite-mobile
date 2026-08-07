// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_thread_owner_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchThreadOwnerResponseDto extends SearchThreadOwnerResponseDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final String? avatar;

  factory _$SearchThreadOwnerResponseDto([
    void Function(SearchThreadOwnerResponseDtoBuilder)? updates,
  ]) => (SearchThreadOwnerResponseDtoBuilder()..update(updates))._build();

  _$SearchThreadOwnerResponseDto._({
    required this.id,
    required this.username,
    this.avatar,
  }) : super._();
  @override
  SearchThreadOwnerResponseDto rebuild(
    void Function(SearchThreadOwnerResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchThreadOwnerResponseDtoBuilder toBuilder() =>
      SearchThreadOwnerResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchThreadOwnerResponseDto &&
        id == other.id &&
        username == other.username &&
        avatar == other.avatar;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchThreadOwnerResponseDto')
          ..add('id', id)
          ..add('username', username)
          ..add('avatar', avatar))
        .toString();
  }
}

class SearchThreadOwnerResponseDtoBuilder
    implements
        Builder<
          SearchThreadOwnerResponseDto,
          SearchThreadOwnerResponseDtoBuilder
        > {
  _$SearchThreadOwnerResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  SearchThreadOwnerResponseDtoBuilder() {
    SearchThreadOwnerResponseDto._defaults(this);
  }

  SearchThreadOwnerResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _avatar = $v.avatar;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchThreadOwnerResponseDto other) {
    _$v = other as _$SearchThreadOwnerResponseDto;
  }

  @override
  void update(void Function(SearchThreadOwnerResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchThreadOwnerResponseDto build() => _build();

  _$SearchThreadOwnerResponseDto _build() {
    final _$result =
        _$v ??
        _$SearchThreadOwnerResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'SearchThreadOwnerResponseDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'SearchThreadOwnerResponseDto',
            'username',
          ),
          avatar: avatar,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
