//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_auth_logout200_response.g.dart';

/// AdminAuthLogout200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminAuthLogout200Response implements ApiSuccessEnvelope, Built<AdminAuthLogout200Response, AdminAuthLogout200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  AdminAuthLogout200Response._();

  factory AdminAuthLogout200Response([void updates(AdminAuthLogout200ResponseBuilder b)]) = _$AdminAuthLogout200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAuthLogout200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAuthLogout200Response> get serializer => _$AdminAuthLogout200ResponseSerializer();
}

class _$AdminAuthLogout200ResponseSerializer implements PrimitiveSerializer<AdminAuthLogout200Response> {
  @override
  final Iterable<Type> types = const [AdminAuthLogout200Response, _$AdminAuthLogout200Response];

  @override
  final String wireName = r'AdminAuthLogout200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAuthLogout200Response object, {
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
    AdminAuthLogout200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAuthLogout200ResponseBuilder result,
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
  AdminAuthLogout200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAuthLogout200ResponseBuilder();
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

class AdminAuthLogout200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminAuthLogout200ResponseCodeEnum number0 = _$adminAuthLogout200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminAuthLogout200ResponseCodeEnum unknownDefaultOpenApi = _$adminAuthLogout200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminAuthLogout200ResponseCodeEnum> get serializer => _$adminAuthLogout200ResponseCodeEnumSerializer;

  const AdminAuthLogout200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminAuthLogout200ResponseCodeEnum> get values => _$adminAuthLogout200ResponseCodeEnumValues;
  static AdminAuthLogout200ResponseCodeEnum valueOf(String name) => _$adminAuthLogout200ResponseCodeEnumValueOf(name);
}
