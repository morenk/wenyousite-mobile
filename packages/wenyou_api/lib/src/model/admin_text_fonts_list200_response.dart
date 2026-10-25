//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_admin_page_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_list200_response.g.dart';

/// AdminTextFontsList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsList200Response implements ApiSuccessEnvelope, Built<AdminTextFontsList200Response, AdminTextFontsList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontAdminPageDto get data;

  AdminTextFontsList200Response._();

  factory AdminTextFontsList200Response([void updates(AdminTextFontsList200ResponseBuilder b)]) = _$AdminTextFontsList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsList200Response> get serializer => _$AdminTextFontsList200ResponseSerializer();
}

class _$AdminTextFontsList200ResponseSerializer implements PrimitiveSerializer<AdminTextFontsList200Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsList200Response, _$AdminTextFontsList200Response];

  @override
  final String wireName = r'AdminTextFontsList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(FontAdminPageDto),
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
    AdminTextFontsList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsList200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontAdminPageDto),
          ) as FontAdminPageDto;
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
  AdminTextFontsList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsList200ResponseBuilder();
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

class AdminTextFontsList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsList200ResponseCodeEnum number0 = _$adminTextFontsList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsList200ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsList200ResponseCodeEnum> get serializer => _$adminTextFontsList200ResponseCodeEnumSerializer;

  const AdminTextFontsList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsList200ResponseCodeEnum> get values => _$adminTextFontsList200ResponseCodeEnumValues;
  static AdminTextFontsList200ResponseCodeEnum valueOf(String name) => _$adminTextFontsList200ResponseCodeEnumValueOf(name);
}
