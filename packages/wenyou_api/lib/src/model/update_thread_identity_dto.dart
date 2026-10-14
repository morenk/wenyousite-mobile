//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_thread_identity_dto.g.dart';

/// UpdateThreadIdentityDto
///
/// Properties:
/// * [profilePostId] - 本主题内当前可读且可用的楼层、楼中楼或子贴正文 ID，可引用他人发言；省略保留，null 清除；不接受 URL
/// * [clearProfilePost] - 显式解除资料绑定，供省略 null 的客户端使用；不能与非空 profilePostId 同时提供
/// * [clearNickname] - 显式清除昵称，供省略 null 的客户端使用；不能与非空 nickname 同时提供
/// * [clearAvatar] - 显式清除头像；不能与非空 avatarMediaId 同时提供
/// * [nickname] - 允许重名、空格及标点；去除首尾空白，空字符串清除。不允许反斜线、方括号、HTML括号或控制字符
/// * [avatarMediaId] - 本人已完成的 AVATAR 媒体；null 清除，不接受任意 URL
/// * [version] - 已有身份的乐观锁版本；省略兼容首次保存
@BuiltValue()
abstract class UpdateThreadIdentityDto implements Built<UpdateThreadIdentityDto, UpdateThreadIdentityDtoBuilder> {
  /// 本主题内当前可读且可用的楼层、楼中楼或子贴正文 ID，可引用他人发言；省略保留，null 清除；不接受 URL
  @BuiltValueField(wireName: r'profilePostId')
  String? get profilePostId;

  /// 显式解除资料绑定，供省略 null 的客户端使用；不能与非空 profilePostId 同时提供
  @BuiltValueField(wireName: r'clearProfilePost')
  bool? get clearProfilePost;

  /// 显式清除昵称，供省略 null 的客户端使用；不能与非空 nickname 同时提供
  @BuiltValueField(wireName: r'clearNickname')
  bool? get clearNickname;

  /// 显式清除头像；不能与非空 avatarMediaId 同时提供
  @BuiltValueField(wireName: r'clearAvatar')
  bool? get clearAvatar;

  /// 允许重名、空格及标点；去除首尾空白，空字符串清除。不允许反斜线、方括号、HTML括号或控制字符
  @BuiltValueField(wireName: r'nickname')
  String? get nickname;

  /// 本人已完成的 AVATAR 媒体；null 清除，不接受任意 URL
  @BuiltValueField(wireName: r'avatarMediaId')
  String? get avatarMediaId;

  /// 已有身份的乐观锁版本；省略兼容首次保存
  @BuiltValueField(wireName: r'version')
  num? get version;

  UpdateThreadIdentityDto._();

  factory UpdateThreadIdentityDto([void updates(UpdateThreadIdentityDtoBuilder b)]) = _$UpdateThreadIdentityDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateThreadIdentityDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateThreadIdentityDto> get serializer => _$UpdateThreadIdentityDtoSerializer();
}

class _$UpdateThreadIdentityDtoSerializer implements PrimitiveSerializer<UpdateThreadIdentityDto> {
  @override
  final Iterable<Type> types = const [UpdateThreadIdentityDto, _$UpdateThreadIdentityDto];

  @override
  final String wireName = r'UpdateThreadIdentityDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateThreadIdentityDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.profilePostId != null) {
      yield r'profilePostId';
      yield serializers.serialize(
        object.profilePostId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.clearProfilePost != null) {
      yield r'clearProfilePost';
      yield serializers.serialize(
        object.clearProfilePost,
        specifiedType: const FullType(bool),
      );
    }
    if (object.clearNickname != null) {
      yield r'clearNickname';
      yield serializers.serialize(
        object.clearNickname,
        specifiedType: const FullType(bool),
      );
    }
    if (object.clearAvatar != null) {
      yield r'clearAvatar';
      yield serializers.serialize(
        object.clearAvatar,
        specifiedType: const FullType(bool),
      );
    }
    if (object.nickname != null) {
      yield r'nickname';
      yield serializers.serialize(
        object.nickname,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.avatarMediaId != null) {
      yield r'avatarMediaId';
      yield serializers.serialize(
        object.avatarMediaId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.version != null) {
      yield r'version';
      yield serializers.serialize(
        object.version,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateThreadIdentityDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateThreadIdentityDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'profilePostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.profilePostId = valueDes;
          break;
        case r'clearProfilePost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.clearProfilePost = valueDes;
          break;
        case r'clearNickname':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.clearNickname = valueDes;
          break;
        case r'clearAvatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.clearAvatar = valueDes;
          break;
        case r'nickname':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nickname = valueDes;
          break;
        case r'avatarMediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatarMediaId = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateThreadIdentityDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateThreadIdentityDtoBuilder();
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
