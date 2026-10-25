//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/font_reorder_result_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_reorder200_response.g.dart';

/// AdminTextFontsReorder200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsReorder200Response implements ApiSuccessEnvelope, Built<AdminTextFontsReorder200Response, AdminTextFontsReorder200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontReorderResultDto get data;

  AdminTextFontsReorder200Response._();

  factory AdminTextFontsReorder200Response([void updates(AdminTextFontsReorder200ResponseBuilder b)]) = _$AdminTextFontsReorder200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsReorder200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsReorder200Response> get serializer => _$AdminTextFontsReorder200ResponseSerializer();
}

class _$AdminTextFontsReorder200ResponseSerializer implements PrimitiveSerializer<AdminTextFontsReorder200Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsReorder200Response, _$AdminTextFontsReorder200Response];

  @override
  final String wireName = r'AdminTextFontsReorder200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsReorder200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(FontReorderResultDto),
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
    AdminTextFontsReorder200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsReorder200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontReorderResultDto),
          ) as FontReorderResultDto;
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
  AdminTextFontsReorder200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsReorder200ResponseBuilder();
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

class AdminTextFontsReorder200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsReorder200ResponseCodeEnum number0 = _$adminTextFontsReorder200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsReorder200ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsReorder200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsReorder200ResponseCodeEnum> get serializer => _$adminTextFontsReorder200ResponseCodeEnumSerializer;

  const AdminTextFontsReorder200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsReorder200ResponseCodeEnum> get values => _$adminTextFontsReorder200ResponseCodeEnumValues;
  static AdminTextFontsReorder200ResponseCodeEnum valueOf(String name) => _$adminTextFontsReorder200ResponseCodeEnumValueOf(name);
}
