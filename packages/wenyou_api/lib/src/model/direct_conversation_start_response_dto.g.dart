// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversation_start_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DirectConversationStartResponseDto
    extends DirectConversationStartResponseDto {
  @override
  final DirectConversationResponseDto conversation;
  @override
  final DirectMessageResponseDto message;

  factory _$DirectConversationStartResponseDto([
    void Function(DirectConversationStartResponseDtoBuilder)? updates,
  ]) => (DirectConversationStartResponseDtoBuilder()..update(updates))._build();

  _$DirectConversationStartResponseDto._({
    required this.conversation,
    required this.message,
  }) : super._();
  @override
  DirectConversationStartResponseDto rebuild(
    void Function(DirectConversationStartResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationStartResponseDtoBuilder toBuilder() =>
      DirectConversationStartResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationStartResponseDto &&
        conversation == other.conversation &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, conversation.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DirectConversationStartResponseDto')
          ..add('conversation', conversation)
          ..add('message', message))
        .toString();
  }
}

class DirectConversationStartResponseDtoBuilder
    implements
        Builder<
          DirectConversationStartResponseDto,
          DirectConversationStartResponseDtoBuilder
        > {
  _$DirectConversationStartResponseDto? _$v;

  DirectConversationResponseDtoBuilder? _conversation;
  DirectConversationResponseDtoBuilder get conversation =>
      _$this._conversation ??= DirectConversationResponseDtoBuilder();
  set conversation(DirectConversationResponseDtoBuilder? conversation) =>
      _$this._conversation = conversation;

  DirectMessageResponseDtoBuilder? _message;
  DirectMessageResponseDtoBuilder get message =>
      _$this._message ??= DirectMessageResponseDtoBuilder();
  set message(DirectMessageResponseDtoBuilder? message) =>
      _$this._message = message;

  DirectConversationStartResponseDtoBuilder() {
    DirectConversationStartResponseDto._defaults(this);
  }

  DirectConversationStartResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _conversation = $v.conversation.toBuilder();
      _message = $v.message.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DirectConversationStartResponseDto other) {
    _$v = other as _$DirectConversationStartResponseDto;
  }

  @override
  void update(
    void Function(DirectConversationStartResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationStartResponseDto build() => _build();

  _$DirectConversationStartResponseDto _build() {
    _$DirectConversationStartResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationStartResponseDto._(
            conversation: conversation.build(),
            message: message.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'conversation';
        conversation.build();
        _$failedField = 'message';
        message.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DirectConversationStartResponseDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
