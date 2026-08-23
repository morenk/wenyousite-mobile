// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_draft_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateDraftDto extends CreateDraftDto {
  @override
  final String? clientRequestId;
  @override
  final String content;
  @override
  final num? slot;
  @override
  final num? version;

  factory _$CreateDraftDto([void Function(CreateDraftDtoBuilder)? updates]) =>
      (CreateDraftDtoBuilder()..update(updates))._build();

  _$CreateDraftDto._({
    this.clientRequestId,
    required this.content,
    this.slot,
    this.version,
  }) : super._();
  @override
  CreateDraftDto rebuild(void Function(CreateDraftDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateDraftDtoBuilder toBuilder() => CreateDraftDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateDraftDto &&
        clientRequestId == other.clientRequestId &&
        content == other.content &&
        slot == other.slot &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateDraftDto')
          ..add('clientRequestId', clientRequestId)
          ..add('content', content)
          ..add('slot', slot)
          ..add('version', version))
        .toString();
  }
}

class CreateDraftDtoBuilder
    implements Builder<CreateDraftDto, CreateDraftDtoBuilder> {
  _$CreateDraftDto? _$v;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  num? _slot;
  num? get slot => _$this._slot;
  set slot(num? slot) => _$this._slot = slot;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  CreateDraftDtoBuilder() {
    CreateDraftDto._defaults(this);
  }

  CreateDraftDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientRequestId = $v.clientRequestId;
      _content = $v.content;
      _slot = $v.slot;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateDraftDto other) {
    _$v = other as _$CreateDraftDto;
  }

  @override
  void update(void Function(CreateDraftDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateDraftDto build() => _build();

  _$CreateDraftDto _build() {
    final _$result =
        _$v ??
        _$CreateDraftDto._(
          clientRequestId: clientRequestId,
          content: BuiltValueNullFieldError.checkNotNull(
            content,
            r'CreateDraftDto',
            'content',
          ),
          slot: slot,
          version: version,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
