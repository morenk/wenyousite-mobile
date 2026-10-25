//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_family_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_update200_response.g.dart';

/// AdminTextFontsUpdate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsUpdate200Response implements ApiSuccessEnvelope, Built<AdminTextFontsUpdate200Response, AdminTextFontsUpdate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontFamilyDto get data;

  AdminTextFontsUpdate200Response._();

  factory AdminTextFontsUpdate200Response([void updates(AdminTextFontsUpdate200ResponseBuilder b)]) = _$AdminTextFontsUpdate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsUpdate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsUpdate200Response> get serializer => _$AdminTextFontsUpdate200ResponseSerializer();
}

class _$AdminTextFontsUpdate200ResponseSerializer implements PrimitiveSerializer<AdminTextFontsUpdate200Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsUpdate200Response, _$AdminTextFontsUpdate200Response];

  @override
  final String wireName = r'AdminTextFontsUpdate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(FontFamilyDto),
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
    AdminTextFontsUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsUpdate200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontFamilyDto),
          ) as FontFamilyDto;
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
  AdminTextFontsUpdate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsUpdate200ResponseBuilder();
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

class AdminTextFontsUpdate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsUpdate200ResponseCodeEnum number0 = _$adminTextFontsUpdate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsUpdate200ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsUpdate200ResponseCodeEnum> get serializer => _$adminTextFontsUpdate200ResponseCodeEnumSerializer;

  const AdminTextFontsUpdate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsUpdate200ResponseCodeEnum> get values => _$adminTextFontsUpdate200ResponseCodeEnumValues;
  static AdminTextFontsUpdate200ResponseCodeEnum valueOf(String name) => _$adminTextFontsUpdate200ResponseCodeEnumValueOf(name);
}
