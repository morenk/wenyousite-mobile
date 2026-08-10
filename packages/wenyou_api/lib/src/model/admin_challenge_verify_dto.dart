//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_challenge_verify_dto.g.dart';

/// AdminChallengeVerifyDto
///
/// Properties:
/// * [challengeId]
/// * [code]
@BuiltValue()
abstract class AdminChallengeVerifyDto implements Built<AdminChallengeVerifyDto, AdminChallengeVerifyDtoBuilder> {
  @BuiltValueField(wireName: r'challengeId')
  String get challengeId;

  @BuiltValueField(wireName: r'code')
  String get code;

  AdminChallengeVerifyDto._();

  factory AdminChallengeVerifyDto([void updates(AdminChallengeVerifyDtoBuilder b)]) = _$AdminChallengeVerifyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminChallengeVerifyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminChallengeVerifyDto> get serializer => _$AdminChallengeVerifyDtoSerializer();
}

class _$AdminChallengeVerifyDtoSerializer implements PrimitiveSerializer<AdminChallengeVerifyDto> {
  @override
  final Iterable<Type> types = const [AdminChallengeVerifyDto, _$AdminChallengeVerifyDto];

  @override
  final String wireName = r'AdminChallengeVerifyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminChallengeVerifyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'challengeId';
    yield serializers.serialize(
      object.challengeId,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminChallengeVerifyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminChallengeVerifyDtoBuilder result,
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
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminChallengeVerifyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminChallengeVerifyDtoBuilder();
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
