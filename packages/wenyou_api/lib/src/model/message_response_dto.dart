//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'message_response_dto.g.dart';

/// MessageResponseDto
///
/// Properties:
/// * [message] - 操作结果说明
@BuiltValue()
abstract class MessageResponseDto implements Built<MessageResponseDto, MessageResponseDtoBuilder> {
  /// 操作结果说明
  @BuiltValueField(wireName: r'message')
  String get message;

  MessageResponseDto._();

  factory MessageResponseDto([void updates(MessageResponseDtoBuilder b)]) = _$MessageResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MessageResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MessageResponseDto> get serializer => _$MessageResponseDtoSerializer();
}

class _$MessageResponseDtoSerializer implements PrimitiveSerializer<MessageResponseDto> {
  @override
  final Iterable<Type> types = const [MessageResponseDto, _$MessageResponseDto];

  @override
  final String wireName = r'MessageResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MessageResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MessageResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MessageResponseDtoBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MessageResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MessageResponseDtoBuilder();
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
