//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/direct_conversation_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversations_find_by_id200_response.g.dart';

/// DirectConversationsFindById200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DirectConversationsFindById200Response implements ApiSuccessEnvelope, Built<DirectConversationsFindById200Response, DirectConversationsFindById200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DirectConversationResponseDto get data;

  DirectConversationsFindById200Response._();

  factory DirectConversationsFindById200Response([void updates(DirectConversationsFindById200ResponseBuilder b)]) = _$DirectConversationsFindById200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationsFindById200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationsFindById200Response> get serializer => _$DirectConversationsFindById200ResponseSerializer();
}

class _$DirectConversationsFindById200ResponseSerializer implements PrimitiveSerializer<DirectConversationsFindById200Response> {
  @override
  final Iterable<Type> types = const [DirectConversationsFindById200Response, _$DirectConversationsFindById200Response];

  @override
  final String wireName = r'DirectConversationsFindById200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationsFindById200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DirectConversationResponseDto),
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
    DirectConversationsFindById200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationsFindById200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectConversationResponseDto),
          ) as DirectConversationResponseDto;
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
  DirectConversationsFindById200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationsFindById200ResponseBuilder();
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

class DirectConversationsFindById200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DirectConversationsFindById200ResponseCodeEnum number0 = _$directConversationsFindById200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DirectConversationsFindById200ResponseCodeEnum unknownDefaultOpenApi = _$directConversationsFindById200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationsFindById200ResponseCodeEnum> get serializer => _$directConversationsFindById200ResponseCodeEnumSerializer;

  const DirectConversationsFindById200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DirectConversationsFindById200ResponseCodeEnum> get values => _$directConversationsFindById200ResponseCodeEnumValues;
  static DirectConversationsFindById200ResponseCodeEnum valueOf(String name) => _$directConversationsFindById200ResponseCodeEnumValueOf(name);
}
