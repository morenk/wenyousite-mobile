//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'discussion_window_target_dto.g.dart';

/// DiscussionWindowTargetDto
///
/// Properties:
/// * [id]
/// * [number]
@BuiltValue()
abstract class DiscussionWindowTargetDto implements Built<DiscussionWindowTargetDto, DiscussionWindowTargetDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'number')
  num get number;

  DiscussionWindowTargetDto._();

  factory DiscussionWindowTargetDto([void updates(DiscussionWindowTargetDtoBuilder b)]) = _$DiscussionWindowTargetDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DiscussionWindowTargetDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DiscussionWindowTargetDto> get serializer => _$DiscussionWindowTargetDtoSerializer();
}

class _$DiscussionWindowTargetDtoSerializer implements PrimitiveSerializer<DiscussionWindowTargetDto> {
  @override
  final Iterable<Type> types = const [DiscussionWindowTargetDto, _$DiscussionWindowTargetDto];

  @override
  final String wireName = r'DiscussionWindowTargetDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DiscussionWindowTargetDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'number';
    yield serializers.serialize(
      object.number,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DiscussionWindowTargetDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DiscussionWindowTargetDtoBuilder result,
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
        case r'number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.number = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DiscussionWindowTargetDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DiscussionWindowTargetDtoBuilder();
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
