// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_verify_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChangeEmailVerifyDto extends ChangeEmailVerifyDto {
  @override
  final String newEmail;
  @override
  final String code;

  factory _$ChangeEmailVerifyDto([
    void Function(ChangeEmailVerifyDtoBuilder)? updates,
  ]) => (ChangeEmailVerifyDtoBuilder()..update(updates))._build();

  _$ChangeEmailVerifyDto._({required this.newEmail, required this.code})
    : super._();
  @override
  ChangeEmailVerifyDto rebuild(
    void Function(ChangeEmailVerifyDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ChangeEmailVerifyDtoBuilder toBuilder() =>
      ChangeEmailVerifyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChangeEmailVerifyDto &&
        newEmail == other.newEmail &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, newEmail.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChangeEmailVerifyDto')
          ..add('newEmail', newEmail)
          ..add('code', code))
        .toString();
  }
}

class ChangeEmailVerifyDtoBuilder
    implements Builder<ChangeEmailVerifyDto, ChangeEmailVerifyDtoBuilder> {
  _$ChangeEmailVerifyDto? _$v;

  String? _newEmail;
  String? get newEmail => _$this._newEmail;
  set newEmail(String? newEmail) => _$this._newEmail = newEmail;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  ChangeEmailVerifyDtoBuilder() {
    ChangeEmailVerifyDto._defaults(this);
  }

  ChangeEmailVerifyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _newEmail = $v.newEmail;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChangeEmailVerifyDto other) {
    _$v = other as _$ChangeEmailVerifyDto;
  }

  @override
  void update(void Function(ChangeEmailVerifyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChangeEmailVerifyDto build() => _build();

  _$ChangeEmailVerifyDto _build() {
    final _$result =
        _$v ??
        _$ChangeEmailVerifyDto._(
          newEmail: BuiltValueNullFieldError.checkNotNull(
            newEmail,
            r'ChangeEmailVerifyDto',
            'newEmail',
          ),
          code: BuiltValueNullFieldError.checkNotNull(
            code,
            r'ChangeEmailVerifyDto',
            'code',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
