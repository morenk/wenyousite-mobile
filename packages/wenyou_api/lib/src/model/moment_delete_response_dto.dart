//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_delete_response_dto.g.dart';

/// MomentDeleteResponseDto
///
/// Properties:
/// * [message]
@BuiltValue()
abstract class MomentDeleteResponseDto implements Built<MomentDeleteResponseDto, MomentDeleteResponseDtoBuilder> {
  @BuiltValueField(wireName: r'message')
  String get message;

  MomentDeleteResponseDto._();

  factory MomentDeleteResponseDto([void updates(MomentDeleteResponseDtoBuilder b)]) = _$MomentDeleteResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentDeleteResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentDeleteResponseDto> get serializer => _$MomentDeleteResponseDtoSerializer();
}

class _$MomentDeleteResponseDtoSerializer implements PrimitiveSerializer<MomentDeleteResponseDto> {
  @override
  final Iterable<Type> types = const [MomentDeleteResponseDto, _$MomentDeleteResponseDto];

  @override
  final String wireName = r'MomentDeleteResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentDeleteResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MomentDeleteResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentDeleteResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MomentDeleteResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentDeleteResponseDtoBuilder();
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
