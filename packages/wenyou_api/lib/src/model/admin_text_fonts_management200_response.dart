//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_management_page_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_text_fonts_management200_response.g.dart';

/// AdminTextFontsManagement200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTextFontsManagement200Response implements ApiSuccessEnvelope, Built<AdminTextFontsManagement200Response, AdminTextFontsManagement200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontManagementPageDto get data;

  AdminTextFontsManagement200Response._();

  factory AdminTextFontsManagement200Response([void updates(AdminTextFontsManagement200ResponseBuilder b)]) = _$AdminTextFontsManagement200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTextFontsManagement200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTextFontsManagement200Response> get serializer => _$AdminTextFontsManagement200ResponseSerializer();
}

class _$AdminTextFontsManagement200ResponseSerializer implements PrimitiveSerializer<AdminTextFontsManagement200Response> {
  @override
  final Iterable<Type> types = const [AdminTextFontsManagement200Response, _$AdminTextFontsManagement200Response];

  @override
  final String wireName = r'AdminTextFontsManagement200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTextFontsManagement200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(FontManagementPageDto),
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
    AdminTextFontsManagement200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTextFontsManagement200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontManagementPageDto),
          ) as FontManagementPageDto;
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
  AdminTextFontsManagement200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTextFontsManagement200ResponseBuilder();
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

class AdminTextFontsManagement200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTextFontsManagement200ResponseCodeEnum number0 = _$adminTextFontsManagement200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTextFontsManagement200ResponseCodeEnum unknownDefaultOpenApi = _$adminTextFontsManagement200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTextFontsManagement200ResponseCodeEnum> get serializer => _$adminTextFontsManagement200ResponseCodeEnumSerializer;

  const AdminTextFontsManagement200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTextFontsManagement200ResponseCodeEnum> get values => _$adminTextFontsManagement200ResponseCodeEnumValues;
  static AdminTextFontsManagement200ResponseCodeEnum valueOf(String name) => _$adminTextFontsManagement200ResponseCodeEnumValueOf(name);
}
