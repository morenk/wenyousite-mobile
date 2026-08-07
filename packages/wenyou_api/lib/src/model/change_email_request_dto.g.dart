// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_request_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChangeEmailRequestDto extends ChangeEmailRequestDto {
  @override
  final String newEmail;
  @override
  final String oldPassword;

  factory _$ChangeEmailRequestDto([
    void Function(ChangeEmailRequestDtoBuilder)? updates,
  ]) => (ChangeEmailRequestDtoBuilder()..update(updates))._build();

  _$ChangeEmailRequestDto._({required this.newEmail, required this.oldPassword})
    : super._();
  @override
  ChangeEmailRequestDto rebuild(
    void Function(ChangeEmailRequestDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ChangeEmailRequestDtoBuilder toBuilder() =>
      ChangeEmailRequestDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChangeEmailRequestDto &&
        newEmail == other.newEmail &&
        oldPassword == other.oldPassword;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, newEmail.hashCode);
    _$hash = $jc(_$hash, oldPassword.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChangeEmailRequestDto')
          ..add('newEmail', newEmail)
          ..add('oldPassword', oldPassword))
        .toString();
  }
}

class ChangeEmailRequestDtoBuilder
    implements Builder<ChangeEmailRequestDto, ChangeEmailRequestDtoBuilder> {
  _$ChangeEmailRequestDto? _$v;

  String? _newEmail;
  String? get newEmail => _$this._newEmail;
  set newEmail(String? newEmail) => _$this._newEmail = newEmail;

  String? _oldPassword;
  String? get oldPassword => _$this._oldPassword;
  set oldPassword(String? oldPassword) => _$this._oldPassword = oldPassword;

  ChangeEmailRequestDtoBuilder() {
    ChangeEmailRequestDto._defaults(this);
  }

  ChangeEmailRequestDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _newEmail = $v.newEmail;
      _oldPassword = $v.oldPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChangeEmailRequestDto other) {
    _$v = other as _$ChangeEmailRequestDto;
  }

  @override
  void update(void Function(ChangeEmailRequestDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChangeEmailRequestDto build() => _build();

  _$ChangeEmailRequestDto _build() {
    final _$result =
        _$v ??
        _$ChangeEmailRequestDto._(
          newEmail: BuiltValueNullFieldError.checkNotNull(
            newEmail,
            r'ChangeEmailRequestDto',
            'newEmail',
          ),
          oldPassword: BuiltValueNullFieldError.checkNotNull(
            oldPassword,
            r'ChangeEmailRequestDto',
            'oldPassword',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
