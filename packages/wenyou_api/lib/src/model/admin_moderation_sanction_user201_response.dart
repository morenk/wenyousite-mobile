//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_user_sanction_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_moderation_sanction_user201_response.g.dart';

/// AdminModerationSanctionUser201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminModerationSanctionUser201Response implements ApiSuccessEnvelope, Built<AdminModerationSanctionUser201Response, AdminModerationSanctionUser201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminUserSanctionResponseDto get data;

  AdminModerationSanctionUser201Response._();

  factory AdminModerationSanctionUser201Response([void updates(AdminModerationSanctionUser201ResponseBuilder b)]) = _$AdminModerationSanctionUser201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminModerationSanctionUser201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminModerationSanctionUser201Response> get serializer => _$AdminModerationSanctionUser201ResponseSerializer();
}

class _$AdminModerationSanctionUser201ResponseSerializer implements PrimitiveSerializer<AdminModerationSanctionUser201Response> {
  @override
  final Iterable<Type> types = const [AdminModerationSanctionUser201Response, _$AdminModerationSanctionUser201Response];

  @override
  final String wireName = r'AdminModerationSanctionUser201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminModerationSanctionUser201Response object, {
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
    AdminModerationSanctionUser201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminModerationSanctionUser201ResponseBuilder result,
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
  AdminModerationSanctionUser201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminModerationSanctionUser201ResponseBuilder();
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

class AdminModerationSanctionUser201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminModerationSanctionUser201ResponseCodeEnum number0 = _$adminModerationSanctionUser201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminModerationSanctionUser201ResponseCodeEnum unknownDefaultOpenApi = _$adminModerationSanctionUser201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminModerationSanctionUser201ResponseCodeEnum> get serializer => _$adminModerationSanctionUser201ResponseCodeEnumSerializer;

  const AdminModerationSanctionUser201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminModerationSanctionUser201ResponseCodeEnum> get values => _$adminModerationSanctionUser201ResponseCodeEnumValues;
  static AdminModerationSanctionUser201ResponseCodeEnum valueOf(String name) => _$adminModerationSanctionUser201ResponseCodeEnumValueOf(name);
}
