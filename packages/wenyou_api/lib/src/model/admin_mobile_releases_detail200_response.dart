//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/admin_mobile_release_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_mobile_releases_detail200_response.g.dart';

/// AdminMobileReleasesDetail200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminMobileReleasesDetail200Response implements ApiSuccessEnvelope, Built<AdminMobileReleasesDetail200Response, AdminMobileReleasesDetail200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminMobileReleaseDto get data;

  AdminMobileReleasesDetail200Response._();

  factory AdminMobileReleasesDetail200Response([void updates(AdminMobileReleasesDetail200ResponseBuilder b)]) = _$AdminMobileReleasesDetail200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminMobileReleasesDetail200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminMobileReleasesDetail200Response> get serializer => _$AdminMobileReleasesDetail200ResponseSerializer();
}

class _$AdminMobileReleasesDetail200ResponseSerializer implements PrimitiveSerializer<AdminMobileReleasesDetail200Response> {
  @override
  final Iterable<Type> types = const [AdminMobileReleasesDetail200Response, _$AdminMobileReleasesDetail200Response];

  @override
  final String wireName = r'AdminMobileReleasesDetail200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminMobileReleasesDetail200Response object, {
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
    AdminMobileReleasesDetail200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminMobileReleasesDetail200ResponseBuilder result,
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
  AdminMobileReleasesDetail200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminMobileReleasesDetail200ResponseBuilder();
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

class AdminMobileReleasesDetail200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminMobileReleasesDetail200ResponseCodeEnum number0 = _$adminMobileReleasesDetail200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminMobileReleasesDetail200ResponseCodeEnum unknownDefaultOpenApi = _$adminMobileReleasesDetail200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminMobileReleasesDetail200ResponseCodeEnum> get serializer => _$adminMobileReleasesDetail200ResponseCodeEnumSerializer;

  const AdminMobileReleasesDetail200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminMobileReleasesDetail200ResponseCodeEnum> get values => _$adminMobileReleasesDetail200ResponseCodeEnumValues;
  static AdminMobileReleasesDetail200ResponseCodeEnum valueOf(String name) => _$adminMobileReleasesDetail200ResponseCodeEnumValueOf(name);
}
