// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthResponseDto extends AuthResponseDto {
  @override
  final String accessToken;
  @override
  final String? refreshToken;
  @override
  final UserProfile user;
  @override
  final String? message;

  factory _$AuthResponseDto([void Function(AuthResponseDtoBuilder)? updates]) =>
      (AuthResponseDtoBuilder()..update(updates))._build();

  _$AuthResponseDto._({
    required this.accessToken,
    this.refreshToken,
    required this.user,
    this.message,
  }) : super._();
  @override
  AuthResponseDto rebuild(void Function(AuthResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthResponseDtoBuilder toBuilder() => AuthResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthResponseDto &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        user == other.user &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthResponseDto')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('user', user)
          ..add('message', message))
        .toString();
  }
}

class AuthResponseDtoBuilder
    implements Builder<AuthResponseDto, AuthResponseDtoBuilder> {
  _$AuthResponseDto? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  UserProfileBuilder? _user;
  UserProfileBuilder get user => _$this._user ??= UserProfileBuilder();
  set user(UserProfileBuilder? user) => _$this._user = user;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  AuthResponseDtoBuilder() {
    AuthResponseDto._defaults(this);
  }

  AuthResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _user = $v.user.toBuilder();
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthResponseDto other) {
    _$v = other as _$AuthResponseDto;
  }

  @override
  void update(void Function(AuthResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthResponseDto build() => _build();

  _$AuthResponseDto _build() {
    _$AuthResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AuthResponseDto._(
            accessToken: BuiltValueNullFieldError.checkNotNull(
              accessToken,
              r'AuthResponseDto',
              'accessToken',
            ),
            refreshToken: refreshToken,
            user: user.build(),
            message: message,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AuthResponseDto',
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
