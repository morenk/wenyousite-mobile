// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_login_challenge_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLoginChallengeDto extends AdminLoginChallengeDto {
  @override
  final String account;
  @override
  final String password;

  factory _$AdminLoginChallengeDto([
    void Function(AdminLoginChallengeDtoBuilder)? updates,
  ]) => (AdminLoginChallengeDtoBuilder()..update(updates))._build();

  _$AdminLoginChallengeDto._({required this.account, required this.password})
    : super._();
  @override
  AdminLoginChallengeDto rebuild(
    void Function(AdminLoginChallengeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminLoginChallengeDtoBuilder toBuilder() =>
      AdminLoginChallengeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLoginChallengeDto &&
        account == other.account &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, account.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminLoginChallengeDto')
          ..add('account', account)
          ..add('password', password))
        .toString();
  }
}

class AdminLoginChallengeDtoBuilder
    implements Builder<AdminLoginChallengeDto, AdminLoginChallengeDtoBuilder> {
  _$AdminLoginChallengeDto? _$v;

  String? _account;
  String? get account => _$this._account;
  set account(String? account) => _$this._account = account;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  AdminLoginChallengeDtoBuilder() {
    AdminLoginChallengeDto._defaults(this);
  }

  AdminLoginChallengeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _account = $v.account;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminLoginChallengeDto other) {
    _$v = other as _$AdminLoginChallengeDto;
  }

  @override
  void update(void Function(AdminLoginChallengeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLoginChallengeDto build() => _build();

  _$AdminLoginChallengeDto _build() {
    final _$result =
        _$v ??
        _$AdminLoginChallengeDto._(
          account: BuiltValueNullFieldError.checkNotNull(
            account,
            r'AdminLoginChallengeDto',
            'account',
          ),
          password: BuiltValueNullFieldError.checkNotNull(
            password,
            r'AdminLoginChallengeDto',
            'password',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
