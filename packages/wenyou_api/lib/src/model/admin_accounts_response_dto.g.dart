// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_accounts_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminAccountsResponseDto extends AdminAccountsResponseDto {
  @override
  final BuiltList<BuiltMap<String, JsonObject?>> accounts;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>> invites;

  factory _$AdminAccountsResponseDto([
    void Function(AdminAccountsResponseDtoBuilder)? updates,
  ]) => (AdminAccountsResponseDtoBuilder()..update(updates))._build();

  _$AdminAccountsResponseDto._({required this.accounts, required this.invites})
    : super._();
  @override
  AdminAccountsResponseDto rebuild(
    void Function(AdminAccountsResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAccountsResponseDtoBuilder toBuilder() =>
      AdminAccountsResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAccountsResponseDto &&
        accounts == other.accounts &&
        invites == other.invites;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accounts.hashCode);
    _$hash = $jc(_$hash, invites.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminAccountsResponseDto')
          ..add('accounts', accounts)
          ..add('invites', invites))
        .toString();
  }
}

class AdminAccountsResponseDtoBuilder
    implements
        Builder<AdminAccountsResponseDto, AdminAccountsResponseDtoBuilder> {
  _$AdminAccountsResponseDto? _$v;

  ListBuilder<BuiltMap<String, JsonObject?>>? _accounts;
  ListBuilder<BuiltMap<String, JsonObject?>> get accounts =>
      _$this._accounts ??= ListBuilder<BuiltMap<String, JsonObject?>>();
  set accounts(ListBuilder<BuiltMap<String, JsonObject?>>? accounts) =>
      _$this._accounts = accounts;

  ListBuilder<BuiltMap<String, JsonObject?>>? _invites;
  ListBuilder<BuiltMap<String, JsonObject?>> get invites =>
      _$this._invites ??= ListBuilder<BuiltMap<String, JsonObject?>>();
  set invites(ListBuilder<BuiltMap<String, JsonObject?>>? invites) =>
      _$this._invites = invites;

  AdminAccountsResponseDtoBuilder() {
    AdminAccountsResponseDto._defaults(this);
  }

  AdminAccountsResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accounts = $v.accounts.toBuilder();
      _invites = $v.invites.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminAccountsResponseDto other) {
    _$v = other as _$AdminAccountsResponseDto;
  }

  @override
  void update(void Function(AdminAccountsResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAccountsResponseDto build() => _build();

  _$AdminAccountsResponseDto _build() {
    _$AdminAccountsResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminAccountsResponseDto._(
            accounts: accounts.build(),
            invites: invites.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'accounts';
        accounts.build();
        _$failedField = 'invites';
        invites.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminAccountsResponseDto',
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
