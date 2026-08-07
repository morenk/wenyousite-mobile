//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_follow_record_response_dto.g.dart';

/// UserFollowRecordResponseDto
///
/// Properties:
/// * [id]
/// * [followerId]
/// * [followingId]
/// * [createdAt]
/// * [following]
/// * [follower]
@BuiltValue()
abstract class UserFollowRecordResponseDto implements Built<UserFollowRecordResponseDto, UserFollowRecordResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'followerId')
  String get followerId;

  @BuiltValueField(wireName: r'followingId')
  String get followingId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'following')
  PostAuthorResponseDto? get following;

  @BuiltValueField(wireName: r'follower')
  PostAuthorResponseDto? get follower;

  UserFollowRecordResponseDto._();

  factory UserFollowRecordResponseDto([void updates(UserFollowRecordResponseDtoBuilder b)]) = _$UserFollowRecordResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserFollowRecordResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserFollowRecordResponseDto> get serializer => _$UserFollowRecordResponseDtoSerializer();
}

class _$UserFollowRecordResponseDtoSerializer implements PrimitiveSerializer<UserFollowRecordResponseDto> {
  @override
  final Iterable<Type> types = const [UserFollowRecordResponseDto, _$UserFollowRecordResponseDto];

  @override
  final String wireName = r'UserFollowRecordResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserFollowRecordResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'followerId';
    yield serializers.serialize(
      object.followerId,
      specifiedType: const FullType(String),
    );
    yield r'followingId';
    yield serializers.serialize(
      object.followingId,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.following != null) {
      yield r'following';
      yield serializers.serialize(
        object.following,
        specifiedType: const FullType(PostAuthorResponseDto),
      );
    }
    if (object.follower != null) {
      yield r'follower';
      yield serializers.serialize(
        object.follower,
        specifiedType: const FullType(PostAuthorResponseDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserFollowRecordResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserFollowRecordResponseDtoBuilder result,
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
        case r'followerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.followerId = valueDes;
          break;
        case r'followingId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.followingId = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'following':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAuthorResponseDto),
          ) as PostAuthorResponseDto;
          result.following.replace(valueDes);
          break;
        case r'follower':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAuthorResponseDto),
          ) as PostAuthorResponseDto;
          result.follower.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserFollowRecordResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserFollowRecordResponseDtoBuilder();
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
