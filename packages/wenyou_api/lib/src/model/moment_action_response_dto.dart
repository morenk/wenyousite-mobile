//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_action_response_dto.g.dart';

/// MomentActionResponseDto
///
/// Properties:
/// * [momentId]
/// * [count]
/// * [active]
@BuiltValue()
abstract class MomentActionResponseDto implements Built<MomentActionResponseDto, MomentActionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'momentId')
  String get momentId;

  @BuiltValueField(wireName: r'count')
  num get count;

  @BuiltValueField(wireName: r'active')
  bool get active;

  MomentActionResponseDto._();

  factory MomentActionResponseDto([void updates(MomentActionResponseDtoBuilder b)]) = _$MomentActionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentActionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentActionResponseDto> get serializer => _$MomentActionResponseDtoSerializer();
}

class _$MomentActionResponseDtoSerializer implements PrimitiveSerializer<MomentActionResponseDto> {
  @override
  final Iterable<Type> types = const [MomentActionResponseDto, _$MomentActionResponseDto];

  @override
  final String wireName = r'MomentActionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentActionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'momentId';
    yield serializers.serialize(
      object.momentId,
      specifiedType: const FullType(String),
    );
    yield r'count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(num),
    );
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MomentActionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentActionResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'momentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.momentId = valueDes;
          break;
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.count = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.active = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MomentActionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentActionResponseDtoBuilder();
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
