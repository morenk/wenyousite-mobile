//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/font_submission_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_submission200_response.g.dart';

/// AdminTextFontsSubmission200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsSubmission200Response implements ApiSuccessEnvelope, Built<AdminTextFontsSubmission200Response, AdminTextFontsSubmission200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontSubmissionDto get data;

  AdminTextFontsSubmission200Response._();

  factory AdminTextFontsSubmission200Response([void updates(AdminTextFontsSubmission200ResponseBuilder b)]) = _$AdminTextFontsSubmission200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsSubmission200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsSubmission200Response> get serializer => _$AdminTextFontsSubmission200ResponseSerializer();
}

class _$AdminTextFontsSubmission200ResponseSerializer implements PrimitiveSerializer<AdminTextFontsSubmission200Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsSubmission200Response, _$AdminTextFontsSubmission200Response];

  @override
  final String wireName = r'AdminTextFontsSubmission200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsSubmission200Response object, {
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
    AdminTextFontsSubmission200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsSubmission200ResponseBuilder result,
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
  AdminTextFontsSubmission200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsSubmission200ResponseBuilder();
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

class AdminTextFontsSubmission200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsSubmission200ResponseCodeEnum number0 = _$adminTextFontsSubmission200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsSubmission200ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsSubmission200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsSubmission200ResponseCodeEnum> get serializer => _$adminTextFontsSubmission200ResponseCodeEnumSerializer;

  const AdminTextFontsSubmission200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsSubmission200ResponseCodeEnum> get values => _$adminTextFontsSubmission200ResponseCodeEnumValues;
  static AdminTextFontsSubmission200ResponseCodeEnum valueOf(String name) => _$adminTextFontsSubmission200ResponseCodeEnumValueOf(name);
}
