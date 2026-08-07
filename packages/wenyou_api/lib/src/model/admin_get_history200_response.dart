//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_system_notification_history_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_get_history200_response.g.dart';

/// AdminGetHistory200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminGetHistory200Response implements ApiSuccessEnvelope, Built<AdminGetHistory200Response, AdminGetHistory200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminSystemNotificationHistoryResponseDto get data;

  AdminGetHistory200Response._();

  factory AdminGetHistory200Response([void updates(AdminGetHistory200ResponseBuilder b)]) = _$AdminGetHistory200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminGetHistory200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminGetHistory200Response> get serializer => _$AdminGetHistory200ResponseSerializer();
}

class _$AdminGetHistory200ResponseSerializer implements PrimitiveSerializer<AdminGetHistory200Response> {
  @override
  final Iterable<Type> types = const [AdminGetHistory200Response, _$AdminGetHistory200Response];

  @override
  final String wireName = r'AdminGetHistory200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminGetHistory200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminSystemNotificationHistoryResponseDto),
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
    AdminGetHistory200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminGetHistory200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminSystemNotificationHistoryResponseDto),
          ) as AdminSystemNotificationHistoryResponseDto;
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
  AdminGetHistory200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminGetHistory200ResponseBuilder();
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

class AdminGetHistory200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminGetHistory200ResponseCodeEnum number0 = _$adminGetHistory200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminGetHistory200ResponseCodeEnum unknownDefaultOpenApi = _$adminGetHistory200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminGetHistory200ResponseCodeEnum> get serializer => _$adminGetHistory200ResponseCodeEnumSerializer;

  const AdminGetHistory200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminGetHistory200ResponseCodeEnum> get values => _$adminGetHistory200ResponseCodeEnumValues;
  static AdminGetHistory200ResponseCodeEnum valueOf(String name) => _$adminGetHistory200ResponseCodeEnumValueOf(name);
}
