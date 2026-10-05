// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreatePostDtoMarkdownContractVersionEnum
_$createPostDtoMarkdownContractVersionEnum_n6 =
    const CreatePostDtoMarkdownContractVersionEnum._('n6');
const CreatePostDtoMarkdownContractVersionEnum
_$createPostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi =
    const CreatePostDtoMarkdownContractVersionEnum._('unknownDefaultOpenApi');

CreatePostDtoMarkdownContractVersionEnum
_$createPostDtoMarkdownContractVersionEnumValueOf(String name) {
  switch (name) {
    case 'n6':
      return _$createPostDtoMarkdownContractVersionEnum_n6;
    case 'unknownDefaultOpenApi':
      return _$createPostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;
    default:
      return _$createPostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CreatePostDtoMarkdownContractVersionEnum>
_$createPostDtoMarkdownContractVersionEnumValues =
    BuiltSet<CreatePostDtoMarkdownContractVersionEnum>(
      const <CreatePostDtoMarkdownContractVersionEnum>[
        _$createPostDtoMarkdownContractVersionEnum_n6,
        _$createPostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi,
      ],
    );

const CreatePostDtoIdentityModeEnum _$createPostDtoIdentityModeEnum_ACCOUNT =
    const CreatePostDtoIdentityModeEnum._('ACCOUNT');
const CreatePostDtoIdentityModeEnum _$createPostDtoIdentityModeEnum_RP =
    const CreatePostDtoIdentityModeEnum._('RP');
const CreatePostDtoIdentityModeEnum
_$createPostDtoIdentityModeEnum_unknownDefaultOpenApi =
    const CreatePostDtoIdentityModeEnum._('unknownDefaultOpenApi');

CreatePostDtoIdentityModeEnum _$createPostDtoIdentityModeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'ACCOUNT':
      return _$createPostDtoIdentityModeEnum_ACCOUNT;
    case 'RP':
      return _$createPostDtoIdentityModeEnum_RP;
    case 'unknownDefaultOpenApi':
      return _$createPostDtoIdentityModeEnum_unknownDefaultOpenApi;
    default:
      return _$createPostDtoIdentityModeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CreatePostDtoIdentityModeEnum>
_$createPostDtoIdentityModeEnumValues = BuiltSet<CreatePostDtoIdentityModeEnum>(
  const <CreatePostDtoIdentityModeEnum>[
    _$createPostDtoIdentityModeEnum_ACCOUNT,
    _$createPostDtoIdentityModeEnum_RP,
    _$createPostDtoIdentityModeEnum_unknownDefaultOpenApi,
  ],
);

Serializer<CreatePostDtoMarkdownContractVersionEnum>
_$createPostDtoMarkdownContractVersionEnumSerializer =
    _$CreatePostDtoMarkdownContractVersionEnumSerializer();
Serializer<CreatePostDtoIdentityModeEnum>
_$createPostDtoIdentityModeEnumSerializer =
    _$CreatePostDtoIdentityModeEnumSerializer();

class _$CreatePostDtoMarkdownContractVersionEnumSerializer
    implements PrimitiveSerializer<CreatePostDtoMarkdownContractVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n6': '6',
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '6': 'n6',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    CreatePostDtoMarkdownContractVersionEnum,
  ];
  @override
  final String wireName = 'CreatePostDtoMarkdownContractVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreatePostDtoMarkdownContractVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreatePostDtoMarkdownContractVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreatePostDtoMarkdownContractVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreatePostDtoIdentityModeEnumSerializer
    implements PrimitiveSerializer<CreatePostDtoIdentityModeEnum> {
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
  final Iterable<Type> types = const <Type>[CreatePostDtoIdentityModeEnum];
  @override
  final String wireName = 'CreatePostDtoIdentityModeEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreatePostDtoIdentityModeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreatePostDtoIdentityModeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreatePostDtoIdentityModeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreatePostDto extends CreatePostDto {
  @override
  final CreatePostDtoMarkdownContractVersionEnum? markdownContractVersion;
  @override
  final String? identityId;
  @override
  final String? identityToken;
  @override
  final CreatePostDtoIdentityModeEnum? identityMode;
  @override
  final String content;
  @override
  final String? parentPostId;
  @override
  final String? replyToPostId;
  @override
  final String? clientRequestId;

  factory _$CreatePostDto([void Function(CreatePostDtoBuilder)? updates]) =>
      (CreatePostDtoBuilder()..update(updates))._build();

  _$CreatePostDto._({
    this.markdownContractVersion,
    this.identityId,
    this.identityToken,
    this.identityMode,
    required this.content,
    this.parentPostId,
    this.replyToPostId,
    this.clientRequestId,
  }) : super._();
  @override
  CreatePostDto rebuild(void Function(CreatePostDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreatePostDtoBuilder toBuilder() => CreatePostDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreatePostDto &&
        markdownContractVersion == other.markdownContractVersion &&
        identityId == other.identityId &&
        identityToken == other.identityToken &&
        identityMode == other.identityMode &&
        content == other.content &&
        parentPostId == other.parentPostId &&
        replyToPostId == other.replyToPostId &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, markdownContractVersion.hashCode);
    _$hash = $jc(_$hash, identityId.hashCode);
    _$hash = $jc(_$hash, identityToken.hashCode);
    _$hash = $jc(_$hash, identityMode.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, parentPostId.hashCode);
    _$hash = $jc(_$hash, replyToPostId.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreatePostDto')
          ..add('markdownContractVersion', markdownContractVersion)
          ..add('identityId', identityId)
          ..add('identityToken', identityToken)
          ..add('identityMode', identityMode)
          ..add('content', content)
          ..add('parentPostId', parentPostId)
          ..add('replyToPostId', replyToPostId)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class CreatePostDtoBuilder
    implements Builder<CreatePostDto, CreatePostDtoBuilder> {
  _$CreatePostDto? _$v;

  CreatePostDtoMarkdownContractVersionEnum? _markdownContractVersion;
  CreatePostDtoMarkdownContractVersionEnum? get markdownContractVersion =>
      _$this._markdownContractVersion;
  set markdownContractVersion(
    CreatePostDtoMarkdownContractVersionEnum? markdownContractVersion,
  ) => _$this._markdownContractVersion = markdownContractVersion;

  String? _identityId;
  String? get identityId => _$this._identityId;
  set identityId(String? identityId) => _$this._identityId = identityId;

  String? _identityToken;
  String? get identityToken => _$this._identityToken;
  set identityToken(String? identityToken) =>
      _$this._identityToken = identityToken;

  CreatePostDtoIdentityModeEnum? _identityMode;
  CreatePostDtoIdentityModeEnum? get identityMode => _$this._identityMode;
  set identityMode(CreatePostDtoIdentityModeEnum? identityMode) =>
      _$this._identityMode = identityMode;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _parentPostId;
  String? get parentPostId => _$this._parentPostId;
  set parentPostId(String? parentPostId) => _$this._parentPostId = parentPostId;

  String? _replyToPostId;
  String? get replyToPostId => _$this._replyToPostId;
  set replyToPostId(String? replyToPostId) =>
      _$this._replyToPostId = replyToPostId;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  CreatePostDtoBuilder() {
    CreatePostDto._defaults(this);
  }

  CreatePostDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _markdownContractVersion = $v.markdownContractVersion;
      _identityId = $v.identityId;
      _identityToken = $v.identityToken;
      _identityMode = $v.identityMode;
      _content = $v.content;
      _parentPostId = $v.parentPostId;
      _replyToPostId = $v.replyToPostId;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreatePostDto other) {
    _$v = other as _$CreatePostDto;
  }

  @override
  void update(void Function(CreatePostDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreatePostDto build() => _build();

  _$CreatePostDto _build() {
    final _$result =
        _$v ??
        _$CreatePostDto._(
          markdownContractVersion: markdownContractVersion,
          identityId: identityId,
          identityToken: identityToken,
          identityMode: identityMode,
          content: BuiltValueNullFieldError.checkNotNull(
            content,
            r'CreatePostDto',
            'content',
          ),
          parentPostId: parentPostId,
          replyToPostId: replyToPostId,
          clientRequestId: clientRequestId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
