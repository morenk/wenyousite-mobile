//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/admin_mobile_release_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_mobile_releases_confirm201_response.g.dart';

/// AdminMobileReleasesConfirm201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminMobileReleasesConfirm201Response implements ApiSuccessEnvelope, Built<AdminMobileReleasesConfirm201Response, AdminMobileReleasesConfirm201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminMobileReleaseDto get data;

  AdminMobileReleasesConfirm201Response._();

  factory AdminMobileReleasesConfirm201Response([void updates(AdminMobileReleasesConfirm201ResponseBuilder b)]) = _$AdminMobileReleasesConfirm201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminMobileReleasesConfirm201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminMobileReleasesConfirm201Response> get serializer => _$AdminMobileReleasesConfirm201ResponseSerializer();
}

class _$AdminMobileReleasesConfirm201ResponseSerializer implements PrimitiveSerializer<AdminMobileReleasesConfirm201Response> {
  @override
  final Iterable<Type> types = const [AdminMobileReleasesConfirm201Response, _$AdminMobileReleasesConfirm201Response];

  @override
  final String wireName = r'AdminMobileReleasesConfirm201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminMobileReleasesConfirm201Response object, {
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
    AdminMobileReleasesConfirm201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminMobileReleasesConfirm201ResponseBuilder result,
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
  AdminMobileReleasesConfirm201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminMobileReleasesConfirm201ResponseBuilder();
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

class AdminMobileReleasesConfirm201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminMobileReleasesConfirm201ResponseCodeEnum number0 = _$adminMobileReleasesConfirm201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminMobileReleasesConfirm201ResponseCodeEnum unknownDefaultOpenApi = _$adminMobileReleasesConfirm201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminMobileReleasesConfirm201ResponseCodeEnum> get serializer => _$adminMobileReleasesConfirm201ResponseCodeEnumSerializer;

  const AdminMobileReleasesConfirm201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminMobileReleasesConfirm201ResponseCodeEnum> get values => _$adminMobileReleasesConfirm201ResponseCodeEnumValues;
  static AdminMobileReleasesConfirm201ResponseCodeEnum valueOf(String name) => _$adminMobileReleasesConfirm201ResponseCodeEnumValueOf(name);
}
