//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_message_recall_response_dto.g.dart';

/// DirectMessageRecallResponseDto
///
/// Properties:
/// * [message]
/// * [conversationCanceled]
@BuiltValue()
abstract class DirectMessageRecallResponseDto implements Built<DirectMessageRecallResponseDto, DirectMessageRecallResponseDtoBuilder> {
  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'conversationCanceled')
  bool get conversationCanceled;

  DirectMessageRecallResponseDto._();

  factory DirectMessageRecallResponseDto([void updates(DirectMessageRecallResponseDtoBuilder b)]) = _$DirectMessageRecallResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectMessageRecallResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectMessageRecallResponseDto> get serializer => _$DirectMessageRecallResponseDtoSerializer();
}

class _$DirectMessageRecallResponseDtoSerializer implements PrimitiveSerializer<DirectMessageRecallResponseDto> {
  @override
  final Iterable<Type> types = const [DirectMessageRecallResponseDto, _$DirectMessageRecallResponseDto];

  @override
  final String wireName = r'DirectMessageRecallResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectMessageRecallResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'conversationCanceled';
    yield serializers.serialize(
      object.conversationCanceled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DirectMessageRecallResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectMessageRecallResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'conversationCanceled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.conversationCanceled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DirectMessageRecallResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectMessageRecallResponseDtoBuilder();
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
