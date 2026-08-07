//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_upload_url_dto.g.dart';

/// CreateUploadUrlDto
///
/// Properties:
/// * [filename] - 原始文件名
/// * [contentType] - 文件 MIME 类型
/// * [size] - 文件大小（字节），上限 10MB
@BuiltValue()
abstract class CreateUploadUrlDto implements Built<CreateUploadUrlDto, CreateUploadUrlDtoBuilder> {
  /// 原始文件名
  @BuiltValueField(wireName: r'filename')
  String get filename;

  /// 文件 MIME 类型
  @BuiltValueField(wireName: r'contentType')
  CreateUploadUrlDtoContentTypeEnum get contentType;
  // enum contentTypeEnum {  image/jpeg,  image/png,  image/gif,  image/webp,  image/avif,  };

  /// 文件大小（字节），上限 10MB
  @BuiltValueField(wireName: r'size')
  num get size;

  CreateUploadUrlDto._();

  factory CreateUploadUrlDto([void updates(CreateUploadUrlDtoBuilder b)]) = _$CreateUploadUrlDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateUploadUrlDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateUploadUrlDto> get serializer => _$CreateUploadUrlDtoSerializer();
}

class _$CreateUploadUrlDtoSerializer implements PrimitiveSerializer<CreateUploadUrlDto> {
  @override
  final Iterable<Type> types = const [CreateUploadUrlDto, _$CreateUploadUrlDto];

  @override
  final String wireName = r'CreateUploadUrlDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateUploadUrlDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'filename';
    yield serializers.serialize(
      object.filename,
      specifiedType: const FullType(String),
    );
    yield r'contentType';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(CreateUploadUrlDtoContentTypeEnum),
    );
    yield r'size';
    yield serializers.serialize(
      object.size,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateUploadUrlDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateUploadUrlDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'filename':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.filename = valueDes;
          break;
        case r'contentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateUploadUrlDtoContentTypeEnum),
          ) as CreateUploadUrlDtoContentTypeEnum;
          result.contentType = valueDes;
          break;
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.size = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateUploadUrlDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateUploadUrlDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class CreateUploadUrlDtoContentTypeEnum extends EnumClass {

  /// 文件 MIME 类型
  @BuiltValueEnumConst(wireName: r'image/jpeg')
  static const CreateUploadUrlDtoContentTypeEnum imageSlashJpeg = _$createUploadUrlDtoContentTypeEnum_imageSlashJpeg;
  /// 文件 MIME 类型
  @BuiltValueEnumConst(wireName: r'image/png')
  static const CreateUploadUrlDtoContentTypeEnum imageSlashPng = _$createUploadUrlDtoContentTypeEnum_imageSlashPng;
  /// 文件 MIME 类型
  @BuiltValueEnumConst(wireName: r'image/gif')
  static const CreateUploadUrlDtoContentTypeEnum imageSlashGif = _$createUploadUrlDtoContentTypeEnum_imageSlashGif;
  /// 文件 MIME 类型
  @BuiltValueEnumConst(wireName: r'image/webp')
  static const CreateUploadUrlDtoContentTypeEnum imageSlashWebp = _$createUploadUrlDtoContentTypeEnum_imageSlashWebp;
  /// 文件 MIME 类型
  @BuiltValueEnumConst(wireName: r'image/avif')
  static const CreateUploadUrlDtoContentTypeEnum imageSlashAvif = _$createUploadUrlDtoContentTypeEnum_imageSlashAvif;
  /// 文件 MIME 类型
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateUploadUrlDtoContentTypeEnum unknownDefaultOpenApi = _$createUploadUrlDtoContentTypeEnum_unknownDefaultOpenApi;

  static Serializer<CreateUploadUrlDtoContentTypeEnum> get serializer => _$createUploadUrlDtoContentTypeEnumSerializer;

  const CreateUploadUrlDtoContentTypeEnum._(String name): super(name);

  static BuiltSet<CreateUploadUrlDtoContentTypeEnum> get values => _$createUploadUrlDtoContentTypeEnumValues;
  static CreateUploadUrlDtoContentTypeEnum valueOf(String name) => _$createUploadUrlDtoContentTypeEnumValueOf(name);
}
