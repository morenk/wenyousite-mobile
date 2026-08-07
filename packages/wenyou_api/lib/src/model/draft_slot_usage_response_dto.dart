//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'draft_slot_usage_response_dto.g.dart';

/// DraftSlotUsageResponseDto
///
/// Properties:
/// * [usedSlots]
/// * [maxSlots]
/// * [slots] - 已占用槽位编号
@BuiltValue()
abstract class DraftSlotUsageResponseDto implements Built<DraftSlotUsageResponseDto, DraftSlotUsageResponseDtoBuilder> {
  @BuiltValueField(wireName: r'usedSlots')
  num get usedSlots;

  @BuiltValueField(wireName: r'maxSlots')
  num get maxSlots;

  /// 已占用槽位编号
  @BuiltValueField(wireName: r'slots')
  BuiltList<num> get slots;

  DraftSlotUsageResponseDto._();

  factory DraftSlotUsageResponseDto([void updates(DraftSlotUsageResponseDtoBuilder b)]) = _$DraftSlotUsageResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DraftSlotUsageResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DraftSlotUsageResponseDto> get serializer => _$DraftSlotUsageResponseDtoSerializer();
}

class _$DraftSlotUsageResponseDtoSerializer implements PrimitiveSerializer<DraftSlotUsageResponseDto> {
  @override
  final Iterable<Type> types = const [DraftSlotUsageResponseDto, _$DraftSlotUsageResponseDto];

  @override
  final String wireName = r'DraftSlotUsageResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DraftSlotUsageResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'usedSlots';
    yield serializers.serialize(
      object.usedSlots,
      specifiedType: const FullType(num),
    );
    yield r'maxSlots';
    yield serializers.serialize(
      object.maxSlots,
      specifiedType: const FullType(num),
    );
    yield r'slots';
    yield serializers.serialize(
      object.slots,
      specifiedType: const FullType(BuiltList, [FullType(num)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DraftSlotUsageResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DraftSlotUsageResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'usedSlots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.usedSlots = valueDes;
          break;
        case r'maxSlots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.maxSlots = valueDes;
          break;
        case r'slots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(num)]),
          ) as BuiltList<num>;
          result.slots.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DraftSlotUsageResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DraftSlotUsageResponseDtoBuilder();
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
