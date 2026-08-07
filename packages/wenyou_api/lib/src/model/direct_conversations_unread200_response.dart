//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/direct_unread_count_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversations_unread200_response.g.dart';

/// DirectConversationsUnread200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DirectConversationsUnread200Response implements ApiSuccessEnvelope, Built<DirectConversationsUnread200Response, DirectConversationsUnread200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DirectUnreadCountResponseDto get data;

  DirectConversationsUnread200Response._();

  factory DirectConversationsUnread200Response([void updates(DirectConversationsUnread200ResponseBuilder b)]) = _$DirectConversationsUnread200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationsUnread200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationsUnread200Response> get serializer => _$DirectConversationsUnread200ResponseSerializer();
}

class _$DirectConversationsUnread200ResponseSerializer implements PrimitiveSerializer<DirectConversationsUnread200Response> {
  @override
  final Iterable<Type> types = const [DirectConversationsUnread200Response, _$DirectConversationsUnread200Response];

  @override
  final String wireName = r'DirectConversationsUnread200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationsUnread200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DirectUnreadCountResponseDto),
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
    DirectConversationsUnread200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationsUnread200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectUnreadCountResponseDto),
          ) as DirectUnreadCountResponseDto;
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
  DirectConversationsUnread200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationsUnread200ResponseBuilder();
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

class DirectConversationsUnread200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DirectConversationsUnread200ResponseCodeEnum number0 = _$directConversationsUnread200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DirectConversationsUnread200ResponseCodeEnum unknownDefaultOpenApi = _$directConversationsUnread200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationsUnread200ResponseCodeEnum> get serializer => _$directConversationsUnread200ResponseCodeEnumSerializer;

  const DirectConversationsUnread200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DirectConversationsUnread200ResponseCodeEnum> get values => _$directConversationsUnread200ResponseCodeEnumValues;
  static DirectConversationsUnread200ResponseCodeEnum valueOf(String name) => _$directConversationsUnread200ResponseCodeEnumValueOf(name);
}
