//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_direct_message_dto.g.dart';

/// CreateDirectMessageDto
///
/// Properties:
/// * [content] - 纯文字正文，保留换行；与 mediaId 至少提供一项；不能和 stickerAssetId 同时提供
/// * [mediaId] - 已完成处理且属于发送者的图片 ID；每条最多一张
/// * [stickerAssetId] - 当前收藏夹中的表情资产 ID；必须作为独立消息发送
/// * [clientRequestId] - 客户端幂等键；重试同一次发送时必须复用
@BuiltValue()
abstract class CreateDirectMessageDto implements Built<CreateDirectMessageDto, CreateDirectMessageDtoBuilder> {
  /// 纯文字正文，保留换行；与 mediaId 至少提供一项；不能和 stickerAssetId 同时提供
  @BuiltValueField(wireName: r'content')
  String? get content;

  /// 已完成处理且属于发送者的图片 ID；每条最多一张
  @BuiltValueField(wireName: r'mediaId')
  String? get mediaId;

  /// 当前收藏夹中的表情资产 ID；必须作为独立消息发送
  @BuiltValueField(wireName: r'stickerAssetId')
  String? get stickerAssetId;

  /// 客户端幂等键；重试同一次发送时必须复用
  @BuiltValueField(wireName: r'clientRequestId')
  String get clientRequestId;

  CreateDirectMessageDto._();

  factory CreateDirectMessageDto([void updates(CreateDirectMessageDtoBuilder b)]) = _$CreateDirectMessageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateDirectMessageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateDirectMessageDto> get serializer => _$CreateDirectMessageDtoSerializer();
}

class _$CreateDirectMessageDtoSerializer implements PrimitiveSerializer<CreateDirectMessageDto> {
  @override
  final Iterable<Type> types = const [CreateDirectMessageDto, _$CreateDirectMessageDto];

  @override
  final String wireName = r'CreateDirectMessageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateDirectMessageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    if (object.mediaId != null) {
      yield r'mediaId';
      yield serializers.serialize(
        object.mediaId,
        specifiedType: const FullType(String),
      );
    }
    if (object.stickerAssetId != null) {
      yield r'stickerAssetId';
      yield serializers.serialize(
        object.stickerAssetId,
        specifiedType: const FullType(String),
      );
    }
    yield r'clientRequestId';
    yield serializers.serialize(
      object.clientRequestId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateDirectMessageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateDirectMessageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaId = valueDes;
          break;
        case r'stickerAssetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stickerAssetId = valueDes;
          break;
        case r'clientRequestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientRequestId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateDirectMessageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateDirectMessageDtoBuilder();
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
