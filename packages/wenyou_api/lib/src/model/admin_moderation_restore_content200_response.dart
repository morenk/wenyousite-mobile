//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_content_moderation_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_moderation_restore_content200_response.g.dart';

/// AdminModerationRestoreContent200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminModerationRestoreContent200Response implements ApiSuccessEnvelope, Built<AdminModerationRestoreContent200Response, AdminModerationRestoreContent200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminContentModerationResponseDto get data;

  AdminModerationRestoreContent200Response._();

  factory AdminModerationRestoreContent200Response([void updates(AdminModerationRestoreContent200ResponseBuilder b)]) = _$AdminModerationRestoreContent200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminModerationRestoreContent200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminModerationRestoreContent200Response> get serializer => _$AdminModerationRestoreContent200ResponseSerializer();
}

class _$AdminModerationRestoreContent200ResponseSerializer implements PrimitiveSerializer<AdminModerationRestoreContent200Response> {
  @override
  final Iterable<Type> types = const [AdminModerationRestoreContent200Response, _$AdminModerationRestoreContent200Response];

  @override
  final String wireName = r'AdminModerationRestoreContent200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminModerationRestoreContent200Response object, {
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
    AdminModerationRestoreContent200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminModerationRestoreContent200ResponseBuilder result,
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
  AdminModerationRestoreContent200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminModerationRestoreContent200ResponseBuilder();
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

class AdminModerationRestoreContent200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminModerationRestoreContent200ResponseCodeEnum number0 = _$adminModerationRestoreContent200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminModerationRestoreContent200ResponseCodeEnum unknownDefaultOpenApi = _$adminModerationRestoreContent200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminModerationRestoreContent200ResponseCodeEnum> get serializer => _$adminModerationRestoreContent200ResponseCodeEnumSerializer;

  const AdminModerationRestoreContent200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminModerationRestoreContent200ResponseCodeEnum> get values => _$adminModerationRestoreContent200ResponseCodeEnumValues;
  static AdminModerationRestoreContent200ResponseCodeEnum valueOf(String name) => _$adminModerationRestoreContent200ResponseCodeEnumValueOf(name);
}
