//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_direct_conversation_dto.g.dart';

/// CreateDirectConversationDto
///
/// Properties:
/// * [content] - 纯文字正文，保留换行；与 mediaId 至少提供一项；不能和 stickerAssetId 同时提供
/// * [mediaId] - 已完成处理且属于发送者的图片 ID；每条最多一张
/// * [stickerAssetId] - 当前收藏夹中的表情资产 ID；必须作为独立消息发送
/// * [clientRequestId] - 客户端幂等键；重试同一次发送时必须复用
/// * [recipientId] - 接收用户 ID
@BuiltValue()
abstract class CreateDirectConversationDto implements Built<CreateDirectConversationDto, CreateDirectConversationDtoBuilder> {
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

  /// 接收用户 ID
  @BuiltValueField(wireName: r'recipientId')
  String get recipientId;

  CreateDirectConversationDto._();

  factory CreateDirectConversationDto([void updates(CreateDirectConversationDtoBuilder b)]) = _$CreateDirectConversationDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateDirectConversationDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateDirectConversationDto> get serializer => _$CreateDirectConversationDtoSerializer();
}

class _$CreateDirectConversationDtoSerializer implements PrimitiveSerializer<CreateDirectConversationDto> {
  @override
  final Iterable<Type> types = const [CreateDirectConversationDto, _$CreateDirectConversationDto];

  @override
  final String wireName = r'CreateDirectConversationDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateDirectConversationDto object, {
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
    yield r'recipientId';
    yield serializers.serialize(
      object.recipientId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateDirectConversationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateDirectConversationDtoBuilder result,
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
        case r'recipientId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.recipientId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateDirectConversationDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateDirectConversationDtoBuilder();
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
