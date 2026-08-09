//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_category_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_taxonomy_create_category201_response.g.dart';

/// AdminTaxonomyCreateCategory201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTaxonomyCreateCategory201Response implements ApiSuccessEnvelope, Built<AdminTaxonomyCreateCategory201Response, AdminTaxonomyCreateCategory201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadCategoryResponseDto get data;

  AdminTaxonomyCreateCategory201Response._();

  factory AdminTaxonomyCreateCategory201Response([void updates(AdminTaxonomyCreateCategory201ResponseBuilder b)]) = _$AdminTaxonomyCreateCategory201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTaxonomyCreateCategory201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTaxonomyCreateCategory201Response> get serializer => _$AdminTaxonomyCreateCategory201ResponseSerializer();
}

class _$AdminTaxonomyCreateCategory201ResponseSerializer implements PrimitiveSerializer<AdminTaxonomyCreateCategory201Response> {
  @override
  final Iterable<Type> types = const [AdminTaxonomyCreateCategory201Response, _$AdminTaxonomyCreateCategory201Response];

  @override
  final String wireName = r'AdminTaxonomyCreateCategory201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTaxonomyCreateCategory201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ThreadCategoryResponseDto),
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
    AdminTaxonomyCreateCategory201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTaxonomyCreateCategory201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadCategoryResponseDto),
          ) as ThreadCategoryResponseDto;
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
  AdminTaxonomyCreateCategory201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTaxonomyCreateCategory201ResponseBuilder();
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

class AdminTaxonomyCreateCategory201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTaxonomyCreateCategory201ResponseCodeEnum number0 = _$adminTaxonomyCreateCategory201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTaxonomyCreateCategory201ResponseCodeEnum unknownDefaultOpenApi = _$adminTaxonomyCreateCategory201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTaxonomyCreateCategory201ResponseCodeEnum> get serializer => _$adminTaxonomyCreateCategory201ResponseCodeEnumSerializer;

  const AdminTaxonomyCreateCategory201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTaxonomyCreateCategory201ResponseCodeEnum> get values => _$adminTaxonomyCreateCategory201ResponseCodeEnumValues;
  static AdminTaxonomyCreateCategory201ResponseCodeEnum valueOf(String name) => _$adminTaxonomyCreateCategory201ResponseCodeEnumValueOf(name);
}
