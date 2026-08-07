// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_social_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserSocialCountResponseDto extends UserSocialCountResponseDto {
  @override
  final num following;
  @override
  final num followers;

  factory _$UserSocialCountResponseDto([
    void Function(UserSocialCountResponseDtoBuilder)? updates,
  ]) => (UserSocialCountResponseDtoBuilder()..update(updates))._build();

  _$UserSocialCountResponseDto._({
    required this.following,
    required this.followers,
  }) : super._();
  @override
  UserSocialCountResponseDto rebuild(
    void Function(UserSocialCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UserSocialCountResponseDtoBuilder toBuilder() =>
      UserSocialCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserSocialCountResponseDto &&
        following == other.following &&
        followers == other.followers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, following.hashCode);
    _$hash = $jc(_$hash, followers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserSocialCountResponseDto')
          ..add('following', following)
          ..add('followers', followers))
        .toString();
  }
}

class UserSocialCountResponseDtoBuilder
    implements
        Builder<UserSocialCountResponseDto, UserSocialCountResponseDtoBuilder> {
  _$UserSocialCountResponseDto? _$v;

  num? _following;
  num? get following => _$this._following;
  set following(num? following) => _$this._following = following;

  num? _followers;
  num? get followers => _$this._followers;
  set followers(num? followers) => _$this._followers = followers;

  UserSocialCountResponseDtoBuilder() {
    UserSocialCountResponseDto._defaults(this);
  }

  UserSocialCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _following = $v.following;
      _followers = $v.followers;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserSocialCountResponseDto other) {
    _$v = other as _$UserSocialCountResponseDto;
  }

  @override
  void update(void Function(UserSocialCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserSocialCountResponseDto build() => _build();

  _$UserSocialCountResponseDto _build() {
    final _$result =
        _$v ??
        _$UserSocialCountResponseDto._(
          following: BuiltValueNullFieldError.checkNotNull(
            following,
            r'UserSocialCountResponseDto',
            'following',
          ),
          followers: BuiltValueNullFieldError.checkNotNull(
            followers,
            r'UserSocialCountResponseDto',
            'followers',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
