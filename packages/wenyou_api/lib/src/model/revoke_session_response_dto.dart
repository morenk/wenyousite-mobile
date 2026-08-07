//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'revoke_session_response_dto.g.dart';

/// RevokeSessionResponseDto
///
/// Properties:
/// * [message]
@BuiltValue()
abstract class RevokeSessionResponseDto implements Built<RevokeSessionResponseDto, RevokeSessionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'message')
  String get message;

  RevokeSessionResponseDto._();

  factory RevokeSessionResponseDto([void updates(RevokeSessionResponseDtoBuilder b)]) = _$RevokeSessionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RevokeSessionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RevokeSessionResponseDto> get serializer => _$RevokeSessionResponseDtoSerializer();
}

class _$RevokeSessionResponseDtoSerializer implements PrimitiveSerializer<RevokeSessionResponseDto> {
  @override
  final Iterable<Type> types = const [RevokeSessionResponseDto, _$RevokeSessionResponseDto];

  @override
  final String wireName = r'RevokeSessionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RevokeSessionResponseDto object, {
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
    RevokeSessionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RevokeSessionResponseDtoBuilder result,
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
  RevokeSessionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RevokeSessionResponseDtoBuilder();
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
