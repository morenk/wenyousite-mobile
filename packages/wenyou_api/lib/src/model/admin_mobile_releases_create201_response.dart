//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/admin_mobile_release_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_mobile_releases_create201_response.g.dart';

/// AdminMobileReleasesCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminMobileReleasesCreate201Response implements ApiSuccessEnvelope, Built<AdminMobileReleasesCreate201Response, AdminMobileReleasesCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminMobileReleaseDto get data;

  AdminMobileReleasesCreate201Response._();

  factory AdminMobileReleasesCreate201Response([void updates(AdminMobileReleasesCreate201ResponseBuilder b)]) = _$AdminMobileReleasesCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminMobileReleasesCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminMobileReleasesCreate201Response> get serializer => _$AdminMobileReleasesCreate201ResponseSerializer();
}

class _$AdminMobileReleasesCreate201ResponseSerializer implements PrimitiveSerializer<AdminMobileReleasesCreate201Response> {
  @override
  final Iterable<Type> types = const [AdminMobileReleasesCreate201Response, _$AdminMobileReleasesCreate201Response];

  @override
  final String wireName = r'AdminMobileReleasesCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminMobileReleasesCreate201Response object, {
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
    AdminMobileReleasesCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminMobileReleasesCreate201ResponseBuilder result,
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
  AdminMobileReleasesCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminMobileReleasesCreate201ResponseBuilder();
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

class AdminMobileReleasesCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminMobileReleasesCreate201ResponseCodeEnum number0 = _$adminMobileReleasesCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminMobileReleasesCreate201ResponseCodeEnum unknownDefaultOpenApi = _$adminMobileReleasesCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminMobileReleasesCreate201ResponseCodeEnum> get serializer => _$adminMobileReleasesCreate201ResponseCodeEnumSerializer;

  const AdminMobileReleasesCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminMobileReleasesCreate201ResponseCodeEnum> get values => _$adminMobileReleasesCreate201ResponseCodeEnumValues;
  static AdminMobileReleasesCreate201ResponseCodeEnum valueOf(String name) => _$adminMobileReleasesCreate201ResponseCodeEnumValueOf(name);
}
