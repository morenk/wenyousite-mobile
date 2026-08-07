// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_code_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RequestCodeDto extends RequestCodeDto {
  @override
  final String email;

  factory _$RequestCodeDto([void Function(RequestCodeDtoBuilder)? updates]) =>
      (RequestCodeDtoBuilder()..update(updates))._build();

  _$RequestCodeDto._({required this.email}) : super._();
  @override
  RequestCodeDto rebuild(void Function(RequestCodeDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RequestCodeDtoBuilder toBuilder() => RequestCodeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RequestCodeDto && email == other.email;
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
      r'RequestCodeDto',
    )..add('email', email)).toString();
  }
}

class RequestCodeDtoBuilder
    implements Builder<RequestCodeDto, RequestCodeDtoBuilder> {
  _$RequestCodeDto? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  RequestCodeDtoBuilder() {
    RequestCodeDto._defaults(this);
  }

  RequestCodeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RequestCodeDto other) {
    _$v = other as _$RequestCodeDto;
  }

  @override
  void update(void Function(RequestCodeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RequestCodeDto build() => _build();

  _$RequestCodeDto _build() {
    final _$result =
        _$v ??
        _$RequestCodeDto._(
          email: BuiltValueNullFieldError.checkNotNull(
            email,
            r'RequestCodeDto',
            'email',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
