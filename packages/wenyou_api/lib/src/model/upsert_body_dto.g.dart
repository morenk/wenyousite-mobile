// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_body_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpsertBodyDtoMarkdownContractVersionEnum
_$upsertBodyDtoMarkdownContractVersionEnum_number6 =
    const UpsertBodyDtoMarkdownContractVersionEnum._('number6');
const UpsertBodyDtoMarkdownContractVersionEnum
_$upsertBodyDtoMarkdownContractVersionEnum_unknownDefaultOpenApi =
    const UpsertBodyDtoMarkdownContractVersionEnum._('unknownDefaultOpenApi');

UpsertBodyDtoMarkdownContractVersionEnum
_$upsertBodyDtoMarkdownContractVersionEnumValueOf(String name) {
  switch (name) {
    case 'number6':
      return _$upsertBodyDtoMarkdownContractVersionEnum_number6;
    case 'unknownDefaultOpenApi':
      return _$upsertBodyDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;
    default:
      return _$upsertBodyDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UpsertBodyDtoMarkdownContractVersionEnum>
_$upsertBodyDtoMarkdownContractVersionEnumValues =
    BuiltSet<UpsertBodyDtoMarkdownContractVersionEnum>(
      const <UpsertBodyDtoMarkdownContractVersionEnum>[
        _$upsertBodyDtoMarkdownContractVersionEnum_number6,
        _$upsertBodyDtoMarkdownContractVersionEnum_unknownDefaultOpenApi,
      ],
    );

const UpsertBodyDtoIdentityModeEnum _$upsertBodyDtoIdentityModeEnum_ACCOUNT =
    const UpsertBodyDtoIdentityModeEnum._('ACCOUNT');
const UpsertBodyDtoIdentityModeEnum _$upsertBodyDtoIdentityModeEnum_RP =
    const UpsertBodyDtoIdentityModeEnum._('RP');
const UpsertBodyDtoIdentityModeEnum
_$upsertBodyDtoIdentityModeEnum_unknownDefaultOpenApi =
    const UpsertBodyDtoIdentityModeEnum._('unknownDefaultOpenApi');

UpsertBodyDtoIdentityModeEnum _$upsertBodyDtoIdentityModeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'ACCOUNT':
      return _$upsertBodyDtoIdentityModeEnum_ACCOUNT;
    case 'RP':
      return _$upsertBodyDtoIdentityModeEnum_RP;
    case 'unknownDefaultOpenApi':
      return _$upsertBodyDtoIdentityModeEnum_unknownDefaultOpenApi;
    default:
      return _$upsertBodyDtoIdentityModeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UpsertBodyDtoIdentityModeEnum>
_$upsertBodyDtoIdentityModeEnumValues = BuiltSet<UpsertBodyDtoIdentityModeEnum>(
  const <UpsertBodyDtoIdentityModeEnum>[
    _$upsertBodyDtoIdentityModeEnum_ACCOUNT,
    _$upsertBodyDtoIdentityModeEnum_RP,
    _$upsertBodyDtoIdentityModeEnum_unknownDefaultOpenApi,
  ],
);

Serializer<UpsertBodyDtoMarkdownContractVersionEnum>
_$upsertBodyDtoMarkdownContractVersionEnumSerializer =
    _$UpsertBodyDtoMarkdownContractVersionEnumSerializer();
Serializer<UpsertBodyDtoIdentityModeEnum>
_$upsertBodyDtoIdentityModeEnumSerializer =
    _$UpsertBodyDtoIdentityModeEnumSerializer();

class _$UpsertBodyDtoMarkdownContractVersionEnumSerializer
    implements PrimitiveSerializer<UpsertBodyDtoMarkdownContractVersionEnum> {
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
    UpsertBodyDtoMarkdownContractVersionEnum,
  ];
  @override
  final String wireName = 'UpsertBodyDtoMarkdownContractVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    UpsertBodyDtoMarkdownContractVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UpsertBodyDtoMarkdownContractVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UpsertBodyDtoMarkdownContractVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UpsertBodyDtoIdentityModeEnumSerializer
    implements PrimitiveSerializer<UpsertBodyDtoIdentityModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ACCOUNT': 'ACCOUNT',
    'RP': 'RP',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ACCOUNT': 'ACCOUNT',
    'RP': 'RP',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[UpsertBodyDtoIdentityModeEnum];
  @override
  final String wireName = 'UpsertBodyDtoIdentityModeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UpsertBodyDtoIdentityModeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UpsertBodyDtoIdentityModeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UpsertBodyDtoIdentityModeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UpsertBodyDto extends UpsertBodyDto {
  @override
  final UpsertBodyDtoMarkdownContractVersionEnum? markdownContractVersion;
  @override
  final String? identityId;
  @override
  final String? identityToken;
  @override
  final UpsertBodyDtoIdentityModeEnum? identityMode;
  @override
  final String content;
  @override
  final num? version;

  factory _$UpsertBodyDto([void Function(UpsertBodyDtoBuilder)? updates]) =>
      (UpsertBodyDtoBuilder()..update(updates))._build();

  _$UpsertBodyDto._({
    this.markdownContractVersion,
    this.identityId,
    this.identityToken,
    this.identityMode,
    required this.content,
    this.version,
  }) : super._();
  @override
  UpsertBodyDto rebuild(void Function(UpsertBodyDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpsertBodyDtoBuilder toBuilder() => UpsertBodyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpsertBodyDto &&
        markdownContractVersion == other.markdownContractVersion &&
        identityId == other.identityId &&
        identityToken == other.identityToken &&
        identityMode == other.identityMode &&
        content == other.content &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, markdownContractVersion.hashCode);
    _$hash = $jc(_$hash, identityId.hashCode);
    _$hash = $jc(_$hash, identityToken.hashCode);
    _$hash = $jc(_$hash, identityMode.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpsertBodyDto')
          ..add('markdownContractVersion', markdownContractVersion)
          ..add('identityId', identityId)
          ..add('identityToken', identityToken)
          ..add('identityMode', identityMode)
          ..add('content', content)
          ..add('version', version))
        .toString();
  }
}

class UpsertBodyDtoBuilder
    implements Builder<UpsertBodyDto, UpsertBodyDtoBuilder> {
  _$UpsertBodyDto? _$v;

  UpsertBodyDtoMarkdownContractVersionEnum? _markdownContractVersion;
  UpsertBodyDtoMarkdownContractVersionEnum? get markdownContractVersion =>
      _$this._markdownContractVersion;
  set markdownContractVersion(
    UpsertBodyDtoMarkdownContractVersionEnum? markdownContractVersion,
  ) => _$this._markdownContractVersion = markdownContractVersion;

  String? _identityId;
  String? get identityId => _$this._identityId;
  set identityId(String? identityId) => _$this._identityId = identityId;

  String? _identityToken;
  String? get identityToken => _$this._identityToken;
  set identityToken(String? identityToken) =>
      _$this._identityToken = identityToken;

  UpsertBodyDtoIdentityModeEnum? _identityMode;
  UpsertBodyDtoIdentityModeEnum? get identityMode => _$this._identityMode;
  set identityMode(UpsertBodyDtoIdentityModeEnum? identityMode) =>
      _$this._identityMode = identityMode;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  UpsertBodyDtoBuilder() {
    UpsertBodyDto._defaults(this);
  }

  UpsertBodyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _markdownContractVersion = $v.markdownContractVersion;
      _identityId = $v.identityId;
      _identityToken = $v.identityToken;
      _identityMode = $v.identityMode;
      _content = $v.content;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpsertBodyDto other) {
    _$v = other as _$UpsertBodyDto;
  }

  @override
  void update(void Function(UpsertBodyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpsertBodyDto build() => _build();

  _$UpsertBodyDto _build() {
    final _$result =
        _$v ??
        _$UpsertBodyDto._(
          markdownContractVersion: markdownContractVersion,
          identityId: identityId,
          identityToken: identityToken,
          identityMode: identityMode,
          content: BuiltValueNullFieldError.checkNotNull(
            content,
            r'UpsertBodyDto',
            'content',
          ),
          version: version,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
