//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_job_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_process_submission201_response.g.dart';

/// AdminTextFontsProcessSubmission201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsProcessSubmission201Response implements ApiSuccessEnvelope, Built<AdminTextFontsProcessSubmission201Response, AdminTextFontsProcessSubmission201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontJobDto get data;

  AdminTextFontsProcessSubmission201Response._();

  factory AdminTextFontsProcessSubmission201Response([void updates(AdminTextFontsProcessSubmission201ResponseBuilder b)]) = _$AdminTextFontsProcessSubmission201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsProcessSubmission201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsProcessSubmission201Response> get serializer => _$AdminTextFontsProcessSubmission201ResponseSerializer();
}

class _$AdminTextFontsProcessSubmission201ResponseSerializer implements PrimitiveSerializer<AdminTextFontsProcessSubmission201Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsProcessSubmission201Response, _$AdminTextFontsProcessSubmission201Response];

  @override
  final String wireName = r'AdminTextFontsProcessSubmission201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsProcessSubmission201Response object, {
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
    AdminTextFontsProcessSubmission201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsProcessSubmission201ResponseBuilder result,
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
  AdminTextFontsProcessSubmission201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsProcessSubmission201ResponseBuilder();
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

class AdminTextFontsProcessSubmission201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsProcessSubmission201ResponseCodeEnum number0 = _$adminTextFontsProcessSubmission201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsProcessSubmission201ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsProcessSubmission201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsProcessSubmission201ResponseCodeEnum> get serializer => _$adminTextFontsProcessSubmission201ResponseCodeEnumSerializer;

  const AdminTextFontsProcessSubmission201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsProcessSubmission201ResponseCodeEnum> get values => _$adminTextFontsProcessSubmission201ResponseCodeEnumValues;
  static AdminTextFontsProcessSubmission201ResponseCodeEnum valueOf(String name) => _$adminTextFontsProcessSubmission201ResponseCodeEnumValueOf(name);
}
