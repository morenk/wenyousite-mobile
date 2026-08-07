//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/direct_conversation_lookup_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversations_find_by_user200_response.g.dart';

/// DirectConversationsFindByUser200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DirectConversationsFindByUser200Response implements ApiSuccessEnvelope, Built<DirectConversationsFindByUser200Response, DirectConversationsFindByUser200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DirectConversationLookupResponseDto get data;

  DirectConversationsFindByUser200Response._();

  factory DirectConversationsFindByUser200Response([void updates(DirectConversationsFindByUser200ResponseBuilder b)]) = _$DirectConversationsFindByUser200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationsFindByUser200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationsFindByUser200Response> get serializer => _$DirectConversationsFindByUser200ResponseSerializer();
}

class _$DirectConversationsFindByUser200ResponseSerializer implements PrimitiveSerializer<DirectConversationsFindByUser200Response> {
  @override
  final Iterable<Type> types = const [DirectConversationsFindByUser200Response, _$DirectConversationsFindByUser200Response];

  @override
  final String wireName = r'DirectConversationsFindByUser200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationsFindByUser200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DirectConversationLookupResponseDto),
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
    DirectConversationsFindByUser200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationsFindByUser200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectConversationLookupResponseDto),
          ) as DirectConversationLookupResponseDto;
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
  DirectConversationsFindByUser200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationsFindByUser200ResponseBuilder();
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

class DirectConversationsFindByUser200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DirectConversationsFindByUser200ResponseCodeEnum number0 = _$directConversationsFindByUser200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DirectConversationsFindByUser200ResponseCodeEnum unknownDefaultOpenApi = _$directConversationsFindByUser200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationsFindByUser200ResponseCodeEnum> get serializer => _$directConversationsFindByUser200ResponseCodeEnumSerializer;

  const DirectConversationsFindByUser200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DirectConversationsFindByUser200ResponseCodeEnum> get values => _$directConversationsFindByUser200ResponseCodeEnumValues;
  static DirectConversationsFindByUser200ResponseCodeEnum valueOf(String name) => _$directConversationsFindByUser200ResponseCodeEnumValueOf(name);
}
