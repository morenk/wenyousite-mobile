//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/direct_conversation_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversations_archive200_response.g.dart';

/// DirectConversationsArchive200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DirectConversationsArchive200Response implements ApiSuccessEnvelope, Built<DirectConversationsArchive200Response, DirectConversationsArchive200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DirectConversationResponseDto get data;

  DirectConversationsArchive200Response._();

  factory DirectConversationsArchive200Response([void updates(DirectConversationsArchive200ResponseBuilder b)]) = _$DirectConversationsArchive200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationsArchive200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationsArchive200Response> get serializer => _$DirectConversationsArchive200ResponseSerializer();
}

class _$DirectConversationsArchive200ResponseSerializer implements PrimitiveSerializer<DirectConversationsArchive200Response> {
  @override
  final Iterable<Type> types = const [DirectConversationsArchive200Response, _$DirectConversationsArchive200Response];

  @override
  final String wireName = r'DirectConversationsArchive200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationsArchive200Response object, {
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
    DirectConversationsArchive200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationsArchive200ResponseBuilder result,
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
  DirectConversationsArchive200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationsArchive200ResponseBuilder();
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

class DirectConversationsArchive200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DirectConversationsArchive200ResponseCodeEnum number0 = _$directConversationsArchive200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DirectConversationsArchive200ResponseCodeEnum unknownDefaultOpenApi = _$directConversationsArchive200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationsArchive200ResponseCodeEnum> get serializer => _$directConversationsArchive200ResponseCodeEnumSerializer;

  const DirectConversationsArchive200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DirectConversationsArchive200ResponseCodeEnum> get values => _$directConversationsArchive200ResponseCodeEnumValues;
  static DirectConversationsArchive200ResponseCodeEnum valueOf(String name) => _$directConversationsArchive200ResponseCodeEnumValueOf(name);
}
