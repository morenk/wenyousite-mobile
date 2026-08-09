//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_user_moderation_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_moderation_get_user200_response.g.dart';

/// AdminModerationGetUser200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminModerationGetUser200Response implements ApiSuccessEnvelope, Built<AdminModerationGetUser200Response, AdminModerationGetUser200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminUserModerationResponseDto get data;

  AdminModerationGetUser200Response._();

  factory AdminModerationGetUser200Response([void updates(AdminModerationGetUser200ResponseBuilder b)]) = _$AdminModerationGetUser200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminModerationGetUser200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminModerationGetUser200Response> get serializer => _$AdminModerationGetUser200ResponseSerializer();
}

class _$AdminModerationGetUser200ResponseSerializer implements PrimitiveSerializer<AdminModerationGetUser200Response> {
  @override
  final Iterable<Type> types = const [AdminModerationGetUser200Response, _$AdminModerationGetUser200Response];

  @override
  final String wireName = r'AdminModerationGetUser200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminModerationGetUser200Response object, {
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
    AdminModerationGetUser200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminModerationGetUser200ResponseBuilder result,
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
  AdminModerationGetUser200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminModerationGetUser200ResponseBuilder();
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

class AdminModerationGetUser200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminModerationGetUser200ResponseCodeEnum number0 = _$adminModerationGetUser200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminModerationGetUser200ResponseCodeEnum unknownDefaultOpenApi = _$adminModerationGetUser200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminModerationGetUser200ResponseCodeEnum> get serializer => _$adminModerationGetUser200ResponseCodeEnumSerializer;

  const AdminModerationGetUser200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminModerationGetUser200ResponseCodeEnum> get values => _$adminModerationGetUser200ResponseCodeEnumValues;
  static AdminModerationGetUser200ResponseCodeEnum valueOf(String name) => _$adminModerationGetUser200ResponseCodeEnumValueOf(name);
}
