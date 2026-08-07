//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_user_dto.g.dart';

/// UpdateUserDto
///
/// Properties:
/// * [username] - 用户名（字母、数字、中文，修改后 7 天内不可再次修改）
/// * [bio] - 个人简介
/// * [showRecentReplies] - 隐私设置：允许他人在我的主页查看最近回复
/// * [showPlayerBadges] - 隐私设置：允许他人在我的主页查看玩家标记
/// * [showBookmarks] - 隐私设置：允许他人在我的主页查看收藏/订阅
@BuiltValue()
abstract class UpdateUserDto implements Built<UpdateUserDto, UpdateUserDtoBuilder> {
  /// 用户名（字母、数字、中文，修改后 7 天内不可再次修改）
  @BuiltValueField(wireName: r'username')
  String? get username;

  /// 个人简介
  @BuiltValueField(wireName: r'bio')
  String? get bio;

  /// 隐私设置：允许他人在我的主页查看最近回复
  @BuiltValueField(wireName: r'showRecentReplies')
  bool? get showRecentReplies;

  /// 隐私设置：允许他人在我的主页查看玩家标记
  @BuiltValueField(wireName: r'showPlayerBadges')
  bool? get showPlayerBadges;

  /// 隐私设置：允许他人在我的主页查看收藏/订阅
  @BuiltValueField(wireName: r'showBookmarks')
  bool? get showBookmarks;

  UpdateUserDto._();

  factory UpdateUserDto([void updates(UpdateUserDtoBuilder b)]) = _$UpdateUserDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateUserDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateUserDto> get serializer => _$UpdateUserDtoSerializer();
}

class _$UpdateUserDtoSerializer implements PrimitiveSerializer<UpdateUserDto> {
  @override
  final Iterable<Type> types = const [UpdateUserDto, _$UpdateUserDto];

  @override
  final String wireName = r'UpdateUserDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.username != null) {
      yield r'username';
      yield serializers.serialize(
        object.username,
        specifiedType: const FullType(String),
      );
    }
    if (object.bio != null) {
      yield r'bio';
      yield serializers.serialize(
        object.bio,
        specifiedType: const FullType(String),
      );
    }
    if (object.showRecentReplies != null) {
      yield r'showRecentReplies';
      yield serializers.serialize(
        object.showRecentReplies,
        specifiedType: const FullType(bool),
      );
    }
    if (object.showPlayerBadges != null) {
      yield r'showPlayerBadges';
      yield serializers.serialize(
        object.showPlayerBadges,
        specifiedType: const FullType(bool),
      );
    }
    if (object.showBookmarks != null) {
      yield r'showBookmarks';
      yield serializers.serialize(
        object.showBookmarks,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateUserDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'bio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bio = valueDes;
          break;
        case r'showRecentReplies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.showRecentReplies = valueDes;
          break;
        case r'showPlayerBadges':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.showPlayerBadges = valueDes;
          break;
        case r'showBookmarks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.showBookmarks = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateUserDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateUserDtoBuilder();
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
