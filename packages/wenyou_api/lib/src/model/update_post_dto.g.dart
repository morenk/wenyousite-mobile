// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_post_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdatePostDtoTextColorVersionEnum
_$updatePostDtoTextColorVersionEnum_number1 =
    const UpdatePostDtoTextColorVersionEnum._('number1');
const UpdatePostDtoTextColorVersionEnum
_$updatePostDtoTextColorVersionEnum_unknownDefaultOpenApi =
    const UpdatePostDtoTextColorVersionEnum._('unknownDefaultOpenApi');

UpdatePostDtoTextColorVersionEnum _$updatePostDtoTextColorVersionEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number1':
      return _$updatePostDtoTextColorVersionEnum_number1;
    case 'unknownDefaultOpenApi':
      return _$updatePostDtoTextColorVersionEnum_unknownDefaultOpenApi;
    default:
      return _$updatePostDtoTextColorVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UpdatePostDtoTextColorVersionEnum>
_$updatePostDtoTextColorVersionEnumValues =
    BuiltSet<UpdatePostDtoTextColorVersionEnum>(
      const <UpdatePostDtoTextColorVersionEnum>[
        _$updatePostDtoTextColorVersionEnum_number1,
        _$updatePostDtoTextColorVersionEnum_unknownDefaultOpenApi,
      ],
    );

const UpdatePostDtoMarkdownContractVersionEnum
_$updatePostDtoMarkdownContractVersionEnum_number6 =
    const UpdatePostDtoMarkdownContractVersionEnum._('number6');
const UpdatePostDtoMarkdownContractVersionEnum
_$updatePostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi =
    const UpdatePostDtoMarkdownContractVersionEnum._('unknownDefaultOpenApi');

UpdatePostDtoMarkdownContractVersionEnum
_$updatePostDtoMarkdownContractVersionEnumValueOf(String name) {
  switch (name) {
    case 'number6':
      return _$updatePostDtoMarkdownContractVersionEnum_number6;
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
        _$updatePostDtoMarkdownContractVersionEnum_number6,
        _$updatePostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UpdatePostDtoTextColorVersionEnum>
_$updatePostDtoTextColorVersionEnumSerializer =
    _$UpdatePostDtoTextColorVersionEnumSerializer();
Serializer<UpdatePostDtoMarkdownContractVersionEnum>
_$updatePostDtoMarkdownContractVersionEnumSerializer =
    _$UpdatePostDtoMarkdownContractVersionEnumSerializer();

class _$UpdatePostDtoTextColorVersionEnumSerializer
    implements PrimitiveSerializer<UpdatePostDtoTextColorVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number1': 1,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'number1',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[UpdatePostDtoTextColorVersionEnum];
  @override
  final String wireName = 'UpdatePostDtoTextColorVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    UpdatePostDtoTextColorVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UpdatePostDtoTextColorVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UpdatePostDtoTextColorVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UpdatePostDtoMarkdownContractVersionEnumSerializer
    implements PrimitiveSerializer<UpdatePostDtoMarkdownContractVersionEnum> {
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
  final UpdatePostDtoTextColorVersionEnum? textColorVersion;
  @override
  final UpdatePostDtoMarkdownContractVersionEnum? markdownContractVersion;
  @override
  final String content;
  @override
  final num version;

  factory _$UpdatePostDto([void Function(UpdatePostDtoBuilder)? updates]) =>
      (UpdatePostDtoBuilder()..update(updates))._build();

  _$UpdatePostDto._({
    this.textColorVersion,
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
        textColorVersion == other.textColorVersion &&
        markdownContractVersion == other.markdownContractVersion &&
        content == other.content &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, textColorVersion.hashCode);
    _$hash = $jc(_$hash, markdownContractVersion.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdatePostDto')
          ..add('textColorVersion', textColorVersion)
          ..add('markdownContractVersion', markdownContractVersion)
          ..add('content', content)
          ..add('version', version))
        .toString();
  }
}

class UpdatePostDtoBuilder
    implements Builder<UpdatePostDto, UpdatePostDtoBuilder> {
  _$UpdatePostDto? _$v;

  UpdatePostDtoTextColorVersionEnum? _textColorVersion;
  UpdatePostDtoTextColorVersionEnum? get textColorVersion =>
      _$this._textColorVersion;
  set textColorVersion(UpdatePostDtoTextColorVersionEnum? textColorVersion) =>
      _$this._textColorVersion = textColorVersion;

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
      _textColorVersion = $v.textColorVersion;
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
          textColorVersion: textColorVersion,
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
