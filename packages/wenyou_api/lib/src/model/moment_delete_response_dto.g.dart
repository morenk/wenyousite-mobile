// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_delete_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentDeleteResponseDto extends MomentDeleteResponseDto {
  @override
  final String message;

  factory _$MomentDeleteResponseDto([
    void Function(MomentDeleteResponseDtoBuilder)? updates,
  ]) => (MomentDeleteResponseDtoBuilder()..update(updates))._build();

  _$MomentDeleteResponseDto._({required this.message}) : super._();
  @override
  MomentDeleteResponseDto rebuild(
    void Function(MomentDeleteResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentDeleteResponseDtoBuilder toBuilder() =>
      MomentDeleteResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentDeleteResponseDto && message == other.message;
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
      r'MomentDeleteResponseDto',
    )..add('message', message)).toString();
  }
}

class MomentDeleteResponseDtoBuilder
    implements
        Builder<MomentDeleteResponseDto, MomentDeleteResponseDtoBuilder> {
  _$MomentDeleteResponseDto? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  MomentDeleteResponseDtoBuilder() {
    MomentDeleteResponseDto._defaults(this);
  }

  MomentDeleteResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentDeleteResponseDto other) {
    _$v = other as _$MomentDeleteResponseDto;
  }

  @override
  void update(void Function(MomentDeleteResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentDeleteResponseDto build() => _build();

  _$MomentDeleteResponseDto _build() {
    final _$result =
        _$v ??
        _$MomentDeleteResponseDto._(
          message: BuiltValueNullFieldError.checkNotNull(
            message,
            r'MomentDeleteResponseDto',
            'message',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
