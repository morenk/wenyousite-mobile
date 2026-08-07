//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/direct_message_recall_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_messages_recall200_response.g.dart';

/// DirectMessagesRecall200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DirectMessagesRecall200Response implements ApiSuccessEnvelope, Built<DirectMessagesRecall200Response, DirectMessagesRecall200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DirectMessageRecallResponseDto get data;

  DirectMessagesRecall200Response._();

  factory DirectMessagesRecall200Response([void updates(DirectMessagesRecall200ResponseBuilder b)]) = _$DirectMessagesRecall200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectMessagesRecall200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectMessagesRecall200Response> get serializer => _$DirectMessagesRecall200ResponseSerializer();
}

class _$DirectMessagesRecall200ResponseSerializer implements PrimitiveSerializer<DirectMessagesRecall200Response> {
  @override
  final Iterable<Type> types = const [DirectMessagesRecall200Response, _$DirectMessagesRecall200Response];

  @override
  final String wireName = r'DirectMessagesRecall200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectMessagesRecall200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DirectMessageRecallResponseDto),
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
    DirectMessagesRecall200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectMessagesRecall200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectMessageRecallResponseDto),
          ) as DirectMessageRecallResponseDto;
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
  DirectMessagesRecall200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectMessagesRecall200ResponseBuilder();
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

class DirectMessagesRecall200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DirectMessagesRecall200ResponseCodeEnum number0 = _$directMessagesRecall200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DirectMessagesRecall200ResponseCodeEnum unknownDefaultOpenApi = _$directMessagesRecall200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DirectMessagesRecall200ResponseCodeEnum> get serializer => _$directMessagesRecall200ResponseCodeEnumSerializer;

  const DirectMessagesRecall200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DirectMessagesRecall200ResponseCodeEnum> get values => _$directMessagesRecall200ResponseCodeEnumValues;
  static DirectMessagesRecall200ResponseCodeEnum valueOf(String name) => _$directMessagesRecall200ResponseCodeEnumValueOf(name);
}
