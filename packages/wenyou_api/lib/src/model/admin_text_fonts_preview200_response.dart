//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/font_version_descriptor_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_preview200_response.g.dart';

/// AdminTextFontsPreview200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsPreview200Response implements ApiSuccessEnvelope, Built<AdminTextFontsPreview200Response, AdminTextFontsPreview200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontVersionDescriptorDto get data;

  AdminTextFontsPreview200Response._();

  factory AdminTextFontsPreview200Response([void updates(AdminTextFontsPreview200ResponseBuilder b)]) = _$AdminTextFontsPreview200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsPreview200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsPreview200Response> get serializer => _$AdminTextFontsPreview200ResponseSerializer();
}

class _$AdminTextFontsPreview200ResponseSerializer implements PrimitiveSerializer<AdminTextFontsPreview200Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsPreview200Response, _$AdminTextFontsPreview200Response];

  @override
  final String wireName = r'AdminTextFontsPreview200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsPreview200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(FontVersionDescriptorDto),
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
    AdminTextFontsPreview200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsPreview200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontVersionDescriptorDto),
          ) as FontVersionDescriptorDto;
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
  AdminTextFontsPreview200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsPreview200ResponseBuilder();
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

class AdminTextFontsPreview200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsPreview200ResponseCodeEnum number0 = _$adminTextFontsPreview200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsPreview200ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsPreview200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsPreview200ResponseCodeEnum> get serializer => _$adminTextFontsPreview200ResponseCodeEnumSerializer;

  const AdminTextFontsPreview200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsPreview200ResponseCodeEnum> get values => _$adminTextFontsPreview200ResponseCodeEnumValues;
  static AdminTextFontsPreview200ResponseCodeEnum valueOf(String name) => _$adminTextFontsPreview200ResponseCodeEnumValueOf(name);
}
