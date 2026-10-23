//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/font_admin_family_detail_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_detail200_response.g.dart';

/// AdminTextFontsDetail200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsDetail200Response implements ApiSuccessEnvelope, Built<AdminTextFontsDetail200Response, AdminTextFontsDetail200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontAdminFamilyDetailDto get data;

  AdminTextFontsDetail200Response._();

  factory AdminTextFontsDetail200Response([void updates(AdminTextFontsDetail200ResponseBuilder b)]) = _$AdminTextFontsDetail200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsDetail200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsDetail200Response> get serializer => _$AdminTextFontsDetail200ResponseSerializer();
}

class _$AdminTextFontsDetail200ResponseSerializer implements PrimitiveSerializer<AdminTextFontsDetail200Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsDetail200Response, _$AdminTextFontsDetail200Response];

  @override
  final String wireName = r'AdminTextFontsDetail200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsDetail200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(FontAdminFamilyDetailDto),
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
    AdminTextFontsDetail200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsDetail200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontAdminFamilyDetailDto),
          ) as FontAdminFamilyDetailDto;
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
  AdminTextFontsDetail200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsDetail200ResponseBuilder();
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

class AdminTextFontsDetail200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsDetail200ResponseCodeEnum number0 = _$adminTextFontsDetail200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsDetail200ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsDetail200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsDetail200ResponseCodeEnum> get serializer => _$adminTextFontsDetail200ResponseCodeEnumSerializer;

  const AdminTextFontsDetail200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsDetail200ResponseCodeEnum> get values => _$adminTextFontsDetail200ResponseCodeEnumValues;
  static AdminTextFontsDetail200ResponseCodeEnum valueOf(String name) => _$adminTextFontsDetail200ResponseCodeEnumValueOf(name);
}
