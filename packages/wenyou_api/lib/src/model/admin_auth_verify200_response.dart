//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_session_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_auth_verify200_response.g.dart';

/// AdminAuthVerify200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminAuthVerify200Response implements ApiSuccessEnvelope, Built<AdminAuthVerify200Response, AdminAuthVerify200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminSessionResponseDto get data;

  AdminAuthVerify200Response._();

  factory AdminAuthVerify200Response([void updates(AdminAuthVerify200ResponseBuilder b)]) = _$AdminAuthVerify200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAuthVerify200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAuthVerify200Response> get serializer => _$AdminAuthVerify200ResponseSerializer();
}

class _$AdminAuthVerify200ResponseSerializer implements PrimitiveSerializer<AdminAuthVerify200Response> {
  @override
  final Iterable<Type> types = const [AdminAuthVerify200Response, _$AdminAuthVerify200Response];

  @override
  final String wireName = r'AdminAuthVerify200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAuthVerify200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminSessionResponseDto),
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
    AdminAuthVerify200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAuthVerify200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminSessionResponseDto),
          ) as AdminSessionResponseDto;
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
  AdminAuthVerify200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAuthVerify200ResponseBuilder();
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

class AdminAuthVerify200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminAuthVerify200ResponseCodeEnum number0 = _$adminAuthVerify200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminAuthVerify200ResponseCodeEnum unknownDefaultOpenApi = _$adminAuthVerify200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminAuthVerify200ResponseCodeEnum> get serializer => _$adminAuthVerify200ResponseCodeEnumSerializer;

  const AdminAuthVerify200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminAuthVerify200ResponseCodeEnum> get values => _$adminAuthVerify200ResponseCodeEnumValues;
  static AdminAuthVerify200ResponseCodeEnum valueOf(String name) => _$adminAuthVerify200ResponseCodeEnumValueOf(name);
}
