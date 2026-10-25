//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_job_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_upload201_response.g.dart';

/// AdminTextFontsUpload201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsUpload201Response implements ApiSuccessEnvelope, Built<AdminTextFontsUpload201Response, AdminTextFontsUpload201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontJobDto get data;

  AdminTextFontsUpload201Response._();

  factory AdminTextFontsUpload201Response([void updates(AdminTextFontsUpload201ResponseBuilder b)]) = _$AdminTextFontsUpload201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsUpload201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsUpload201Response> get serializer => _$AdminTextFontsUpload201ResponseSerializer();
}

class _$AdminTextFontsUpload201ResponseSerializer implements PrimitiveSerializer<AdminTextFontsUpload201Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsUpload201Response, _$AdminTextFontsUpload201Response];

  @override
  final String wireName = r'AdminTextFontsUpload201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsUpload201Response object, {
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
    AdminTextFontsUpload201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsUpload201ResponseBuilder result,
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
  AdminTextFontsUpload201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsUpload201ResponseBuilder();
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

class AdminTextFontsUpload201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsUpload201ResponseCodeEnum number0 = _$adminTextFontsUpload201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsUpload201ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsUpload201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsUpload201ResponseCodeEnum> get serializer => _$adminTextFontsUpload201ResponseCodeEnumSerializer;

  const AdminTextFontsUpload201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsUpload201ResponseCodeEnum> get values => _$adminTextFontsUpload201ResponseCodeEnumValues;
  static AdminTextFontsUpload201ResponseCodeEnum valueOf(String name) => _$adminTextFontsUpload201ResponseCodeEnumValueOf(name);
}
