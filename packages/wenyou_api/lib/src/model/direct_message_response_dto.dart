//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/direct_message_media_response_dto.dart';
import 'package:wenyou_api/src/model/direct_message_sticker_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_message_response_dto.g.dart';

/// DirectMessageResponseDto
///
/// Properties:
/// * [id]
/// * [conversationId]
/// * [senderId]
/// * [recipientId]
/// * [content]
/// * [media]
/// * [sticker]
/// * [recalledAt]
/// * [createdAt]
@BuiltValue()
abstract class DirectMessageResponseDto implements Built<DirectMessageResponseDto, DirectMessageResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'conversationId')
  String get conversationId;

  @BuiltValueField(wireName: r'senderId')
  String get senderId;

  @BuiltValueField(wireName: r'recipientId')
  String get recipientId;

  @BuiltValueField(wireName: r'content')
  String? get content;

  @BuiltValueField(wireName: r'media')
  DirectMessageMediaResponseDto? get media;

  @BuiltValueField(wireName: r'sticker')
  DirectMessageStickerResponseDto? get sticker;

  @BuiltValueField(wireName: r'recalledAt')
  DateTime? get recalledAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  DirectMessageResponseDto._();

  factory DirectMessageResponseDto([void updates(DirectMessageResponseDtoBuilder b)]) = _$DirectMessageResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectMessageResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectMessageResponseDto> get serializer => _$DirectMessageResponseDtoSerializer();
}

class _$DirectMessageResponseDtoSerializer implements PrimitiveSerializer<DirectMessageResponseDto> {
  @override
  final Iterable<Type> types = const [DirectMessageResponseDto, _$DirectMessageResponseDto];

  @override
  final String wireName = r'DirectMessageResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectMessageResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'conversationId';
    yield serializers.serialize(
      object.conversationId,
      specifiedType: const FullType(String),
    );
    yield r'senderId';
    yield serializers.serialize(
      object.senderId,
      specifiedType: const FullType(String),
    );
    yield r'recipientId';
    yield serializers.serialize(
      object.recipientId,
      specifiedType: const FullType(String),
    );
    yield r'content';
    yield object.content == null ? null : serializers.serialize(
      object.content,
      specifiedType: const FullType.nullable(String),
    );
    yield r'media';
    yield object.media == null ? null : serializers.serialize(
      object.media,
      specifiedType: const FullType.nullable(DirectMessageMediaResponseDto),
    );
    yield r'sticker';
    yield object.sticker == null ? null : serializers.serialize(
      object.sticker,
      specifiedType: const FullType.nullable(DirectMessageStickerResponseDto),
    );
    yield r'recalledAt';
    yield object.recalledAt == null ? null : serializers.serialize(
      object.recalledAt,
      specifiedType: const FullType.nullable(DateTime),
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
    DirectMessageResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectMessageResponseDtoBuilder result,
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
        case r'conversationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.conversationId = valueDes;
          break;
        case r'senderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.senderId = valueDes;
          break;
        case r'recipientId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.recipientId = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.content = valueDes;
          break;
        case r'media':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DirectMessageMediaResponseDto),
          ) as DirectMessageMediaResponseDto?;
          if (valueDes == null) continue;
          result.media.replace(valueDes);
          break;
        case r'sticker':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DirectMessageStickerResponseDto),
          ) as DirectMessageStickerResponseDto?;
          if (valueDes == null) continue;
          result.sticker.replace(valueDes);
          break;
        case r'recalledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.recalledAt = valueDes;
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
  DirectMessageResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectMessageResponseDtoBuilder();
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
