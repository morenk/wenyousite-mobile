//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_order_item_dto.g.dart';

/// FontOrderItemDto
///
/// Properties:
/// * [familyId]
/// * [expectedFamilyRevision]
@BuiltValue()
abstract class FontOrderItemDto implements Built<FontOrderItemDto, FontOrderItemDtoBuilder> {
  @BuiltValueField(wireName: r'familyId')
  String get familyId;

  @BuiltValueField(wireName: r'expectedFamilyRevision')
  int get expectedFamilyRevision;

  FontOrderItemDto._();

  factory FontOrderItemDto([void updates(FontOrderItemDtoBuilder b)]) = _$FontOrderItemDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontOrderItemDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontOrderItemDto> get serializer => _$FontOrderItemDtoSerializer();
}

class _$FontOrderItemDtoSerializer implements PrimitiveSerializer<FontOrderItemDto> {
  @override
  final Iterable<Type> types = const [FontOrderItemDto, _$FontOrderItemDto];

  @override
  final String wireName = r'FontOrderItemDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontOrderItemDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'familyId';
    yield serializers.serialize(
      object.familyId,
      specifiedType: const FullType(String),
    );
    yield r'expectedFamilyRevision';
    yield serializers.serialize(
      object.expectedFamilyRevision,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontOrderItemDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontOrderItemDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'familyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.familyId = valueDes;
          break;
        case r'expectedFamilyRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedFamilyRevision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontOrderItemDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontOrderItemDtoBuilder();
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
