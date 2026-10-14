//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/discussion_window_target_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/floor_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'floor_window_response_dto.g.dart';

/// FloorWindowResponseDto
///
/// Properties:
/// * [total] - 当前查看者、作者筛选下的可见条数
/// * [maxNumber] - 当前查看者在本范围可访问的最大固定编号，不受作者筛选影响；无可访问内容为 null
/// * [target]
/// * [beforeCursor]
/// * [afterCursor]
/// * [hasBefore]
/// * [hasAfter]
/// * [items] - 自然编号顺序窗口，最多 limit 条；置顶也仅在其自然编号位置
/// * [pinnedItems] - 仅默认首屏返回最多十条置顶；消费者保留置顶区时须按 ID 抑制 items 重复，直接定位时清空置顶区
@BuiltValue()
abstract class FloorWindowResponseDto implements Built<FloorWindowResponseDto, FloorWindowResponseDtoBuilder> {
  /// 当前查看者、作者筛选下的可见条数
  @BuiltValueField(wireName: r'total')
  num get total;

  /// 当前查看者在本范围可访问的最大固定编号，不受作者筛选影响；无可访问内容为 null
  @BuiltValueField(wireName: r'maxNumber')
  num? get maxNumber;

  @BuiltValueField(wireName: r'target')
  DiscussionWindowTargetDto? get target;

  @BuiltValueField(wireName: r'beforeCursor')
  String? get beforeCursor;

  @BuiltValueField(wireName: r'afterCursor')
  String? get afterCursor;

  @BuiltValueField(wireName: r'hasBefore')
  bool get hasBefore;

  @BuiltValueField(wireName: r'hasAfter')
  bool get hasAfter;

  /// 自然编号顺序窗口，最多 limit 条；置顶也仅在其自然编号位置
  @BuiltValueField(wireName: r'items')
  BuiltList<FloorResponseDto> get items;

  /// 仅默认首屏返回最多十条置顶；消费者保留置顶区时须按 ID 抑制 items 重复，直接定位时清空置顶区
  @BuiltValueField(wireName: r'pinnedItems')
  BuiltList<FloorResponseDto> get pinnedItems;

  FloorWindowResponseDto._();

  factory FloorWindowResponseDto([void updates(FloorWindowResponseDtoBuilder b)]) = _$FloorWindowResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FloorWindowResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FloorWindowResponseDto> get serializer => _$FloorWindowResponseDtoSerializer();
}

class _$FloorWindowResponseDtoSerializer implements PrimitiveSerializer<FloorWindowResponseDto> {
  @override
  final Iterable<Type> types = const [FloorWindowResponseDto, _$FloorWindowResponseDto];

  @override
  final String wireName = r'FloorWindowResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FloorWindowResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(num),
    );
    yield r'maxNumber';
    yield object.maxNumber == null ? null : serializers.serialize(
      object.maxNumber,
      specifiedType: const FullType.nullable(num),
    );
    yield r'target';
    yield object.target == null ? null : serializers.serialize(
      object.target,
      specifiedType: const FullType.nullable(DiscussionWindowTargetDto),
    );
    yield r'beforeCursor';
    yield object.beforeCursor == null ? null : serializers.serialize(
      object.beforeCursor,
      specifiedType: const FullType.nullable(String),
    );
    yield r'afterCursor';
    yield object.afterCursor == null ? null : serializers.serialize(
      object.afterCursor,
      specifiedType: const FullType.nullable(String),
    );
    yield r'hasBefore';
    yield serializers.serialize(
      object.hasBefore,
      specifiedType: const FullType(bool),
    );
    yield r'hasAfter';
    yield serializers.serialize(
      object.hasAfter,
      specifiedType: const FullType(bool),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(FloorResponseDto)]),
    );
    yield r'pinnedItems';
    yield serializers.serialize(
      object.pinnedItems,
      specifiedType: const FullType(BuiltList, [FullType(FloorResponseDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FloorWindowResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FloorWindowResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.total = valueDes;
          break;
        case r'maxNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.maxNumber = valueDes;
          break;
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DiscussionWindowTargetDto),
          ) as DiscussionWindowTargetDto?;
          if (valueDes == null) continue;
          result.target.replace(valueDes);
          break;
        case r'beforeCursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.beforeCursor = valueDes;
          break;
        case r'afterCursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.afterCursor = valueDes;
          break;
        case r'hasBefore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasBefore = valueDes;
          break;
        case r'hasAfter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasAfter = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FloorResponseDto)]),
          ) as BuiltList<FloorResponseDto>;
          result.items.replace(valueDes);
          break;
        case r'pinnedItems':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FloorResponseDto)]),
          ) as BuiltList<FloorResponseDto>;
          result.pinnedItems.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FloorWindowResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FloorWindowResponseDtoBuilder();
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
