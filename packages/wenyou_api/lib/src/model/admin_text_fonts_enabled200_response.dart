//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_family_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_enabled200_response.g.dart';

/// AdminTextFontsEnabled200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsEnabled200Response implements ApiSuccessEnvelope, Built<AdminTextFontsEnabled200Response, AdminTextFontsEnabled200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontFamilyDto get data;

  AdminTextFontsEnabled200Response._();

  factory AdminTextFontsEnabled200Response([void updates(AdminTextFontsEnabled200ResponseBuilder b)]) = _$AdminTextFontsEnabled200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsEnabled200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsEnabled200Response> get serializer => _$AdminTextFontsEnabled200ResponseSerializer();
}

class _$AdminTextFontsEnabled200ResponseSerializer implements PrimitiveSerializer<AdminTextFontsEnabled200Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsEnabled200Response, _$AdminTextFontsEnabled200Response];

  @override
  final String wireName = r'AdminTextFontsEnabled200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsEnabled200Response object, {
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
    AdminTextFontsEnabled200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsEnabled200ResponseBuilder result,
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
  AdminTextFontsEnabled200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsEnabled200ResponseBuilder();
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

class AdminTextFontsEnabled200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsEnabled200ResponseCodeEnum number0 = _$adminTextFontsEnabled200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsEnabled200ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsEnabled200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsEnabled200ResponseCodeEnum> get serializer => _$adminTextFontsEnabled200ResponseCodeEnumSerializer;

  const AdminTextFontsEnabled200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsEnabled200ResponseCodeEnum> get values => _$adminTextFontsEnabled200ResponseCodeEnumValues;
  static AdminTextFontsEnabled200ResponseCodeEnum valueOf(String name) => _$adminTextFontsEnabled200ResponseCodeEnumValueOf(name);
}
