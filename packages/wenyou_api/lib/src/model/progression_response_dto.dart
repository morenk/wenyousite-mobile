//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'progression_response_dto.g.dart';

/// ProgressionResponseDto
///
/// Properties:
/// * [level]
/// * [experience]
/// * [currentLevelExperience]
/// * [nextLevelExperience]
@BuiltValue()
abstract class ProgressionResponseDto implements Built<ProgressionResponseDto, ProgressionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'level')
  num get level;

  @BuiltValueField(wireName: r'experience')
  num get experience;

  @BuiltValueField(wireName: r'currentLevelExperience')
  num get currentLevelExperience;

  @BuiltValueField(wireName: r'nextLevelExperience')
  num? get nextLevelExperience;

  ProgressionResponseDto._();

  factory ProgressionResponseDto([void updates(ProgressionResponseDtoBuilder b)]) = _$ProgressionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProgressionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProgressionResponseDto> get serializer => _$ProgressionResponseDtoSerializer();
}

class _$ProgressionResponseDtoSerializer implements PrimitiveSerializer<ProgressionResponseDto> {
  @override
  final Iterable<Type> types = const [ProgressionResponseDto, _$ProgressionResponseDto];

  @override
  final String wireName = r'ProgressionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProgressionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType: const FullType(num),
    );
    yield r'experience';
    yield serializers.serialize(
      object.experience,
      specifiedType: const FullType(num),
    );
    yield r'currentLevelExperience';
    yield serializers.serialize(
      object.currentLevelExperience,
      specifiedType: const FullType(num),
    );
    yield r'nextLevelExperience';
    yield object.nextLevelExperience == null ? null : serializers.serialize(
      object.nextLevelExperience,
      specifiedType: const FullType.nullable(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProgressionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProgressionResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.level = valueDes;
          break;
        case r'experience':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.experience = valueDes;
          break;
        case r'currentLevelExperience':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.currentLevelExperience = valueDes;
          break;
        case r'nextLevelExperience':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.nextLevelExperience = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProgressionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProgressionResponseDtoBuilder();
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
