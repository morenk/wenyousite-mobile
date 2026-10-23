//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/font_version_descriptor_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_withdraw201_response.g.dart';

/// AdminTextFontsWithdraw201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsWithdraw201Response implements ApiSuccessEnvelope, Built<AdminTextFontsWithdraw201Response, AdminTextFontsWithdraw201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontVersionDescriptorDto get data;

  AdminTextFontsWithdraw201Response._();

  factory AdminTextFontsWithdraw201Response([void updates(AdminTextFontsWithdraw201ResponseBuilder b)]) = _$AdminTextFontsWithdraw201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsWithdraw201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsWithdraw201Response> get serializer => _$AdminTextFontsWithdraw201ResponseSerializer();
}

class _$AdminTextFontsWithdraw201ResponseSerializer implements PrimitiveSerializer<AdminTextFontsWithdraw201Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsWithdraw201Response, _$AdminTextFontsWithdraw201Response];

  @override
  final String wireName = r'AdminTextFontsWithdraw201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsWithdraw201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(FontVersionDescriptorDto),
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
    AdminTextFontsWithdraw201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsWithdraw201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontVersionDescriptorDto),
          ) as FontVersionDescriptorDto;
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
  AdminTextFontsWithdraw201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsWithdraw201ResponseBuilder();
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

class AdminTextFontsWithdraw201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsWithdraw201ResponseCodeEnum number0 = _$adminTextFontsWithdraw201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsWithdraw201ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsWithdraw201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsWithdraw201ResponseCodeEnum> get serializer => _$adminTextFontsWithdraw201ResponseCodeEnumSerializer;

  const AdminTextFontsWithdraw201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsWithdraw201ResponseCodeEnum> get values => _$adminTextFontsWithdraw201ResponseCodeEnumValues;
  static AdminTextFontsWithdraw201ResponseCodeEnum valueOf(String name) => _$adminTextFontsWithdraw201ResponseCodeEnumValueOf(name);
}
