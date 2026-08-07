//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/direct_conversation_start_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversations_create201_response.g.dart';

/// DirectConversationsCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DirectConversationsCreate201Response implements ApiSuccessEnvelope, Built<DirectConversationsCreate201Response, DirectConversationsCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DirectConversationStartResponseDto get data;

  DirectConversationsCreate201Response._();

  factory DirectConversationsCreate201Response([void updates(DirectConversationsCreate201ResponseBuilder b)]) = _$DirectConversationsCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationsCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationsCreate201Response> get serializer => _$DirectConversationsCreate201ResponseSerializer();
}

class _$DirectConversationsCreate201ResponseSerializer implements PrimitiveSerializer<DirectConversationsCreate201Response> {
  @override
  final Iterable<Type> types = const [DirectConversationsCreate201Response, _$DirectConversationsCreate201Response];

  @override
  final String wireName = r'DirectConversationsCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DirectConversationStartResponseDto),
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
    DirectConversationsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationsCreate201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectConversationStartResponseDto),
          ) as DirectConversationStartResponseDto;
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
  DirectConversationsCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationsCreate201ResponseBuilder();
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

class DirectConversationsCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DirectConversationsCreate201ResponseCodeEnum number0 = _$directConversationsCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DirectConversationsCreate201ResponseCodeEnum unknownDefaultOpenApi = _$directConversationsCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationsCreate201ResponseCodeEnum> get serializer => _$directConversationsCreate201ResponseCodeEnumSerializer;

  const DirectConversationsCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DirectConversationsCreate201ResponseCodeEnum> get values => _$directConversationsCreate201ResponseCodeEnumValues;
  static DirectConversationsCreate201ResponseCodeEnum valueOf(String name) => _$directConversationsCreate201ResponseCodeEnumValueOf(name);
}
