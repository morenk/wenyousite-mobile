//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/direct_conversation_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversations_handle_request200_response.g.dart';

/// DirectConversationsHandleRequest200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DirectConversationsHandleRequest200Response implements ApiSuccessEnvelope, Built<DirectConversationsHandleRequest200Response, DirectConversationsHandleRequest200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DirectConversationResponseDto get data;

  DirectConversationsHandleRequest200Response._();

  factory DirectConversationsHandleRequest200Response([void updates(DirectConversationsHandleRequest200ResponseBuilder b)]) = _$DirectConversationsHandleRequest200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationsHandleRequest200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationsHandleRequest200Response> get serializer => _$DirectConversationsHandleRequest200ResponseSerializer();
}

class _$DirectConversationsHandleRequest200ResponseSerializer implements PrimitiveSerializer<DirectConversationsHandleRequest200Response> {
  @override
  final Iterable<Type> types = const [DirectConversationsHandleRequest200Response, _$DirectConversationsHandleRequest200Response];

  @override
  final String wireName = r'DirectConversationsHandleRequest200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationsHandleRequest200Response object, {
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
    DirectConversationsHandleRequest200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationsHandleRequest200ResponseBuilder result,
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
  DirectConversationsHandleRequest200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationsHandleRequest200ResponseBuilder();
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

class DirectConversationsHandleRequest200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DirectConversationsHandleRequest200ResponseCodeEnum number0 = _$directConversationsHandleRequest200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DirectConversationsHandleRequest200ResponseCodeEnum unknownDefaultOpenApi = _$directConversationsHandleRequest200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationsHandleRequest200ResponseCodeEnum> get serializer => _$directConversationsHandleRequest200ResponseCodeEnumSerializer;

  const DirectConversationsHandleRequest200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DirectConversationsHandleRequest200ResponseCodeEnum> get values => _$directConversationsHandleRequest200ResponseCodeEnumValues;
  static DirectConversationsHandleRequest200ResponseCodeEnum valueOf(String name) => _$directConversationsHandleRequest200ResponseCodeEnumValueOf(name);
}
