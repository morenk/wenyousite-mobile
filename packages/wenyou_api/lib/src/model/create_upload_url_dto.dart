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
/// * [purpose] - 图片业务用途；旧客户端省略时按 LEGACY 生成全部兼容派生图
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

  /// 图片业务用途；旧客户端省略时按 LEGACY 生成全部兼容派生图
  @BuiltValueField(wireName: r'purpose')
  CreateUploadUrlDtoPurposeEnum? get purpose;
  // enum purposeEnum {  AVATAR,  PROFILE_COVER,  DIRECT_MESSAGE,  MOMENT,  MOMENT_COMMENT,  RICH_CONTENT,  STICKER_SOURCE,  LEGACY,  };

  CreateUploadUrlDto._();

  factory CreateUploadUrlDto([void updates(CreateUploadUrlDtoBuilder b)]) = _$CreateUploadUrlDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateUploadUrlDtoBuilder b) => b
      ..purpose = CreateUploadUrlDtoPurposeEnum.valueOf('LEGACY');

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
    if (object.purpose != null) {
      yield r'purpose';
      yield serializers.serialize(
        object.purpose,
        specifiedType: const FullType(CreateUploadUrlDtoPurposeEnum),
      );
    }
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
        case r'purpose':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateUploadUrlDtoPurposeEnum),
          ) as CreateUploadUrlDtoPurposeEnum;
          result.purpose = valueDes;
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

class CreateUploadUrlDtoPurposeEnum extends EnumClass {

  /// 图片业务用途；旧客户端省略时按 LEGACY 生成全部兼容派生图
  @BuiltValueEnumConst(wireName: r'AVATAR')
  static const CreateUploadUrlDtoPurposeEnum AVATAR = _$createUploadUrlDtoPurposeEnum_AVATAR;
  /// 图片业务用途；旧客户端省略时按 LEGACY 生成全部兼容派生图
  @BuiltValueEnumConst(wireName: r'PROFILE_COVER')
  static const CreateUploadUrlDtoPurposeEnum PROFILE_COVER = _$createUploadUrlDtoPurposeEnum_PROFILE_COVER;
  /// 图片业务用途；旧客户端省略时按 LEGACY 生成全部兼容派生图
  @BuiltValueEnumConst(wireName: r'DIRECT_MESSAGE')
  static const CreateUploadUrlDtoPurposeEnum DIRECT_MESSAGE = _$createUploadUrlDtoPurposeEnum_DIRECT_MESSAGE;
  /// 图片业务用途；旧客户端省略时按 LEGACY 生成全部兼容派生图
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const CreateUploadUrlDtoPurposeEnum MOMENT = _$createUploadUrlDtoPurposeEnum_MOMENT;
  /// 图片业务用途；旧客户端省略时按 LEGACY 生成全部兼容派生图
  @BuiltValueEnumConst(wireName: r'MOMENT_COMMENT')
  static const CreateUploadUrlDtoPurposeEnum MOMENT_COMMENT = _$createUploadUrlDtoPurposeEnum_MOMENT_COMMENT;
  /// 图片业务用途；旧客户端省略时按 LEGACY 生成全部兼容派生图
  @BuiltValueEnumConst(wireName: r'RICH_CONTENT')
  static const CreateUploadUrlDtoPurposeEnum RICH_CONTENT = _$createUploadUrlDtoPurposeEnum_RICH_CONTENT;
  /// 图片业务用途；旧客户端省略时按 LEGACY 生成全部兼容派生图
  @BuiltValueEnumConst(wireName: r'STICKER_SOURCE')
  static const CreateUploadUrlDtoPurposeEnum STICKER_SOURCE = _$createUploadUrlDtoPurposeEnum_STICKER_SOURCE;
  /// 图片业务用途；旧客户端省略时按 LEGACY 生成全部兼容派生图
  @BuiltValueEnumConst(wireName: r'LEGACY')
  static const CreateUploadUrlDtoPurposeEnum LEGACY = _$createUploadUrlDtoPurposeEnum_LEGACY;
  /// 图片业务用途；旧客户端省略时按 LEGACY 生成全部兼容派生图
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateUploadUrlDtoPurposeEnum unknownDefaultOpenApi = _$createUploadUrlDtoPurposeEnum_unknownDefaultOpenApi;

  static Serializer<CreateUploadUrlDtoPurposeEnum> get serializer => _$createUploadUrlDtoPurposeEnumSerializer;

  const CreateUploadUrlDtoPurposeEnum._(String name): super(name);

  static BuiltSet<CreateUploadUrlDtoPurposeEnum> get values => _$createUploadUrlDtoPurposeEnumValues;
  static CreateUploadUrlDtoPurposeEnum valueOf(String name) => _$createUploadUrlDtoPurposeEnumValueOf(name);
}
