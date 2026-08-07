//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mark_direct_conversation_read_dto.g.dart';

/// MarkDirectConversationReadDto
///
/// Properties:
/// * [throughMessageId] - 客户端实际已展示的最后一条消息 ID
@BuiltValue()
abstract class MarkDirectConversationReadDto implements Built<MarkDirectConversationReadDto, MarkDirectConversationReadDtoBuilder> {
  /// 客户端实际已展示的最后一条消息 ID
  @BuiltValueField(wireName: r'throughMessageId')
  String get throughMessageId;

  MarkDirectConversationReadDto._();

  factory MarkDirectConversationReadDto([void updates(MarkDirectConversationReadDtoBuilder b)]) = _$MarkDirectConversationReadDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MarkDirectConversationReadDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MarkDirectConversationReadDto> get serializer => _$MarkDirectConversationReadDtoSerializer();
}

class _$MarkDirectConversationReadDtoSerializer implements PrimitiveSerializer<MarkDirectConversationReadDto> {
  @override
  final Iterable<Type> types = const [MarkDirectConversationReadDto, _$MarkDirectConversationReadDto];

  @override
  final String wireName = r'MarkDirectConversationReadDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MarkDirectConversationReadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'throughMessageId';
    yield serializers.serialize(
      object.throughMessageId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MarkDirectConversationReadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MarkDirectConversationReadDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'throughMessageId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.throughMessageId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MarkDirectConversationReadDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MarkDirectConversationReadDtoBuilder();
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
