//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_family_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_publish201_response.g.dart';

/// AdminTextFontsPublish201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsPublish201Response implements ApiSuccessEnvelope, Built<AdminTextFontsPublish201Response, AdminTextFontsPublish201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontFamilyDto get data;

  AdminTextFontsPublish201Response._();

  factory AdminTextFontsPublish201Response([void updates(AdminTextFontsPublish201ResponseBuilder b)]) = _$AdminTextFontsPublish201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsPublish201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsPublish201Response> get serializer => _$AdminTextFontsPublish201ResponseSerializer();
}

class _$AdminTextFontsPublish201ResponseSerializer implements PrimitiveSerializer<AdminTextFontsPublish201Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsPublish201Response, _$AdminTextFontsPublish201Response];

  @override
  final String wireName = r'AdminTextFontsPublish201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsPublish201Response object, {
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
    AdminTextFontsPublish201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsPublish201ResponseBuilder result,
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
  AdminTextFontsPublish201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsPublish201ResponseBuilder();
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

class AdminTextFontsPublish201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsPublish201ResponseCodeEnum number0 = _$adminTextFontsPublish201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsPublish201ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsPublish201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsPublish201ResponseCodeEnum> get serializer => _$adminTextFontsPublish201ResponseCodeEnumSerializer;

  const AdminTextFontsPublish201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsPublish201ResponseCodeEnum> get values => _$adminTextFontsPublish201ResponseCodeEnumValues;
  static AdminTextFontsPublish201ResponseCodeEnum valueOf(String name) => _$adminTextFontsPublish201ResponseCodeEnumValueOf(name);
}
