// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_and_complete_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VerifyAndCompleteDto extends VerifyAndCompleteDto {
  @override
  final String email;
  @override
  final String code;
  @override
  final String username;
  @override
  final String password;

  factory _$VerifyAndCompleteDto([
    void Function(VerifyAndCompleteDtoBuilder)? updates,
  ]) => (VerifyAndCompleteDtoBuilder()..update(updates))._build();

  _$VerifyAndCompleteDto._({
    required this.email,
    required this.code,
    required this.username,
    required this.password,
  }) : super._();
  @override
  VerifyAndCompleteDto rebuild(
    void Function(VerifyAndCompleteDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  VerifyAndCompleteDtoBuilder toBuilder() =>
      VerifyAndCompleteDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerifyAndCompleteDto &&
        email == other.email &&
        code == other.code &&
        username == other.username &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VerifyAndCompleteDto')
          ..add('email', email)
          ..add('code', code)
          ..add('username', username)
          ..add('password', password))
        .toString();
  }
}

class VerifyAndCompleteDtoBuilder
    implements Builder<VerifyAndCompleteDto, VerifyAndCompleteDtoBuilder> {
  _$VerifyAndCompleteDto? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  VerifyAndCompleteDtoBuilder() {
    VerifyAndCompleteDto._defaults(this);
  }

  VerifyAndCompleteDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _code = $v.code;
      _username = $v.username;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VerifyAndCompleteDto other) {
    _$v = other as _$VerifyAndCompleteDto;
  }

  @override
  void update(void Function(VerifyAndCompleteDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerifyAndCompleteDto build() => _build();

  _$VerifyAndCompleteDto _build() {
    final _$result =
        _$v ??
        _$VerifyAndCompleteDto._(
          email: BuiltValueNullFieldError.checkNotNull(
            email,
            r'VerifyAndCompleteDto',
            'email',
          ),
          code: BuiltValueNullFieldError.checkNotNull(
            code,
            r'VerifyAndCompleteDto',
            'code',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'VerifyAndCompleteDto',
            'username',
          ),
          password: BuiltValueNullFieldError.checkNotNull(
            password,
            r'VerifyAndCompleteDto',
            'password',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
