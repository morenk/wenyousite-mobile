//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recent_reply_dice_response_dto.g.dart';

/// RecentReplyDiceResponseDto
///
/// Properties:
/// * [nodeId]
/// * [notation]
/// * [total]
@BuiltValue()
abstract class RecentReplyDiceResponseDto implements Built<RecentReplyDiceResponseDto, RecentReplyDiceResponseDtoBuilder> {
  @BuiltValueField(wireName: r'nodeId')
  String get nodeId;

  @BuiltValueField(wireName: r'notation')
  String get notation;

  @BuiltValueField(wireName: r'total')
  num get total;

  RecentReplyDiceResponseDto._();

  factory RecentReplyDiceResponseDto([void updates(RecentReplyDiceResponseDtoBuilder b)]) = _$RecentReplyDiceResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecentReplyDiceResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecentReplyDiceResponseDto> get serializer => _$RecentReplyDiceResponseDtoSerializer();
}

class _$RecentReplyDiceResponseDtoSerializer implements PrimitiveSerializer<RecentReplyDiceResponseDto> {
  @override
  final Iterable<Type> types = const [RecentReplyDiceResponseDto, _$RecentReplyDiceResponseDto];

  @override
  final String wireName = r'RecentReplyDiceResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecentReplyDiceResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'nodeId';
    yield serializers.serialize(
      object.nodeId,
      specifiedType: const FullType(String),
    );
    yield r'notation';
    yield serializers.serialize(
      object.notation,
      specifiedType: const FullType(String),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecentReplyDiceResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecentReplyDiceResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'nodeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nodeId = valueDes;
          break;
        case r'notation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.notation = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecentReplyDiceResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecentReplyDiceResponseDtoBuilder();
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
