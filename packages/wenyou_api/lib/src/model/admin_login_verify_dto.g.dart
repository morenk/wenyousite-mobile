// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_login_verify_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLoginVerifyDto extends AdminLoginVerifyDto {
  @override
  final String challengeId;
  @override
  final String code;
  @override
  final bool? rememberDevice;

  factory _$AdminLoginVerifyDto([
    void Function(AdminLoginVerifyDtoBuilder)? updates,
  ]) => (AdminLoginVerifyDtoBuilder()..update(updates))._build();

  _$AdminLoginVerifyDto._({
    required this.challengeId,
    required this.code,
    this.rememberDevice,
  }) : super._();
  @override
  AdminLoginVerifyDto rebuild(
    void Function(AdminLoginVerifyDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminLoginVerifyDtoBuilder toBuilder() =>
      AdminLoginVerifyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLoginVerifyDto &&
        challengeId == other.challengeId &&
        code == other.code &&
        rememberDevice == other.rememberDevice;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, challengeId.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, rememberDevice.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminLoginVerifyDto')
          ..add('challengeId', challengeId)
          ..add('code', code)
          ..add('rememberDevice', rememberDevice))
        .toString();
  }
}

class AdminLoginVerifyDtoBuilder
    implements Builder<AdminLoginVerifyDto, AdminLoginVerifyDtoBuilder> {
  _$AdminLoginVerifyDto? _$v;

  String? _challengeId;
  String? get challengeId => _$this._challengeId;
  set challengeId(String? challengeId) => _$this._challengeId = challengeId;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  bool? _rememberDevice;
  bool? get rememberDevice => _$this._rememberDevice;
  set rememberDevice(bool? rememberDevice) =>
      _$this._rememberDevice = rememberDevice;

  AdminLoginVerifyDtoBuilder() {
    AdminLoginVerifyDto._defaults(this);
  }

  AdminLoginVerifyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _challengeId = $v.challengeId;
      _code = $v.code;
      _rememberDevice = $v.rememberDevice;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminLoginVerifyDto other) {
    _$v = other as _$AdminLoginVerifyDto;
  }

  @override
  void update(void Function(AdminLoginVerifyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLoginVerifyDto build() => _build();

  _$AdminLoginVerifyDto _build() {
    final _$result =
        _$v ??
        _$AdminLoginVerifyDto._(
          challengeId: BuiltValueNullFieldError.checkNotNull(
            challengeId,
            r'AdminLoginVerifyDto',
            'challengeId',
          ),
          code: BuiltValueNullFieldError.checkNotNull(
            code,
            r'AdminLoginVerifyDto',
            'code',
          ),
          rememberDevice: rememberDevice,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
