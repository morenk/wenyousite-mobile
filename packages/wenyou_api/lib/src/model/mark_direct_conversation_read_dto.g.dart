// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mark_direct_conversation_read_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MarkDirectConversationReadDto extends MarkDirectConversationReadDto {
  @override
  final String throughMessageId;

  factory _$MarkDirectConversationReadDto([
    void Function(MarkDirectConversationReadDtoBuilder)? updates,
  ]) => (MarkDirectConversationReadDtoBuilder()..update(updates))._build();

  _$MarkDirectConversationReadDto._({required this.throughMessageId})
    : super._();
  @override
  MarkDirectConversationReadDto rebuild(
    void Function(MarkDirectConversationReadDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MarkDirectConversationReadDtoBuilder toBuilder() =>
      MarkDirectConversationReadDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MarkDirectConversationReadDto &&
        throughMessageId == other.throughMessageId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, throughMessageId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'MarkDirectConversationReadDto',
    )..add('throughMessageId', throughMessageId)).toString();
  }
}

class MarkDirectConversationReadDtoBuilder
    implements
        Builder<
          MarkDirectConversationReadDto,
          MarkDirectConversationReadDtoBuilder
        > {
  _$MarkDirectConversationReadDto? _$v;

  String? _throughMessageId;
  String? get throughMessageId => _$this._throughMessageId;
  set throughMessageId(String? throughMessageId) =>
      _$this._throughMessageId = throughMessageId;

  MarkDirectConversationReadDtoBuilder() {
    MarkDirectConversationReadDto._defaults(this);
  }

  MarkDirectConversationReadDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _throughMessageId = $v.throughMessageId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MarkDirectConversationReadDto other) {
    _$v = other as _$MarkDirectConversationReadDto;
  }

  @override
  void update(void Function(MarkDirectConversationReadDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MarkDirectConversationReadDto build() => _build();

  _$MarkDirectConversationReadDto _build() {
    final _$result =
        _$v ??
        _$MarkDirectConversationReadDto._(
          throughMessageId: BuiltValueNullFieldError.checkNotNull(
            throughMessageId,
            r'MarkDirectConversationReadDto',
            'throughMessageId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
