// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_code_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RegisterCodeResponseDto extends RegisterCodeResponseDto {
  @override
  final bool emailSent;
  @override
  final num codeExpiresIn;
  @override
  final String message;

  factory _$RegisterCodeResponseDto([
    void Function(RegisterCodeResponseDtoBuilder)? updates,
  ]) => (RegisterCodeResponseDtoBuilder()..update(updates))._build();

  _$RegisterCodeResponseDto._({
    required this.emailSent,
    required this.codeExpiresIn,
    required this.message,
  }) : super._();
  @override
  RegisterCodeResponseDto rebuild(
    void Function(RegisterCodeResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RegisterCodeResponseDtoBuilder toBuilder() =>
      RegisterCodeResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterCodeResponseDto &&
        emailSent == other.emailSent &&
        codeExpiresIn == other.codeExpiresIn &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, emailSent.hashCode);
    _$hash = $jc(_$hash, codeExpiresIn.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegisterCodeResponseDto')
          ..add('emailSent', emailSent)
          ..add('codeExpiresIn', codeExpiresIn)
          ..add('message', message))
        .toString();
  }
}

class RegisterCodeResponseDtoBuilder
    implements
        Builder<RegisterCodeResponseDto, RegisterCodeResponseDtoBuilder> {
  _$RegisterCodeResponseDto? _$v;

  bool? _emailSent;
  bool? get emailSent => _$this._emailSent;
  set emailSent(bool? emailSent) => _$this._emailSent = emailSent;

  num? _codeExpiresIn;
  num? get codeExpiresIn => _$this._codeExpiresIn;
  set codeExpiresIn(num? codeExpiresIn) =>
      _$this._codeExpiresIn = codeExpiresIn;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  RegisterCodeResponseDtoBuilder() {
    RegisterCodeResponseDto._defaults(this);
  }

  RegisterCodeResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _emailSent = $v.emailSent;
      _codeExpiresIn = $v.codeExpiresIn;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterCodeResponseDto other) {
    _$v = other as _$RegisterCodeResponseDto;
  }

  @override
  void update(void Function(RegisterCodeResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterCodeResponseDto build() => _build();

  _$RegisterCodeResponseDto _build() {
    final _$result =
        _$v ??
        _$RegisterCodeResponseDto._(
          emailSent: BuiltValueNullFieldError.checkNotNull(
            emailSent,
            r'RegisterCodeResponseDto',
            'emailSent',
          ),
          codeExpiresIn: BuiltValueNullFieldError.checkNotNull(
            codeExpiresIn,
            r'RegisterCodeResponseDto',
            'codeExpiresIn',
          ),
          message: BuiltValueNullFieldError.checkNotNull(
            message,
            r'RegisterCodeResponseDto',
            'message',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
