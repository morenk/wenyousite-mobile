//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'media_response_dto.g.dart';

/// MediaResponseDto
///
/// Properties:
/// * [id]
/// * [userId]
/// * [url] - 正式媒体地址；静态图为归一化母版，GIF 为保留的动画原件
/// * [thumbnailUrl] - 处理完成后的 300px WebP 缩略图地址
/// * [feedUrl] - 处理完成后的 480px 等比例 WebP 信息流图片地址
/// * [mediumUrl] - 处理完成后的 800px WebP 中图地址
/// * [key] - 对象存储 key
/// * [contentType] - 经对象存储确认的 MIME 类型；历史记录可能为空
/// * [size] - 声明或经确认的文件大小（字节）
/// * [width]
/// * [height]
/// * [purpose]
/// * [animated] - 是否为保留动画的 GIF
/// * [status]
/// * [createdAt]
@BuiltValue()
abstract class MediaResponseDto implements Built<MediaResponseDto, MediaResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  /// 正式媒体地址；静态图为归一化母版，GIF 为保留的动画原件
  @BuiltValueField(wireName: r'url')
  String get url;

  /// 处理完成后的 300px WebP 缩略图地址
  @BuiltValueField(wireName: r'thumbnailUrl')
  String? get thumbnailUrl;

  /// 处理完成后的 480px 等比例 WebP 信息流图片地址
  @BuiltValueField(wireName: r'feedUrl')
  String? get feedUrl;

  /// 处理完成后的 800px WebP 中图地址
  @BuiltValueField(wireName: r'mediumUrl')
  String? get mediumUrl;

  /// 对象存储 key
  @BuiltValueField(wireName: r'key')
  String get key;

  /// 经对象存储确认的 MIME 类型；历史记录可能为空
  @BuiltValueField(wireName: r'contentType')
  String? get contentType;

  /// 声明或经确认的文件大小（字节）
  @BuiltValueField(wireName: r'size')
  num? get size;

  @BuiltValueField(wireName: r'width')
  num? get width;

  @BuiltValueField(wireName: r'height')
  num? get height;

  @BuiltValueField(wireName: r'purpose')
  MediaResponseDtoPurposeEnum get purpose;
  // enum purposeEnum {  AVATAR,  PROFILE_COVER,  DIRECT_MESSAGE,  MOMENT,  MOMENT_COMMENT,  RICH_CONTENT,  STICKER_SOURCE,  LEGACY,  };

  /// 是否为保留动画的 GIF
  @BuiltValueField(wireName: r'animated')
  bool get animated;

  @BuiltValueField(wireName: r'status')
  MediaResponseDtoStatusEnum get status;
  // enum statusEnum {  UPLOADING,  PROCESSING,  COMPLETED,  FAILED,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  MediaResponseDto._();

  factory MediaResponseDto([void updates(MediaResponseDtoBuilder b)]) = _$MediaResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MediaResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MediaResponseDto> get serializer => _$MediaResponseDtoSerializer();
}

class _$MediaResponseDtoSerializer implements PrimitiveSerializer<MediaResponseDto> {
  @override
  final Iterable<Type> types = const [MediaResponseDto, _$MediaResponseDto];

  @override
  final String wireName = r'MediaResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MediaResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'thumbnailUrl';
    yield object.thumbnailUrl == null ? null : serializers.serialize(
      object.thumbnailUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'feedUrl';
    yield object.feedUrl == null ? null : serializers.serialize(
      object.feedUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'mediumUrl';
    yield object.mediumUrl == null ? null : serializers.serialize(
      object.mediumUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'contentType';
    yield object.contentType == null ? null : serializers.serialize(
      object.contentType,
      specifiedType: const FullType.nullable(String),
    );
    yield r'size';
    yield object.size == null ? null : serializers.serialize(
      object.size,
      specifiedType: const FullType.nullable(num),
    );
    yield r'width';
    yield object.width == null ? null : serializers.serialize(
      object.width,
      specifiedType: const FullType.nullable(num),
    );
    yield r'height';
    yield object.height == null ? null : serializers.serialize(
      object.height,
      specifiedType: const FullType.nullable(num),
    );
    yield r'purpose';
    yield serializers.serialize(
      object.purpose,
      specifiedType: const FullType(MediaResponseDtoPurposeEnum),
    );
    yield r'animated';
    yield serializers.serialize(
      object.animated,
      specifiedType: const FullType(bool),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(MediaResponseDtoStatusEnum),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MediaResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MediaResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'thumbnailUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.thumbnailUrl = valueDes;
          break;
        case r'feedUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.feedUrl = valueDes;
          break;
        case r'mediumUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mediumUrl = valueDes;
          break;
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        case r'contentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.contentType = valueDes;
          break;
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.size = valueDes;
          break;
        case r'width':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.width = valueDes;
          break;
        case r'height':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.height = valueDes;
          break;
        case r'purpose':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MediaResponseDtoPurposeEnum),
          ) as MediaResponseDtoPurposeEnum;
          result.purpose = valueDes;
          break;
        case r'animated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.animated = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MediaResponseDtoStatusEnum),
          ) as MediaResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MediaResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MediaResponseDtoBuilder();
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

class MediaResponseDtoPurposeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'AVATAR')
  static const MediaResponseDtoPurposeEnum AVATAR = _$mediaResponseDtoPurposeEnum_AVATAR;
  @BuiltValueEnumConst(wireName: r'PROFILE_COVER')
  static const MediaResponseDtoPurposeEnum PROFILE_COVER = _$mediaResponseDtoPurposeEnum_PROFILE_COVER;
  @BuiltValueEnumConst(wireName: r'DIRECT_MESSAGE')
  static const MediaResponseDtoPurposeEnum DIRECT_MESSAGE = _$mediaResponseDtoPurposeEnum_DIRECT_MESSAGE;
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const MediaResponseDtoPurposeEnum MOMENT = _$mediaResponseDtoPurposeEnum_MOMENT;
  @BuiltValueEnumConst(wireName: r'MOMENT_COMMENT')
  static const MediaResponseDtoPurposeEnum MOMENT_COMMENT = _$mediaResponseDtoPurposeEnum_MOMENT_COMMENT;
  @BuiltValueEnumConst(wireName: r'RICH_CONTENT')
  static const MediaResponseDtoPurposeEnum RICH_CONTENT = _$mediaResponseDtoPurposeEnum_RICH_CONTENT;
  @BuiltValueEnumConst(wireName: r'STICKER_SOURCE')
  static const MediaResponseDtoPurposeEnum STICKER_SOURCE = _$mediaResponseDtoPurposeEnum_STICKER_SOURCE;
  @BuiltValueEnumConst(wireName: r'LEGACY')
  static const MediaResponseDtoPurposeEnum LEGACY = _$mediaResponseDtoPurposeEnum_LEGACY;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const MediaResponseDtoPurposeEnum unknownDefaultOpenApi = _$mediaResponseDtoPurposeEnum_unknownDefaultOpenApi;

  static Serializer<MediaResponseDtoPurposeEnum> get serializer => _$mediaResponseDtoPurposeEnumSerializer;

  const MediaResponseDtoPurposeEnum._(String name): super(name);

  static BuiltSet<MediaResponseDtoPurposeEnum> get values => _$mediaResponseDtoPurposeEnumValues;
  static MediaResponseDtoPurposeEnum valueOf(String name) => _$mediaResponseDtoPurposeEnumValueOf(name);
}

class MediaResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'UPLOADING')
  static const MediaResponseDtoStatusEnum UPLOADING = _$mediaResponseDtoStatusEnum_UPLOADING;
  @BuiltValueEnumConst(wireName: r'PROCESSING')
  static const MediaResponseDtoStatusEnum PROCESSING = _$mediaResponseDtoStatusEnum_PROCESSING;
  @BuiltValueEnumConst(wireName: r'COMPLETED')
  static const MediaResponseDtoStatusEnum COMPLETED = _$mediaResponseDtoStatusEnum_COMPLETED;
  @BuiltValueEnumConst(wireName: r'FAILED')
  static const MediaResponseDtoStatusEnum FAILED = _$mediaResponseDtoStatusEnum_FAILED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const MediaResponseDtoStatusEnum unknownDefaultOpenApi = _$mediaResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<MediaResponseDtoStatusEnum> get serializer => _$mediaResponseDtoStatusEnumSerializer;

  const MediaResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<MediaResponseDtoStatusEnum> get values => _$mediaResponseDtoStatusEnumValues;
  static MediaResponseDtoStatusEnum valueOf(String name) => _$mediaResponseDtoStatusEnumValueOf(name);
}
