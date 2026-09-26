//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/admin_mobile_release_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_mobile_releases_update200_response.g.dart';

/// AdminMobileReleasesUpdate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminMobileReleasesUpdate200Response implements ApiSuccessEnvelope, Built<AdminMobileReleasesUpdate200Response, AdminMobileReleasesUpdate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminMobileReleaseDto get data;

  AdminMobileReleasesUpdate200Response._();

  factory AdminMobileReleasesUpdate200Response([void updates(AdminMobileReleasesUpdate200ResponseBuilder b)]) = _$AdminMobileReleasesUpdate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminMobileReleasesUpdate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminMobileReleasesUpdate200Response> get serializer => _$AdminMobileReleasesUpdate200ResponseSerializer();
}

class _$AdminMobileReleasesUpdate200ResponseSerializer implements PrimitiveSerializer<AdminMobileReleasesUpdate200Response> {
  @override
  final Iterable<Type> types = const [AdminMobileReleasesUpdate200Response, _$AdminMobileReleasesUpdate200Response];

  @override
  final String wireName = r'AdminMobileReleasesUpdate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminMobileReleasesUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminMobileReleaseDto),
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
    AdminMobileReleasesUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminMobileReleasesUpdate200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminMobileReleaseDto),
          ) as AdminMobileReleaseDto;
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
  AdminMobileReleasesUpdate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminMobileReleasesUpdate200ResponseBuilder();
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

class AdminMobileReleasesUpdate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminMobileReleasesUpdate200ResponseCodeEnum number0 = _$adminMobileReleasesUpdate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminMobileReleasesUpdate200ResponseCodeEnum unknownDefaultOpenApi = _$adminMobileReleasesUpdate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminMobileReleasesUpdate200ResponseCodeEnum> get serializer => _$adminMobileReleasesUpdate200ResponseCodeEnumSerializer;

  const AdminMobileReleasesUpdate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminMobileReleasesUpdate200ResponseCodeEnum> get values => _$adminMobileReleasesUpdate200ResponseCodeEnumValues;
  static AdminMobileReleasesUpdate200ResponseCodeEnum valueOf(String name) => _$adminMobileReleasesUpdate200ResponseCodeEnumValueOf(name);
}
