//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dice_roll_response_dto.g.dart';

/// DiceRollResponseDto
///
/// Properties:
/// * [id]
/// * [postId]
/// * [nodeId] - 正文内联节点 ID
/// * [protocolVersion] - 骰子结果协议版本
/// * [notation] - 规范化后的基础骰子表达式
/// * [quantity]
/// * [sides]
/// * [modifier]
/// * [results] - 每一枚骰子的原始点数
/// * [total] - 逐骰点数之和加修正值
/// * [createdAt]
@BuiltValue()
abstract class DiceRollResponseDto implements Built<DiceRollResponseDto, DiceRollResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'postId')
  String get postId;

  /// 正文内联节点 ID
  @BuiltValueField(wireName: r'nodeId')
  String get nodeId;

  /// 骰子结果协议版本
  @BuiltValueField(wireName: r'protocolVersion')
  num get protocolVersion;

  /// 规范化后的基础骰子表达式
  @BuiltValueField(wireName: r'notation')
  String get notation;

  @BuiltValueField(wireName: r'quantity')
  num get quantity;

  @BuiltValueField(wireName: r'sides')
  num get sides;

  @BuiltValueField(wireName: r'modifier')
  num get modifier;

  /// 每一枚骰子的原始点数
  @BuiltValueField(wireName: r'results')
  BuiltList<num> get results;

  /// 逐骰点数之和加修正值
  @BuiltValueField(wireName: r'total')
  num get total;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  DiceRollResponseDto._();

  factory DiceRollResponseDto([void updates(DiceRollResponseDtoBuilder b)]) = _$DiceRollResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DiceRollResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DiceRollResponseDto> get serializer => _$DiceRollResponseDtoSerializer();
}

class _$DiceRollResponseDtoSerializer implements PrimitiveSerializer<DiceRollResponseDto> {
  @override
  final Iterable<Type> types = const [DiceRollResponseDto, _$DiceRollResponseDto];

  @override
  final String wireName = r'DiceRollResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DiceRollResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'postId';
    yield serializers.serialize(
      object.postId,
      specifiedType: const FullType(String),
    );
    yield r'nodeId';
    yield serializers.serialize(
      object.nodeId,
      specifiedType: const FullType(String),
    );
    yield r'protocolVersion';
    yield serializers.serialize(
      object.protocolVersion,
      specifiedType: const FullType(num),
    );
    yield r'notation';
    yield serializers.serialize(
      object.notation,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(num),
    );
    yield r'sides';
    yield serializers.serialize(
      object.sides,
      specifiedType: const FullType(num),
    );
    yield r'modifier';
    yield serializers.serialize(
      object.modifier,
      specifiedType: const FullType(num),
    );
    yield r'results';
    yield serializers.serialize(
      object.results,
      specifiedType: const FullType(BuiltList, [FullType(num)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(num),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DiceRollResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DiceRollResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'postId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.postId = valueDes;
          break;
        case r'nodeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nodeId = valueDes;
          break;
        case r'protocolVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.protocolVersion = valueDes;
          break;
        case r'notation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.notation = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.quantity = valueDes;
          break;
        case r'sides':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.sides = valueDes;
          break;
        case r'modifier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.modifier = valueDes;
          break;
        case r'results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(num)]),
          ) as BuiltList<num>;
          result.results.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.total = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DiceRollResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DiceRollResponseDtoBuilder();
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
