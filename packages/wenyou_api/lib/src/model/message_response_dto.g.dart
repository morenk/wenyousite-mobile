// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MessageResponseDto extends MessageResponseDto {
  @override
  final String message;

  factory _$MessageResponseDto([
    void Function(MessageResponseDtoBuilder)? updates,
  ]) => (MessageResponseDtoBuilder()..update(updates))._build();

  _$MessageResponseDto._({required this.message}) : super._();
  @override
  MessageResponseDto rebuild(
    void Function(MessageResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MessageResponseDtoBuilder toBuilder() =>
      MessageResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessageResponseDto && message == other.message;
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
      r'MessageResponseDto',
    )..add('message', message)).toString();
  }
}

class MessageResponseDtoBuilder
    implements Builder<MessageResponseDto, MessageResponseDtoBuilder> {
  _$MessageResponseDto? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  MessageResponseDtoBuilder() {
    MessageResponseDto._defaults(this);
  }

  MessageResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MessageResponseDto other) {
    _$v = other as _$MessageResponseDto;
  }

  @override
  void update(void Function(MessageResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MessageResponseDto build() => _build();

  _$MessageResponseDto _build() {
    final _$result =
        _$v ??
        _$MessageResponseDto._(
          message: BuiltValueNullFieldError.checkNotNull(
            message,
            r'MessageResponseDto',
            'message',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
