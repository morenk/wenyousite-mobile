// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_draft_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateDraftDtoMarkdownContractVersionEnum
_$updateDraftDtoMarkdownContractVersionEnum_n6 =
    const UpdateDraftDtoMarkdownContractVersionEnum._('n6');
const UpdateDraftDtoMarkdownContractVersionEnum
_$updateDraftDtoMarkdownContractVersionEnum_unknownDefaultOpenApi =
    const UpdateDraftDtoMarkdownContractVersionEnum._('unknownDefaultOpenApi');

UpdateDraftDtoMarkdownContractVersionEnum
_$updateDraftDtoMarkdownContractVersionEnumValueOf(String name) {
  switch (name) {
    case 'n6':
      return _$updateDraftDtoMarkdownContractVersionEnum_n6;
    case 'unknownDefaultOpenApi':
      return _$updateDraftDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;
    default:
      return _$updateDraftDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UpdateDraftDtoMarkdownContractVersionEnum>
_$updateDraftDtoMarkdownContractVersionEnumValues =
    BuiltSet<UpdateDraftDtoMarkdownContractVersionEnum>(
      const <UpdateDraftDtoMarkdownContractVersionEnum>[
        _$updateDraftDtoMarkdownContractVersionEnum_n6,
        _$updateDraftDtoMarkdownContractVersionEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UpdateDraftDtoMarkdownContractVersionEnum>
_$updateDraftDtoMarkdownContractVersionEnumSerializer =
    _$UpdateDraftDtoMarkdownContractVersionEnumSerializer();

class _$UpdateDraftDtoMarkdownContractVersionEnumSerializer
    implements PrimitiveSerializer<UpdateDraftDtoMarkdownContractVersionEnum> {
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
    UpdateDraftDtoMarkdownContractVersionEnum,
  ];
  @override
  final String wireName = 'UpdateDraftDtoMarkdownContractVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    UpdateDraftDtoMarkdownContractVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UpdateDraftDtoMarkdownContractVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UpdateDraftDtoMarkdownContractVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UpdateDraftDto extends UpdateDraftDto {
  @override
  final UpdateDraftDtoMarkdownContractVersionEnum? markdownContractVersion;
  @override
  final String content;
  @override
  final num version;

  factory _$UpdateDraftDto([void Function(UpdateDraftDtoBuilder)? updates]) =>
      (UpdateDraftDtoBuilder()..update(updates))._build();

  _$UpdateDraftDto._({
    this.markdownContractVersion,
    required this.content,
    required this.version,
  }) : super._();
  @override
  UpdateDraftDto rebuild(void Function(UpdateDraftDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateDraftDtoBuilder toBuilder() => UpdateDraftDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateDraftDto &&
        markdownContractVersion == other.markdownContractVersion &&
        content == other.content &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, markdownContractVersion.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateDraftDto')
          ..add('markdownContractVersion', markdownContractVersion)
          ..add('content', content)
          ..add('version', version))
        .toString();
  }
}

class UpdateDraftDtoBuilder
    implements Builder<UpdateDraftDto, UpdateDraftDtoBuilder> {
  _$UpdateDraftDto? _$v;

  UpdateDraftDtoMarkdownContractVersionEnum? _markdownContractVersion;
  UpdateDraftDtoMarkdownContractVersionEnum? get markdownContractVersion =>
      _$this._markdownContractVersion;
  set markdownContractVersion(
    UpdateDraftDtoMarkdownContractVersionEnum? markdownContractVersion,
  ) => _$this._markdownContractVersion = markdownContractVersion;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  UpdateDraftDtoBuilder() {
    UpdateDraftDto._defaults(this);
  }

  UpdateDraftDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _markdownContractVersion = $v.markdownContractVersion;
      _content = $v.content;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateDraftDto other) {
    _$v = other as _$UpdateDraftDto;
  }

  @override
  void update(void Function(UpdateDraftDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateDraftDto build() => _build();

  _$UpdateDraftDto _build() {
    final _$result =
        _$v ??
        _$UpdateDraftDto._(
          markdownContractVersion: markdownContractVersion,
          content: BuiltValueNullFieldError.checkNotNull(
            content,
            r'UpdateDraftDto',
            'content',
          ),
          version: BuiltValueNullFieldError.checkNotNull(
            version,
            r'UpdateDraftDto',
            'version',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
