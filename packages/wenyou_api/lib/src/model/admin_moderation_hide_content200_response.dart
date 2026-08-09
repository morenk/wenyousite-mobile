//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_content_moderation_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_moderation_hide_content200_response.g.dart';

/// AdminModerationHideContent200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminModerationHideContent200Response implements ApiSuccessEnvelope, Built<AdminModerationHideContent200Response, AdminModerationHideContent200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminContentModerationResponseDto get data;

  AdminModerationHideContent200Response._();

  factory AdminModerationHideContent200Response([void updates(AdminModerationHideContent200ResponseBuilder b)]) = _$AdminModerationHideContent200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminModerationHideContent200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminModerationHideContent200Response> get serializer => _$AdminModerationHideContent200ResponseSerializer();
}

class _$AdminModerationHideContent200ResponseSerializer implements PrimitiveSerializer<AdminModerationHideContent200Response> {
  @override
  final Iterable<Type> types = const [AdminModerationHideContent200Response, _$AdminModerationHideContent200Response];

  @override
  final String wireName = r'AdminModerationHideContent200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminModerationHideContent200Response object, {
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
    AdminModerationHideContent200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminModerationHideContent200ResponseBuilder result,
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
  AdminModerationHideContent200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminModerationHideContent200ResponseBuilder();
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

class AdminModerationHideContent200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminModerationHideContent200ResponseCodeEnum number0 = _$adminModerationHideContent200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminModerationHideContent200ResponseCodeEnum unknownDefaultOpenApi = _$adminModerationHideContent200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminModerationHideContent200ResponseCodeEnum> get serializer => _$adminModerationHideContent200ResponseCodeEnumSerializer;

  const AdminModerationHideContent200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminModerationHideContent200ResponseCodeEnum> get values => _$adminModerationHideContent200ResponseCodeEnumValues;
  static AdminModerationHideContent200ResponseCodeEnum valueOf(String name) => _$adminModerationHideContent200ResponseCodeEnumValueOf(name);
}
