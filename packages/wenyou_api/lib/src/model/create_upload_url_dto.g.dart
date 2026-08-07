// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_upload_url_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateUploadUrlDtoContentTypeEnum
_$createUploadUrlDtoContentTypeEnum_imageSlashJpeg =
    const CreateUploadUrlDtoContentTypeEnum._('imageSlashJpeg');
const CreateUploadUrlDtoContentTypeEnum
_$createUploadUrlDtoContentTypeEnum_imageSlashPng =
    const CreateUploadUrlDtoContentTypeEnum._('imageSlashPng');
const CreateUploadUrlDtoContentTypeEnum
_$createUploadUrlDtoContentTypeEnum_imageSlashGif =
    const CreateUploadUrlDtoContentTypeEnum._('imageSlashGif');
const CreateUploadUrlDtoContentTypeEnum
_$createUploadUrlDtoContentTypeEnum_imageSlashWebp =
    const CreateUploadUrlDtoContentTypeEnum._('imageSlashWebp');
const CreateUploadUrlDtoContentTypeEnum
_$createUploadUrlDtoContentTypeEnum_imageSlashAvif =
    const CreateUploadUrlDtoContentTypeEnum._('imageSlashAvif');
const CreateUploadUrlDtoContentTypeEnum
_$createUploadUrlDtoContentTypeEnum_unknownDefaultOpenApi =
    const CreateUploadUrlDtoContentTypeEnum._('unknownDefaultOpenApi');

CreateUploadUrlDtoContentTypeEnum _$createUploadUrlDtoContentTypeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'imageSlashJpeg':
      return _$createUploadUrlDtoContentTypeEnum_imageSlashJpeg;
    case 'imageSlashPng':
      return _$createUploadUrlDtoContentTypeEnum_imageSlashPng;
    case 'imageSlashGif':
      return _$createUploadUrlDtoContentTypeEnum_imageSlashGif;
    case 'imageSlashWebp':
      return _$createUploadUrlDtoContentTypeEnum_imageSlashWebp;
    case 'imageSlashAvif':
      return _$createUploadUrlDtoContentTypeEnum_imageSlashAvif;
    case 'unknownDefaultOpenApi':
      return _$createUploadUrlDtoContentTypeEnum_unknownDefaultOpenApi;
    default:
      return _$createUploadUrlDtoContentTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CreateUploadUrlDtoContentTypeEnum>
_$createUploadUrlDtoContentTypeEnumValues =
    BuiltSet<CreateUploadUrlDtoContentTypeEnum>(
      const <CreateUploadUrlDtoContentTypeEnum>[
        _$createUploadUrlDtoContentTypeEnum_imageSlashJpeg,
        _$createUploadUrlDtoContentTypeEnum_imageSlashPng,
        _$createUploadUrlDtoContentTypeEnum_imageSlashGif,
        _$createUploadUrlDtoContentTypeEnum_imageSlashWebp,
        _$createUploadUrlDtoContentTypeEnum_imageSlashAvif,
        _$createUploadUrlDtoContentTypeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<CreateUploadUrlDtoContentTypeEnum>
_$createUploadUrlDtoContentTypeEnumSerializer =
    _$CreateUploadUrlDtoContentTypeEnumSerializer();

class _$CreateUploadUrlDtoContentTypeEnumSerializer
    implements PrimitiveSerializer<CreateUploadUrlDtoContentTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'imageSlashJpeg': 'image/jpeg',
    'imageSlashPng': 'image/png',
    'imageSlashGif': 'image/gif',
    'imageSlashWebp': 'image/webp',
    'imageSlashAvif': 'image/avif',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'image/jpeg': 'imageSlashJpeg',
    'image/png': 'imageSlashPng',
    'image/gif': 'imageSlashGif',
    'image/webp': 'imageSlashWebp',
    'image/avif': 'imageSlashAvif',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[CreateUploadUrlDtoContentTypeEnum];
  @override
  final String wireName = 'CreateUploadUrlDtoContentTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreateUploadUrlDtoContentTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreateUploadUrlDtoContentTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreateUploadUrlDtoContentTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreateUploadUrlDto extends CreateUploadUrlDto {
  @override
  final String filename;
  @override
  final CreateUploadUrlDtoContentTypeEnum contentType;
  @override
  final num size;

  factory _$CreateUploadUrlDto([
    void Function(CreateUploadUrlDtoBuilder)? updates,
  ]) => (CreateUploadUrlDtoBuilder()..update(updates))._build();

  _$CreateUploadUrlDto._({
    required this.filename,
    required this.contentType,
    required this.size,
  }) : super._();
  @override
  CreateUploadUrlDto rebuild(
    void Function(CreateUploadUrlDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateUploadUrlDtoBuilder toBuilder() =>
      CreateUploadUrlDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateUploadUrlDto &&
        filename == other.filename &&
        contentType == other.contentType &&
        size == other.size;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, filename.hashCode);
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateUploadUrlDto')
          ..add('filename', filename)
          ..add('contentType', contentType)
          ..add('size', size))
        .toString();
  }
}

class CreateUploadUrlDtoBuilder
    implements Builder<CreateUploadUrlDto, CreateUploadUrlDtoBuilder> {
  _$CreateUploadUrlDto? _$v;

  String? _filename;
  String? get filename => _$this._filename;
  set filename(String? filename) => _$this._filename = filename;

  CreateUploadUrlDtoContentTypeEnum? _contentType;
  CreateUploadUrlDtoContentTypeEnum? get contentType => _$this._contentType;
  set contentType(CreateUploadUrlDtoContentTypeEnum? contentType) =>
      _$this._contentType = contentType;

  num? _size;
  num? get size => _$this._size;
  set size(num? size) => _$this._size = size;

  CreateUploadUrlDtoBuilder() {
    CreateUploadUrlDto._defaults(this);
  }

  CreateUploadUrlDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _filename = $v.filename;
      _contentType = $v.contentType;
      _size = $v.size;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateUploadUrlDto other) {
    _$v = other as _$CreateUploadUrlDto;
  }

  @override
  void update(void Function(CreateUploadUrlDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateUploadUrlDto build() => _build();

  _$CreateUploadUrlDto _build() {
    final _$result =
        _$v ??
        _$CreateUploadUrlDto._(
          filename: BuiltValueNullFieldError.checkNotNull(
            filename,
            r'CreateUploadUrlDto',
            'filename',
          ),
          contentType: BuiltValueNullFieldError.checkNotNull(
            contentType,
            r'CreateUploadUrlDto',
            'contentType',
          ),
          size: BuiltValueNullFieldError.checkNotNull(
            size,
            r'CreateUploadUrlDto',
            'size',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
