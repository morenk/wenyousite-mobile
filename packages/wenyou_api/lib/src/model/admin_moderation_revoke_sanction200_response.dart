//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_user_sanction_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_moderation_revoke_sanction200_response.g.dart';

/// AdminModerationRevokeSanction200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminModerationRevokeSanction200Response implements ApiSuccessEnvelope, Built<AdminModerationRevokeSanction200Response, AdminModerationRevokeSanction200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminUserSanctionResponseDto get data;

  AdminModerationRevokeSanction200Response._();

  factory AdminModerationRevokeSanction200Response([void updates(AdminModerationRevokeSanction200ResponseBuilder b)]) = _$AdminModerationRevokeSanction200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminModerationRevokeSanction200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminModerationRevokeSanction200Response> get serializer => _$AdminModerationRevokeSanction200ResponseSerializer();
}

class _$AdminModerationRevokeSanction200ResponseSerializer implements PrimitiveSerializer<AdminModerationRevokeSanction200Response> {
  @override
  final Iterable<Type> types = const [AdminModerationRevokeSanction200Response, _$AdminModerationRevokeSanction200Response];

  @override
  final String wireName = r'AdminModerationRevokeSanction200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminModerationRevokeSanction200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminUserSanctionResponseDto),
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
    AdminModerationRevokeSanction200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminModerationRevokeSanction200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserSanctionResponseDto),
          ) as AdminUserSanctionResponseDto;
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
  AdminModerationRevokeSanction200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminModerationRevokeSanction200ResponseBuilder();
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

class AdminModerationRevokeSanction200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminModerationRevokeSanction200ResponseCodeEnum number0 = _$adminModerationRevokeSanction200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminModerationRevokeSanction200ResponseCodeEnum unknownDefaultOpenApi = _$adminModerationRevokeSanction200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminModerationRevokeSanction200ResponseCodeEnum> get serializer => _$adminModerationRevokeSanction200ResponseCodeEnumSerializer;

  const AdminModerationRevokeSanction200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminModerationRevokeSanction200ResponseCodeEnum> get values => _$adminModerationRevokeSanction200ResponseCodeEnumValues;
  static AdminModerationRevokeSanction200ResponseCodeEnum valueOf(String name) => _$adminModerationRevokeSanction200ResponseCodeEnumValueOf(name);
}
