//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_content_taxonomy_dto.g.dart';

/// UpdateContentTaxonomyDto
///
/// Properties:
/// * [version]
/// * [reason]
/// * [category] - 省略保持原值，不可清空
/// * [tagIds]
@BuiltValue()
abstract class UpdateContentTaxonomyDto implements Built<UpdateContentTaxonomyDto, UpdateContentTaxonomyDtoBuilder> {
  @BuiltValueField(wireName: r'version')
  num get version;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  /// 省略保持原值，不可清空
  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'tagIds')
  BuiltList<String>? get tagIds;

  UpdateContentTaxonomyDto._();

  factory UpdateContentTaxonomyDto([void updates(UpdateContentTaxonomyDtoBuilder b)]) = _$UpdateContentTaxonomyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateContentTaxonomyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateContentTaxonomyDto> get serializer => _$UpdateContentTaxonomyDtoSerializer();
}

class _$UpdateContentTaxonomyDtoSerializer implements PrimitiveSerializer<UpdateContentTaxonomyDto> {
  @override
  final Iterable<Type> types = const [UpdateContentTaxonomyDto, _$UpdateContentTaxonomyDto];

  @override
  final String wireName = r'UpdateContentTaxonomyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateContentTaxonomyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    if (object.category != null) {
      yield r'category';
      yield serializers.serialize(
        object.category,
        specifiedType: const FullType(String),
      );
    }
    if (object.tagIds != null) {
      yield r'tagIds';
      yield serializers.serialize(
        object.tagIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateContentTaxonomyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateContentTaxonomyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.category = valueDes;
          break;
        case r'tagIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.tagIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateContentTaxonomyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateContentTaxonomyDtoBuilder();
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
