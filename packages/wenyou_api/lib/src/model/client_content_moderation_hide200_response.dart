//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_content_moderation_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'client_content_moderation_hide200_response.g.dart';

/// ClientContentModerationHide200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ClientContentModerationHide200Response implements ApiSuccessEnvelope, Built<ClientContentModerationHide200Response, ClientContentModerationHide200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminContentModerationResponseDto get data;

  ClientContentModerationHide200Response._();

  factory ClientContentModerationHide200Response([void updates(ClientContentModerationHide200ResponseBuilder b)]) = _$ClientContentModerationHide200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClientContentModerationHide200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClientContentModerationHide200Response> get serializer => _$ClientContentModerationHide200ResponseSerializer();
}

class _$ClientContentModerationHide200ResponseSerializer implements PrimitiveSerializer<ClientContentModerationHide200Response> {
  @override
  final Iterable<Type> types = const [ClientContentModerationHide200Response, _$ClientContentModerationHide200Response];

  @override
  final String wireName = r'ClientContentModerationHide200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClientContentModerationHide200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminContentModerationResponseDto),
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
    ClientContentModerationHide200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClientContentModerationHide200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminContentModerationResponseDto),
          ) as AdminContentModerationResponseDto;
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
  ClientContentModerationHide200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClientContentModerationHide200ResponseBuilder();
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

class ClientContentModerationHide200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ClientContentModerationHide200ResponseCodeEnum number0 = _$clientContentModerationHide200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ClientContentModerationHide200ResponseCodeEnum unknownDefaultOpenApi = _$clientContentModerationHide200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ClientContentModerationHide200ResponseCodeEnum> get serializer => _$clientContentModerationHide200ResponseCodeEnumSerializer;

  const ClientContentModerationHide200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ClientContentModerationHide200ResponseCodeEnum> get values => _$clientContentModerationHide200ResponseCodeEnumValues;
  static ClientContentModerationHide200ResponseCodeEnum valueOf(String name) => _$clientContentModerationHide200ResponseCodeEnumValueOf(name);
}
