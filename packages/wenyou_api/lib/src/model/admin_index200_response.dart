//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_capability_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_index200_response.g.dart';

/// AdminIndex200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminIndex200Response implements ApiSuccessEnvelope, Built<AdminIndex200Response, AdminIndex200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminCapabilityResponseDto get data;

  AdminIndex200Response._();

  factory AdminIndex200Response([void updates(AdminIndex200ResponseBuilder b)]) = _$AdminIndex200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminIndex200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminIndex200Response> get serializer => _$AdminIndex200ResponseSerializer();
}

class _$AdminIndex200ResponseSerializer implements PrimitiveSerializer<AdminIndex200Response> {
  @override
  final Iterable<Type> types = const [AdminIndex200Response, _$AdminIndex200Response];

  @override
  final String wireName = r'AdminIndex200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminCapabilityResponseDto),
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
    AdminIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminIndex200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminCapabilityResponseDto),
          ) as AdminCapabilityResponseDto;
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
  AdminIndex200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminIndex200ResponseBuilder();
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

class AdminIndex200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminIndex200ResponseCodeEnum number0 = _$adminIndex200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminIndex200ResponseCodeEnum unknownDefaultOpenApi = _$adminIndex200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminIndex200ResponseCodeEnum> get serializer => _$adminIndex200ResponseCodeEnumSerializer;

  const AdminIndex200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminIndex200ResponseCodeEnum> get values => _$adminIndex200ResponseCodeEnumValues;
  static AdminIndex200ResponseCodeEnum valueOf(String name) => _$adminIndex200ResponseCodeEnumValueOf(name);
}
