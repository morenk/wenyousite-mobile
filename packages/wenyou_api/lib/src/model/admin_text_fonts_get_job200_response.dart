//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_job_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_get_job200_response.g.dart';

/// AdminTextFontsGetJob200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsGetJob200Response implements ApiSuccessEnvelope, Built<AdminTextFontsGetJob200Response, AdminTextFontsGetJob200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontJobDto get data;

  AdminTextFontsGetJob200Response._();

  factory AdminTextFontsGetJob200Response([void updates(AdminTextFontsGetJob200ResponseBuilder b)]) = _$AdminTextFontsGetJob200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsGetJob200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsGetJob200Response> get serializer => _$AdminTextFontsGetJob200ResponseSerializer();
}

class _$AdminTextFontsGetJob200ResponseSerializer implements PrimitiveSerializer<AdminTextFontsGetJob200Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsGetJob200Response, _$AdminTextFontsGetJob200Response];

  @override
  final String wireName = r'AdminTextFontsGetJob200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsGetJob200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(FontJobDto),
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
    AdminTextFontsGetJob200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsGetJob200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontJobDto),
          ) as FontJobDto;
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
  AdminTextFontsGetJob200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsGetJob200ResponseBuilder();
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

class AdminTextFontsGetJob200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsGetJob200ResponseCodeEnum number0 = _$adminTextFontsGetJob200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsGetJob200ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsGetJob200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsGetJob200ResponseCodeEnum> get serializer => _$adminTextFontsGetJob200ResponseCodeEnumSerializer;

  const AdminTextFontsGetJob200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsGetJob200ResponseCodeEnum> get values => _$adminTextFontsGetJob200ResponseCodeEnumValues;
  static AdminTextFontsGetJob200ResponseCodeEnum valueOf(String name) => _$adminTextFontsGetJob200ResponseCodeEnumValueOf(name);
}
