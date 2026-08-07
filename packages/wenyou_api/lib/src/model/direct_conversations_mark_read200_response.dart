//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversations_mark_read200_response.g.dart';

/// DirectConversationsMarkRead200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DirectConversationsMarkRead200Response implements ApiSuccessEnvelope, Built<DirectConversationsMarkRead200Response, DirectConversationsMarkRead200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  DirectConversationsMarkRead200Response._();

  factory DirectConversationsMarkRead200Response([void updates(DirectConversationsMarkRead200ResponseBuilder b)]) = _$DirectConversationsMarkRead200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationsMarkRead200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationsMarkRead200Response> get serializer => _$DirectConversationsMarkRead200ResponseSerializer();
}

class _$DirectConversationsMarkRead200ResponseSerializer implements PrimitiveSerializer<DirectConversationsMarkRead200Response> {
  @override
  final Iterable<Type> types = const [DirectConversationsMarkRead200Response, _$DirectConversationsMarkRead200Response];

  @override
  final String wireName = r'DirectConversationsMarkRead200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationsMarkRead200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MessageResponseDto),
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
    DirectConversationsMarkRead200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationsMarkRead200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageResponseDto),
          ) as MessageResponseDto;
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
  DirectConversationsMarkRead200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationsMarkRead200ResponseBuilder();
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

class DirectConversationsMarkRead200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DirectConversationsMarkRead200ResponseCodeEnum number0 = _$directConversationsMarkRead200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DirectConversationsMarkRead200ResponseCodeEnum unknownDefaultOpenApi = _$directConversationsMarkRead200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationsMarkRead200ResponseCodeEnum> get serializer => _$directConversationsMarkRead200ResponseCodeEnumSerializer;

  const DirectConversationsMarkRead200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DirectConversationsMarkRead200ResponseCodeEnum> get values => _$directConversationsMarkRead200ResponseCodeEnumValues;
  static DirectConversationsMarkRead200ResponseCodeEnum valueOf(String name) => _$directConversationsMarkRead200ResponseCodeEnumValueOf(name);
}
