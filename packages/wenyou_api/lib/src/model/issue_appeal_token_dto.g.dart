// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_appeal_token_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IssueAppealTokenDto extends IssueAppealTokenDto {
  @override
  final String account;
  @override
  final String password;

  factory _$IssueAppealTokenDto([
    void Function(IssueAppealTokenDtoBuilder)? updates,
  ]) => (IssueAppealTokenDtoBuilder()..update(updates))._build();

  _$IssueAppealTokenDto._({required this.account, required this.password})
    : super._();
  @override
  IssueAppealTokenDto rebuild(
    void Function(IssueAppealTokenDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  IssueAppealTokenDtoBuilder toBuilder() =>
      IssueAppealTokenDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IssueAppealTokenDto &&
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
    return (newBuiltValueToStringHelper(r'IssueAppealTokenDto')
          ..add('account', account)
          ..add('password', password))
        .toString();
  }
}

class IssueAppealTokenDtoBuilder
    implements Builder<IssueAppealTokenDto, IssueAppealTokenDtoBuilder> {
  _$IssueAppealTokenDto? _$v;

  String? _account;
  String? get account => _$this._account;
  set account(String? account) => _$this._account = account;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  IssueAppealTokenDtoBuilder() {
    IssueAppealTokenDto._defaults(this);
  }

  IssueAppealTokenDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _account = $v.account;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IssueAppealTokenDto other) {
    _$v = other as _$IssueAppealTokenDto;
  }

  @override
  void update(void Function(IssueAppealTokenDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IssueAppealTokenDto build() => _build();

  _$IssueAppealTokenDto _build() {
    final _$result =
        _$v ??
        _$IssueAppealTokenDto._(
          account: BuiltValueNullFieldError.checkNotNull(
            account,
            r'IssueAppealTokenDto',
            'account',
          ),
          password: BuiltValueNullFieldError.checkNotNull(
            password,
            r'IssueAppealTokenDto',
            'password',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
