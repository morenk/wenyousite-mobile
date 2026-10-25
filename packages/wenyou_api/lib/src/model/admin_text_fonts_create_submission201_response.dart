//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/font_submission_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_create_submission201_response.g.dart';

/// AdminTextFontsCreateSubmission201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsCreateSubmission201Response implements ApiSuccessEnvelope, Built<AdminTextFontsCreateSubmission201Response, AdminTextFontsCreateSubmission201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontSubmissionDto get data;

  AdminTextFontsCreateSubmission201Response._();

  factory AdminTextFontsCreateSubmission201Response([void updates(AdminTextFontsCreateSubmission201ResponseBuilder b)]) = _$AdminTextFontsCreateSubmission201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsCreateSubmission201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsCreateSubmission201Response> get serializer => _$AdminTextFontsCreateSubmission201ResponseSerializer();
}

class _$AdminTextFontsCreateSubmission201ResponseSerializer implements PrimitiveSerializer<AdminTextFontsCreateSubmission201Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsCreateSubmission201Response, _$AdminTextFontsCreateSubmission201Response];

  @override
  final String wireName = r'AdminTextFontsCreateSubmission201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsCreateSubmission201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(FontSubmissionDto),
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
    AdminTextFontsCreateSubmission201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsCreateSubmission201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontSubmissionDto),
          ) as FontSubmissionDto;
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
  AdminTextFontsCreateSubmission201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsCreateSubmission201ResponseBuilder();
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

class AdminTextFontsCreateSubmission201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsCreateSubmission201ResponseCodeEnum number0 = _$adminTextFontsCreateSubmission201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsCreateSubmission201ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsCreateSubmission201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsCreateSubmission201ResponseCodeEnum> get serializer => _$adminTextFontsCreateSubmission201ResponseCodeEnumSerializer;

  const AdminTextFontsCreateSubmission201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsCreateSubmission201ResponseCodeEnum> get values => _$adminTextFontsCreateSubmission201ResponseCodeEnumValues;
  static AdminTextFontsCreateSubmission201ResponseCodeEnum valueOf(String name) => _$adminTextFontsCreateSubmission201ResponseCodeEnumValueOf(name);
}
