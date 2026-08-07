// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_sticker_direct_message_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImportStickerDirectMessageDto extends ImportStickerDirectMessageDto {
  @override
  final String directMessageId;
  @override
  final String clientRequestId;

  factory _$ImportStickerDirectMessageDto([
    void Function(ImportStickerDirectMessageDtoBuilder)? updates,
  ]) => (ImportStickerDirectMessageDtoBuilder()..update(updates))._build();

  _$ImportStickerDirectMessageDto._({
    required this.directMessageId,
    required this.clientRequestId,
  }) : super._();
  @override
  ImportStickerDirectMessageDto rebuild(
    void Function(ImportStickerDirectMessageDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ImportStickerDirectMessageDtoBuilder toBuilder() =>
      ImportStickerDirectMessageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImportStickerDirectMessageDto &&
        directMessageId == other.directMessageId &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, directMessageId.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImportStickerDirectMessageDto')
          ..add('directMessageId', directMessageId)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class ImportStickerDirectMessageDtoBuilder
    implements
        Builder<
          ImportStickerDirectMessageDto,
          ImportStickerDirectMessageDtoBuilder
        > {
  _$ImportStickerDirectMessageDto? _$v;

  String? _directMessageId;
  String? get directMessageId => _$this._directMessageId;
  set directMessageId(String? directMessageId) =>
      _$this._directMessageId = directMessageId;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  ImportStickerDirectMessageDtoBuilder() {
    ImportStickerDirectMessageDto._defaults(this);
  }

  ImportStickerDirectMessageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _directMessageId = $v.directMessageId;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImportStickerDirectMessageDto other) {
    _$v = other as _$ImportStickerDirectMessageDto;
  }

  @override
  void update(void Function(ImportStickerDirectMessageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImportStickerDirectMessageDto build() => _build();

  _$ImportStickerDirectMessageDto _build() {
    final _$result =
        _$v ??
        _$ImportStickerDirectMessageDto._(
          directMessageId: BuiltValueNullFieldError.checkNotNull(
            directMessageId,
            r'ImportStickerDirectMessageDto',
            'directMessageId',
          ),
          clientRequestId: BuiltValueNullFieldError.checkNotNull(
            clientRequestId,
            r'ImportStickerDirectMessageDto',
            'clientRequestId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
