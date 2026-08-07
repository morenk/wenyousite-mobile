// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_author_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAuthorResponseDto extends PostAuthorResponseDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final String? avatar;

  factory _$PostAuthorResponseDto([
    void Function(PostAuthorResponseDtoBuilder)? updates,
  ]) => (PostAuthorResponseDtoBuilder()..update(updates))._build();

  _$PostAuthorResponseDto._({
    required this.id,
    required this.username,
    this.avatar,
  }) : super._();
  @override
  PostAuthorResponseDto rebuild(
    void Function(PostAuthorResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostAuthorResponseDtoBuilder toBuilder() =>
      PostAuthorResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAuthorResponseDto &&
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
    return (newBuiltValueToStringHelper(r'PostAuthorResponseDto')
          ..add('id', id)
          ..add('username', username)
          ..add('avatar', avatar))
        .toString();
  }
}

class PostAuthorResponseDtoBuilder
    implements Builder<PostAuthorResponseDto, PostAuthorResponseDtoBuilder> {
  _$PostAuthorResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  PostAuthorResponseDtoBuilder() {
    PostAuthorResponseDto._defaults(this);
  }

  PostAuthorResponseDtoBuilder get _$this {
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
  void replace(PostAuthorResponseDto other) {
    _$v = other as _$PostAuthorResponseDto;
  }

  @override
  void update(void Function(PostAuthorResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAuthorResponseDto build() => _build();

  _$PostAuthorResponseDto _build() {
    final _$result =
        _$v ??
        _$PostAuthorResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'PostAuthorResponseDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'PostAuthorResponseDto',
            'username',
          ),
          avatar: avatar,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
