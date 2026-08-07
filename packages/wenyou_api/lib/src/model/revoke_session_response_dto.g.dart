// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revoke_session_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RevokeSessionResponseDto extends RevokeSessionResponseDto {
  @override
  final String message;

  factory _$RevokeSessionResponseDto([
    void Function(RevokeSessionResponseDtoBuilder)? updates,
  ]) => (RevokeSessionResponseDtoBuilder()..update(updates))._build();

  _$RevokeSessionResponseDto._({required this.message}) : super._();
  @override
  RevokeSessionResponseDto rebuild(
    void Function(RevokeSessionResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RevokeSessionResponseDtoBuilder toBuilder() =>
      RevokeSessionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RevokeSessionResponseDto && message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'RevokeSessionResponseDto',
    )..add('message', message)).toString();
  }
}

class RevokeSessionResponseDtoBuilder
    implements
        Builder<RevokeSessionResponseDto, RevokeSessionResponseDtoBuilder> {
  _$RevokeSessionResponseDto? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  RevokeSessionResponseDtoBuilder() {
    RevokeSessionResponseDto._defaults(this);
  }

  RevokeSessionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RevokeSessionResponseDto other) {
    _$v = other as _$RevokeSessionResponseDto;
  }

  @override
  void update(void Function(RevokeSessionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RevokeSessionResponseDto build() => _build();

  _$RevokeSessionResponseDto _build() {
    final _$result =
        _$v ??
        _$RevokeSessionResponseDto._(
          message: BuiltValueNullFieldError.checkNotNull(
            message,
            r'RevokeSessionResponseDto',
            'message',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
