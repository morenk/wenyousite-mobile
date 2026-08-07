// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message_recall_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DirectMessageRecallResponseDto extends DirectMessageRecallResponseDto {
  @override
  final String message;
  @override
  final bool conversationCanceled;

  factory _$DirectMessageRecallResponseDto([
    void Function(DirectMessageRecallResponseDtoBuilder)? updates,
  ]) => (DirectMessageRecallResponseDtoBuilder()..update(updates))._build();

  _$DirectMessageRecallResponseDto._({
    required this.message,
    required this.conversationCanceled,
  }) : super._();
  @override
  DirectMessageRecallResponseDto rebuild(
    void Function(DirectMessageRecallResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectMessageRecallResponseDtoBuilder toBuilder() =>
      DirectMessageRecallResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectMessageRecallResponseDto &&
        message == other.message &&
        conversationCanceled == other.conversationCanceled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, conversationCanceled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DirectMessageRecallResponseDto')
          ..add('message', message)
          ..add('conversationCanceled', conversationCanceled))
        .toString();
  }
}

class DirectMessageRecallResponseDtoBuilder
    implements
        Builder<
          DirectMessageRecallResponseDto,
          DirectMessageRecallResponseDtoBuilder
        > {
  _$DirectMessageRecallResponseDto? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  bool? _conversationCanceled;
  bool? get conversationCanceled => _$this._conversationCanceled;
  set conversationCanceled(bool? conversationCanceled) =>
      _$this._conversationCanceled = conversationCanceled;

  DirectMessageRecallResponseDtoBuilder() {
    DirectMessageRecallResponseDto._defaults(this);
  }

  DirectMessageRecallResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _conversationCanceled = $v.conversationCanceled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DirectMessageRecallResponseDto other) {
    _$v = other as _$DirectMessageRecallResponseDto;
  }

  @override
  void update(void Function(DirectMessageRecallResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DirectMessageRecallResponseDto build() => _build();

  _$DirectMessageRecallResponseDto _build() {
    final _$result =
        _$v ??
        _$DirectMessageRecallResponseDto._(
          message: BuiltValueNullFieldError.checkNotNull(
            message,
            r'DirectMessageRecallResponseDto',
            'message',
          ),
          conversationCanceled: BuiltValueNullFieldError.checkNotNull(
            conversationCanceled,
            r'DirectMessageRecallResponseDto',
            'conversationCanceled',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
