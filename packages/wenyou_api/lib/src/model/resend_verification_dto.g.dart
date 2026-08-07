// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resend_verification_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResendVerificationDto extends ResendVerificationDto {
  @override
  final String email;

  factory _$ResendVerificationDto([
    void Function(ResendVerificationDtoBuilder)? updates,
  ]) => (ResendVerificationDtoBuilder()..update(updates))._build();

  _$ResendVerificationDto._({required this.email}) : super._();
  @override
  ResendVerificationDto rebuild(
    void Function(ResendVerificationDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ResendVerificationDtoBuilder toBuilder() =>
      ResendVerificationDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResendVerificationDto && email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'ResendVerificationDto',
    )..add('email', email)).toString();
  }
}

class ResendVerificationDtoBuilder
    implements Builder<ResendVerificationDto, ResendVerificationDtoBuilder> {
  _$ResendVerificationDto? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  ResendVerificationDtoBuilder() {
    ResendVerificationDto._defaults(this);
  }

  ResendVerificationDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResendVerificationDto other) {
    _$v = other as _$ResendVerificationDto;
  }

  @override
  void update(void Function(ResendVerificationDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResendVerificationDto build() => _build();

  _$ResendVerificationDto _build() {
    final _$result =
        _$v ??
        _$ResendVerificationDto._(
          email: BuiltValueNullFieldError.checkNotNull(
            email,
            r'ResendVerificationDto',
            'email',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
