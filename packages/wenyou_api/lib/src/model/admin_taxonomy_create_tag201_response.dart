//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/tag_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_taxonomy_create_tag201_response.g.dart';

/// AdminTaxonomyCreateTag201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTaxonomyCreateTag201Response implements ApiSuccessEnvelope, Built<AdminTaxonomyCreateTag201Response, AdminTaxonomyCreateTag201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  TagResponseDto get data;

  AdminTaxonomyCreateTag201Response._();

  factory AdminTaxonomyCreateTag201Response([void updates(AdminTaxonomyCreateTag201ResponseBuilder b)]) = _$AdminTaxonomyCreateTag201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTaxonomyCreateTag201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTaxonomyCreateTag201Response> get serializer => _$AdminTaxonomyCreateTag201ResponseSerializer();
}

class _$AdminTaxonomyCreateTag201ResponseSerializer implements PrimitiveSerializer<AdminTaxonomyCreateTag201Response> {
  @override
  final Iterable<Type> types = const [AdminTaxonomyCreateTag201Response, _$AdminTaxonomyCreateTag201Response];

  @override
  final String wireName = r'AdminTaxonomyCreateTag201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTaxonomyCreateTag201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TagResponseDto),
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
    AdminTaxonomyCreateTag201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTaxonomyCreateTag201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TagResponseDto),
          ) as TagResponseDto;
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
  AdminTaxonomyCreateTag201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTaxonomyCreateTag201ResponseBuilder();
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

class AdminTaxonomyCreateTag201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTaxonomyCreateTag201ResponseCodeEnum number0 = _$adminTaxonomyCreateTag201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTaxonomyCreateTag201ResponseCodeEnum unknownDefaultOpenApi = _$adminTaxonomyCreateTag201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTaxonomyCreateTag201ResponseCodeEnum> get serializer => _$adminTaxonomyCreateTag201ResponseCodeEnumSerializer;

  const AdminTaxonomyCreateTag201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTaxonomyCreateTag201ResponseCodeEnum> get values => _$adminTaxonomyCreateTag201ResponseCodeEnumValues;
  static AdminTaxonomyCreateTag201ResponseCodeEnum valueOf(String name) => _$adminTaxonomyCreateTag201ResponseCodeEnumValueOf(name);
}
