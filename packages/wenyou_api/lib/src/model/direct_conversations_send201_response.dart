//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/direct_message_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversations_send201_response.g.dart';

/// DirectConversationsSend201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DirectConversationsSend201Response implements ApiSuccessEnvelope, Built<DirectConversationsSend201Response, DirectConversationsSend201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DirectMessageResponseDto get data;

  DirectConversationsSend201Response._();

  factory DirectConversationsSend201Response([void updates(DirectConversationsSend201ResponseBuilder b)]) = _$DirectConversationsSend201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationsSend201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationsSend201Response> get serializer => _$DirectConversationsSend201ResponseSerializer();
}

class _$DirectConversationsSend201ResponseSerializer implements PrimitiveSerializer<DirectConversationsSend201Response> {
  @override
  final Iterable<Type> types = const [DirectConversationsSend201Response, _$DirectConversationsSend201Response];

  @override
  final String wireName = r'DirectConversationsSend201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationsSend201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DirectMessageResponseDto),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationsSend201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationsSend201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectMessageResponseDto),
          ) as DirectMessageResponseDto;
          result.data.replace(valueDes);
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
          ) as ApiSuccessEnvelopeCodeEnum;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DirectConversationsSend201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationsSend201ResponseBuilder();
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

class DirectConversationsSend201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DirectConversationsSend201ResponseCodeEnum number0 = _$directConversationsSend201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DirectConversationsSend201ResponseCodeEnum unknownDefaultOpenApi = _$directConversationsSend201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationsSend201ResponseCodeEnum> get serializer => _$directConversationsSend201ResponseCodeEnumSerializer;

  const DirectConversationsSend201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DirectConversationsSend201ResponseCodeEnum> get values => _$directConversationsSend201ResponseCodeEnumValues;
  static DirectConversationsSend201ResponseCodeEnum valueOf(String name) => _$directConversationsSend201ResponseCodeEnumValueOf(name);
}
