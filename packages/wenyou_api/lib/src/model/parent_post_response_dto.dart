//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'parent_post_response_dto.g.dart';

/// ParentPostResponseDto
///
/// Properties:
/// * [id]
/// * [floorNumber]
@BuiltValue()
abstract class ParentPostResponseDto implements Built<ParentPostResponseDto, ParentPostResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'floorNumber')
  num? get floorNumber;

  ParentPostResponseDto._();

  factory ParentPostResponseDto([void updates(ParentPostResponseDtoBuilder b)]) = _$ParentPostResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ParentPostResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ParentPostResponseDto> get serializer => _$ParentPostResponseDtoSerializer();
}

class _$ParentPostResponseDtoSerializer implements PrimitiveSerializer<ParentPostResponseDto> {
  @override
  final Iterable<Type> types = const [ParentPostResponseDto, _$ParentPostResponseDto];

  @override
  final String wireName = r'ParentPostResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ParentPostResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'floorNumber';
    yield object.floorNumber == null ? null : serializers.serialize(
      object.floorNumber,
      specifiedType: const FullType.nullable(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ParentPostResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ParentPostResponseDtoBuilder result,
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
        case r'floorNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.floorNumber = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ParentPostResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ParentPostResponseDtoBuilder();
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
