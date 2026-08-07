//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/direct_conversation_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversation_lookup_response_dto.g.dart';

/// DirectConversationLookupResponseDto
///
/// Properties:
/// * [contactState]
/// * [canInitiate]
/// * [conversation]
@BuiltValue()
abstract class DirectConversationLookupResponseDto implements Built<DirectConversationLookupResponseDto, DirectConversationLookupResponseDtoBuilder> {
  @BuiltValueField(wireName: r'contactState')
  DirectConversationLookupResponseDtoContactStateEnum get contactState;
  // enum contactStateEnum {  NEW,  PENDING,  ACCEPTED,  DECLINED,  CANCELED,  UNAVAILABLE,  };

  @BuiltValueField(wireName: r'canInitiate')
  bool get canInitiate;

  @BuiltValueField(wireName: r'conversation')
  DirectConversationResponseDto? get conversation;

  DirectConversationLookupResponseDto._();

  factory DirectConversationLookupResponseDto([void updates(DirectConversationLookupResponseDtoBuilder b)]) = _$DirectConversationLookupResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationLookupResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationLookupResponseDto> get serializer => _$DirectConversationLookupResponseDtoSerializer();
}

class _$DirectConversationLookupResponseDtoSerializer implements PrimitiveSerializer<DirectConversationLookupResponseDto> {
  @override
  final Iterable<Type> types = const [DirectConversationLookupResponseDto, _$DirectConversationLookupResponseDto];

  @override
  final String wireName = r'DirectConversationLookupResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationLookupResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'contactState';
    yield serializers.serialize(
      object.contactState,
      specifiedType: const FullType(DirectConversationLookupResponseDtoContactStateEnum),
    );
    yield r'canInitiate';
    yield serializers.serialize(
      object.canInitiate,
      specifiedType: const FullType(bool),
    );
    yield r'conversation';
    yield object.conversation == null ? null : serializers.serialize(
      object.conversation,
      specifiedType: const FullType.nullable(DirectConversationResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationLookupResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationLookupResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'contactState':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectConversationLookupResponseDtoContactStateEnum),
          ) as DirectConversationLookupResponseDtoContactStateEnum;
          result.contactState = valueDes;
          break;
        case r'canInitiate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canInitiate = valueDes;
          break;
        case r'conversation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DirectConversationResponseDto),
          ) as DirectConversationResponseDto?;
          if (valueDes == null) continue;
          result.conversation.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DirectConversationLookupResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationLookupResponseDtoBuilder();
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

class DirectConversationLookupResponseDtoContactStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'NEW')
  static const DirectConversationLookupResponseDtoContactStateEnum NEW = _$directConversationLookupResponseDtoContactStateEnum_NEW;
  @BuiltValueEnumConst(wireName: r'PENDING')
  static const DirectConversationLookupResponseDtoContactStateEnum PENDING = _$directConversationLookupResponseDtoContactStateEnum_PENDING;
  @BuiltValueEnumConst(wireName: r'ACCEPTED')
  static const DirectConversationLookupResponseDtoContactStateEnum ACCEPTED = _$directConversationLookupResponseDtoContactStateEnum_ACCEPTED;
  @BuiltValueEnumConst(wireName: r'DECLINED')
  static const DirectConversationLookupResponseDtoContactStateEnum DECLINED = _$directConversationLookupResponseDtoContactStateEnum_DECLINED;
  @BuiltValueEnumConst(wireName: r'CANCELED')
  static const DirectConversationLookupResponseDtoContactStateEnum CANCELED = _$directConversationLookupResponseDtoContactStateEnum_CANCELED;
  @BuiltValueEnumConst(wireName: r'UNAVAILABLE')
  static const DirectConversationLookupResponseDtoContactStateEnum UNAVAILABLE = _$directConversationLookupResponseDtoContactStateEnum_UNAVAILABLE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DirectConversationLookupResponseDtoContactStateEnum unknownDefaultOpenApi = _$directConversationLookupResponseDtoContactStateEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationLookupResponseDtoContactStateEnum> get serializer => _$directConversationLookupResponseDtoContactStateEnumSerializer;

  const DirectConversationLookupResponseDtoContactStateEnum._(String name): super(name);

  static BuiltSet<DirectConversationLookupResponseDtoContactStateEnum> get values => _$directConversationLookupResponseDtoContactStateEnumValues;
  static DirectConversationLookupResponseDtoContactStateEnum valueOf(String name) => _$directConversationLookupResponseDtoContactStateEnumValueOf(name);
}
