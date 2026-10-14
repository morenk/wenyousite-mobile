// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_draft_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateDraftDtoMarkdownContractVersionEnum
_$createDraftDtoMarkdownContractVersionEnum_number6 =
    const CreateDraftDtoMarkdownContractVersionEnum._('number6');
const CreateDraftDtoMarkdownContractVersionEnum
_$createDraftDtoMarkdownContractVersionEnum_unknownDefaultOpenApi =
    const CreateDraftDtoMarkdownContractVersionEnum._('unknownDefaultOpenApi');

CreateDraftDtoMarkdownContractVersionEnum
_$createDraftDtoMarkdownContractVersionEnumValueOf(String name) {
  switch (name) {
    case 'number6':
      return _$createDraftDtoMarkdownContractVersionEnum_number6;
    case 'unknownDefaultOpenApi':
      return _$createDraftDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;
    default:
      return _$createDraftDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CreateDraftDtoMarkdownContractVersionEnum>
_$createDraftDtoMarkdownContractVersionEnumValues =
    BuiltSet<CreateDraftDtoMarkdownContractVersionEnum>(
      const <CreateDraftDtoMarkdownContractVersionEnum>[
        _$createDraftDtoMarkdownContractVersionEnum_number6,
        _$createDraftDtoMarkdownContractVersionEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<CreateDraftDtoMarkdownContractVersionEnum>
_$createDraftDtoMarkdownContractVersionEnumSerializer =
    _$CreateDraftDtoMarkdownContractVersionEnumSerializer();

class _$CreateDraftDtoMarkdownContractVersionEnumSerializer
    implements PrimitiveSerializer<CreateDraftDtoMarkdownContractVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number6': 6,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    6: 'number6',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    CreateDraftDtoMarkdownContractVersionEnum,
  ];
  @override
  final String wireName = 'CreateDraftDtoMarkdownContractVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreateDraftDtoMarkdownContractVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreateDraftDtoMarkdownContractVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreateDraftDtoMarkdownContractVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreateDraftDto extends CreateDraftDto {
  @override
  final CreateDraftDtoMarkdownContractVersionEnum? markdownContractVersion;
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
    this.markdownContractVersion,
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
        markdownContractVersion == other.markdownContractVersion &&
        clientRequestId == other.clientRequestId &&
        content == other.content &&
        slot == other.slot &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, markdownContractVersion.hashCode);
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
          ..add('markdownContractVersion', markdownContractVersion)
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

  CreateDraftDtoMarkdownContractVersionEnum? _markdownContractVersion;
  CreateDraftDtoMarkdownContractVersionEnum? get markdownContractVersion =>
      _$this._markdownContractVersion;
  set markdownContractVersion(
    CreateDraftDtoMarkdownContractVersionEnum? markdownContractVersion,
  ) => _$this._markdownContractVersion = markdownContractVersion;

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
      _markdownContractVersion = $v.markdownContractVersion;
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
          markdownContractVersion: markdownContractVersion,
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
