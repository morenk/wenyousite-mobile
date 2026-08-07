//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_social_count_response_dto.g.dart';

/// UserSocialCountResponseDto
///
/// Properties:
/// * [following]
/// * [followers]
@BuiltValue()
abstract class UserSocialCountResponseDto implements Built<UserSocialCountResponseDto, UserSocialCountResponseDtoBuilder> {
  @BuiltValueField(wireName: r'following')
  num get following;

  @BuiltValueField(wireName: r'followers')
  num get followers;

  UserSocialCountResponseDto._();

  factory UserSocialCountResponseDto([void updates(UserSocialCountResponseDtoBuilder b)]) = _$UserSocialCountResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserSocialCountResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserSocialCountResponseDto> get serializer => _$UserSocialCountResponseDtoSerializer();
}

class _$UserSocialCountResponseDtoSerializer implements PrimitiveSerializer<UserSocialCountResponseDto> {
  @override
  final Iterable<Type> types = const [UserSocialCountResponseDto, _$UserSocialCountResponseDto];

  @override
  final String wireName = r'UserSocialCountResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserSocialCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'following';
    yield serializers.serialize(
      object.following,
      specifiedType: const FullType(num),
    );
    yield r'followers';
    yield serializers.serialize(
      object.followers,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserSocialCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserSocialCountResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'following':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.following = valueDes;
          break;
        case r'followers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.followers = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserSocialCountResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserSocialCountResponseDtoBuilder();
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
