//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_user_moderation_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_moderation_update_role200_response.g.dart';

/// AdminModerationUpdateRole200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminModerationUpdateRole200Response implements ApiSuccessEnvelope, Built<AdminModerationUpdateRole200Response, AdminModerationUpdateRole200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminUserModerationResponseDto get data;

  AdminModerationUpdateRole200Response._();

  factory AdminModerationUpdateRole200Response([void updates(AdminModerationUpdateRole200ResponseBuilder b)]) = _$AdminModerationUpdateRole200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminModerationUpdateRole200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminModerationUpdateRole200Response> get serializer => _$AdminModerationUpdateRole200ResponseSerializer();
}

class _$AdminModerationUpdateRole200ResponseSerializer implements PrimitiveSerializer<AdminModerationUpdateRole200Response> {
  @override
  final Iterable<Type> types = const [AdminModerationUpdateRole200Response, _$AdminModerationUpdateRole200Response];

  @override
  final String wireName = r'AdminModerationUpdateRole200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminModerationUpdateRole200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminUserModerationResponseDto),
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
    AdminModerationUpdateRole200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminModerationUpdateRole200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserModerationResponseDto),
          ) as AdminUserModerationResponseDto;
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
  AdminModerationUpdateRole200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminModerationUpdateRole200ResponseBuilder();
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

class AdminModerationUpdateRole200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminModerationUpdateRole200ResponseCodeEnum number0 = _$adminModerationUpdateRole200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminModerationUpdateRole200ResponseCodeEnum unknownDefaultOpenApi = _$adminModerationUpdateRole200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminModerationUpdateRole200ResponseCodeEnum> get serializer => _$adminModerationUpdateRole200ResponseCodeEnumSerializer;

  const AdminModerationUpdateRole200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminModerationUpdateRole200ResponseCodeEnum> get values => _$adminModerationUpdateRole200ResponseCodeEnumValues;
  static AdminModerationUpdateRole200ResponseCodeEnum valueOf(String name) => _$adminModerationUpdateRole200ResponseCodeEnumValueOf(name);
}
