//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/direct_conversation_response_dto.dart';
import 'package:wenyou_api/src/model/direct_message_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversation_start_response_dto.g.dart';

/// DirectConversationStartResponseDto
///
/// Properties:
/// * [conversation]
/// * [message]
@BuiltValue()
abstract class DirectConversationStartResponseDto implements Built<DirectConversationStartResponseDto, DirectConversationStartResponseDtoBuilder> {
  @BuiltValueField(wireName: r'conversation')
  DirectConversationResponseDto get conversation;

  @BuiltValueField(wireName: r'message')
  DirectMessageResponseDto get message;

  DirectConversationStartResponseDto._();

  factory DirectConversationStartResponseDto([void updates(DirectConversationStartResponseDtoBuilder b)]) = _$DirectConversationStartResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationStartResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationStartResponseDto> get serializer => _$DirectConversationStartResponseDtoSerializer();
}

class _$DirectConversationStartResponseDtoSerializer implements PrimitiveSerializer<DirectConversationStartResponseDto> {
  @override
  final Iterable<Type> types = const [DirectConversationStartResponseDto, _$DirectConversationStartResponseDto];

  @override
  final String wireName = r'DirectConversationStartResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationStartResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'conversation';
    yield serializers.serialize(
      object.conversation,
      specifiedType: const FullType(DirectConversationResponseDto),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(DirectMessageResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationStartResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationStartResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'conversation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectConversationResponseDto),
          ) as DirectConversationResponseDto;
          result.conversation.replace(valueDes);
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectMessageResponseDto),
          ) as DirectMessageResponseDto;
          result.message.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DirectConversationStartResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationStartResponseDtoBuilder();
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
