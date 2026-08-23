//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/draft_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'draft_state_response_dto.g.dart';

/// DraftStateResponseDto
///
/// Properties:
/// * [usedSlots]
/// * [maxSlots]
/// * [slots] - 已占用槽位编号
/// * [drafts]
@BuiltValue()
abstract class DraftStateResponseDto implements Built<DraftStateResponseDto, DraftStateResponseDtoBuilder> {
  @BuiltValueField(wireName: r'usedSlots')
  num get usedSlots;

  @BuiltValueField(wireName: r'maxSlots')
  num get maxSlots;

  /// 已占用槽位编号
  @BuiltValueField(wireName: r'slots')
  BuiltList<num> get slots;

  @BuiltValueField(wireName: r'drafts')
  BuiltList<DraftResponseDto> get drafts;

  DraftStateResponseDto._();

  factory DraftStateResponseDto([void updates(DraftStateResponseDtoBuilder b)]) = _$DraftStateResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DraftStateResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DraftStateResponseDto> get serializer => _$DraftStateResponseDtoSerializer();
}

class _$DraftStateResponseDtoSerializer implements PrimitiveSerializer<DraftStateResponseDto> {
  @override
  final Iterable<Type> types = const [DraftStateResponseDto, _$DraftStateResponseDto];

  @override
  final String wireName = r'DraftStateResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DraftStateResponseDto object, {
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
    yield r'drafts';
    yield serializers.serialize(
      object.drafts,
      specifiedType: const FullType(BuiltList, [FullType(DraftResponseDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DraftStateResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DraftStateResponseDtoBuilder result,
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
        case r'drafts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DraftResponseDto)]),
          ) as BuiltList<DraftResponseDto>;
          result.drafts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DraftStateResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DraftStateResponseDtoBuilder();
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
