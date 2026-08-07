//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_user_search_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_search_users200_response.g.dart';

/// AdminSearchUsers200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminSearchUsers200Response implements ApiSuccessEnvelope, Built<AdminSearchUsers200Response, AdminSearchUsers200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminUserSearchResponseDto get data;

  AdminSearchUsers200Response._();

  factory AdminSearchUsers200Response([void updates(AdminSearchUsers200ResponseBuilder b)]) = _$AdminSearchUsers200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminSearchUsers200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminSearchUsers200Response> get serializer => _$AdminSearchUsers200ResponseSerializer();
}

class _$AdminSearchUsers200ResponseSerializer implements PrimitiveSerializer<AdminSearchUsers200Response> {
  @override
  final Iterable<Type> types = const [AdminSearchUsers200Response, _$AdminSearchUsers200Response];

  @override
  final String wireName = r'AdminSearchUsers200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminSearchUsers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminUserSearchResponseDto),
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
    AdminSearchUsers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminSearchUsers200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserSearchResponseDto),
          ) as AdminUserSearchResponseDto;
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
  AdminSearchUsers200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminSearchUsers200ResponseBuilder();
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

class AdminSearchUsers200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminSearchUsers200ResponseCodeEnum number0 = _$adminSearchUsers200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminSearchUsers200ResponseCodeEnum unknownDefaultOpenApi = _$adminSearchUsers200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminSearchUsers200ResponseCodeEnum> get serializer => _$adminSearchUsers200ResponseCodeEnumSerializer;

  const AdminSearchUsers200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminSearchUsers200ResponseCodeEnum> get values => _$adminSearchUsers200ResponseCodeEnumValues;
  static AdminSearchUsers200ResponseCodeEnum valueOf(String name) => _$adminSearchUsers200ResponseCodeEnumValueOf(name);
}
