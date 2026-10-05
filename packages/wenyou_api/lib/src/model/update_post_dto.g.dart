// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_post_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdatePostDtoMarkdownContractVersionEnum
_$updatePostDtoMarkdownContractVersionEnum_n6 =
    const UpdatePostDtoMarkdownContractVersionEnum._('n6');
const UpdatePostDtoMarkdownContractVersionEnum
_$updatePostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi =
    const UpdatePostDtoMarkdownContractVersionEnum._('unknownDefaultOpenApi');

UpdatePostDtoMarkdownContractVersionEnum
_$updatePostDtoMarkdownContractVersionEnumValueOf(String name) {
  switch (name) {
    case 'n6':
      return _$updatePostDtoMarkdownContractVersionEnum_n6;
    case 'unknownDefaultOpenApi':
      return _$updatePostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;
    default:
      return _$updatePostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UpdatePostDtoMarkdownContractVersionEnum>
_$updatePostDtoMarkdownContractVersionEnumValues =
    BuiltSet<UpdatePostDtoMarkdownContractVersionEnum>(
      const <UpdatePostDtoMarkdownContractVersionEnum>[
        _$updatePostDtoMarkdownContractVersionEnum_n6,
        _$updatePostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UpdatePostDtoMarkdownContractVersionEnum>
_$updatePostDtoMarkdownContractVersionEnumSerializer =
    _$UpdatePostDtoMarkdownContractVersionEnumSerializer();

class _$UpdatePostDtoMarkdownContractVersionEnumSerializer
    implements PrimitiveSerializer<UpdatePostDtoMarkdownContractVersionEnum> {
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
    UpdatePostDtoMarkdownContractVersionEnum,
  ];
  @override
  final String wireName = 'UpdatePostDtoMarkdownContractVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    UpdatePostDtoMarkdownContractVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UpdatePostDtoMarkdownContractVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UpdatePostDtoMarkdownContractVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UpdatePostDto extends UpdatePostDto {
  @override
  final UpdatePostDtoMarkdownContractVersionEnum? markdownContractVersion;
  @override
  final String content;
  @override
  final num version;

  factory _$UpdatePostDto([void Function(UpdatePostDtoBuilder)? updates]) =>
      (UpdatePostDtoBuilder()..update(updates))._build();

  _$UpdatePostDto._({
    this.markdownContractVersion,
    required this.content,
    required this.version,
  }) : super._();
  @override
  UpdatePostDto rebuild(void Function(UpdatePostDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdatePostDtoBuilder toBuilder() => UpdatePostDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdatePostDto &&
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
    return (newBuiltValueToStringHelper(r'UpdatePostDto')
          ..add('markdownContractVersion', markdownContractVersion)
          ..add('content', content)
          ..add('version', version))
        .toString();
  }
}

class UpdatePostDtoBuilder
    implements Builder<UpdatePostDto, UpdatePostDtoBuilder> {
  _$UpdatePostDto? _$v;

  UpdatePostDtoMarkdownContractVersionEnum? _markdownContractVersion;
  UpdatePostDtoMarkdownContractVersionEnum? get markdownContractVersion =>
      _$this._markdownContractVersion;
  set markdownContractVersion(
    UpdatePostDtoMarkdownContractVersionEnum? markdownContractVersion,
  ) => _$this._markdownContractVersion = markdownContractVersion;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  UpdatePostDtoBuilder() {
    UpdatePostDto._defaults(this);
  }

  UpdatePostDtoBuilder get _$this {
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
  void replace(UpdatePostDto other) {
    _$v = other as _$UpdatePostDto;
  }

  @override
  void update(void Function(UpdatePostDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdatePostDto build() => _build();

  _$UpdatePostDto _build() {
    final _$result =
        _$v ??
        _$UpdatePostDto._(
          markdownContractVersion: markdownContractVersion,
          content: BuiltValueNullFieldError.checkNotNull(
            content,
            r'UpdatePostDto',
            'content',
          ),
          version: BuiltValueNullFieldError.checkNotNull(
            version,
            r'UpdatePostDto',
            'version',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
