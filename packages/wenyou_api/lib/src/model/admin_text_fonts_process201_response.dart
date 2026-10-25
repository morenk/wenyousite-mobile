//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_job_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_process201_response.g.dart';

/// AdminTextFontsProcess201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsProcess201Response implements ApiSuccessEnvelope, Built<AdminTextFontsProcess201Response, AdminTextFontsProcess201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontJobDto get data;

  AdminTextFontsProcess201Response._();

  factory AdminTextFontsProcess201Response([void updates(AdminTextFontsProcess201ResponseBuilder b)]) = _$AdminTextFontsProcess201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsProcess201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsProcess201Response> get serializer => _$AdminTextFontsProcess201ResponseSerializer();
}

class _$AdminTextFontsProcess201ResponseSerializer implements PrimitiveSerializer<AdminTextFontsProcess201Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsProcess201Response, _$AdminTextFontsProcess201Response];

  @override
  final String wireName = r'AdminTextFontsProcess201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsProcess201Response object, {
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
    AdminTextFontsProcess201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsProcess201ResponseBuilder result,
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
  AdminTextFontsProcess201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsProcess201ResponseBuilder();
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

class AdminTextFontsProcess201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsProcess201ResponseCodeEnum number0 = _$adminTextFontsProcess201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsProcess201ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsProcess201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsProcess201ResponseCodeEnum> get serializer => _$adminTextFontsProcess201ResponseCodeEnumSerializer;

  const AdminTextFontsProcess201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsProcess201ResponseCodeEnum> get values => _$adminTextFontsProcess201ResponseCodeEnumValues;
  static AdminTextFontsProcess201ResponseCodeEnum valueOf(String name) => _$adminTextFontsProcess201ResponseCodeEnumValueOf(name);
}
