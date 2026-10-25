//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_family_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_create201_response.g.dart';

/// AdminTextFontsCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsCreate201Response implements ApiSuccessEnvelope, Built<AdminTextFontsCreate201Response, AdminTextFontsCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontFamilyDto get data;

  AdminTextFontsCreate201Response._();

  factory AdminTextFontsCreate201Response([void updates(AdminTextFontsCreate201ResponseBuilder b)]) = _$AdminTextFontsCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsCreate201Response> get serializer => _$AdminTextFontsCreate201ResponseSerializer();
}

class _$AdminTextFontsCreate201ResponseSerializer implements PrimitiveSerializer<AdminTextFontsCreate201Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsCreate201Response, _$AdminTextFontsCreate201Response];

  @override
  final String wireName = r'AdminTextFontsCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsCreate201Response object, {
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
    AdminTextFontsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsCreate201ResponseBuilder result,
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
  AdminTextFontsCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsCreate201ResponseBuilder();
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

class AdminTextFontsCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsCreate201ResponseCodeEnum number0 = _$adminTextFontsCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsCreate201ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsCreate201ResponseCodeEnum> get serializer => _$adminTextFontsCreate201ResponseCodeEnumSerializer;

  const AdminTextFontsCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsCreate201ResponseCodeEnum> get values => _$adminTextFontsCreate201ResponseCodeEnumValues;
  static AdminTextFontsCreate201ResponseCodeEnum valueOf(String name) => _$adminTextFontsCreate201ResponseCodeEnumValueOf(name);
}
