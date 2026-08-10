//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_challenge_response_dto.g.dart';

/// AdminChallengeResponseDto
///
/// Properties:
/// * [challengeId]
/// * [expiresIn]
@BuiltValue()
abstract class AdminChallengeResponseDto implements Built<AdminChallengeResponseDto, AdminChallengeResponseDtoBuilder> {
  @BuiltValueField(wireName: r'challengeId')
  String get challengeId;

  @BuiltValueField(wireName: r'expiresIn')
  num get expiresIn;

  AdminChallengeResponseDto._();

  factory AdminChallengeResponseDto([void updates(AdminChallengeResponseDtoBuilder b)]) = _$AdminChallengeResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminChallengeResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminChallengeResponseDto> get serializer => _$AdminChallengeResponseDtoSerializer();
}

class _$AdminChallengeResponseDtoSerializer implements PrimitiveSerializer<AdminChallengeResponseDto> {
  @override
  final Iterable<Type> types = const [AdminChallengeResponseDto, _$AdminChallengeResponseDto];

  @override
  final String wireName = r'AdminChallengeResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminChallengeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'challengeId';
    yield serializers.serialize(
      object.challengeId,
      specifiedType: const FullType(String),
    );
    yield r'expiresIn';
    yield serializers.serialize(
      object.expiresIn,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminChallengeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminChallengeResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'challengeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.challengeId = valueDes;
          break;
        case r'expiresIn':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.expiresIn = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminChallengeResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminChallengeResponseDtoBuilder();
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
