//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'discussion_author_response_dto.g.dart';

/// DiscussionAuthorResponseDto
///
/// Properties:
/// * [id]
/// * [username]
/// * [avatar]
/// * [level]
/// * [role]
/// * [playerMarked] - 是否为当前主题帖已标记玩家
@BuiltValue()
abstract class DiscussionAuthorResponseDto implements Built<DiscussionAuthorResponseDto, DiscussionAuthorResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  @BuiltValueField(wireName: r'level')
  num get level;

  @BuiltValueField(wireName: r'role')
  DiscussionAuthorResponseDtoRoleEnum get role;
  // enum roleEnum {  OWNER,  COLLABORATOR,  PARTICIPANT,  };

  /// 是否为当前主题帖已标记玩家
  @BuiltValueField(wireName: r'playerMarked')
  bool get playerMarked;

  DiscussionAuthorResponseDto._();

  factory DiscussionAuthorResponseDto([void updates(DiscussionAuthorResponseDtoBuilder b)]) = _$DiscussionAuthorResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DiscussionAuthorResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DiscussionAuthorResponseDto> get serializer => _$DiscussionAuthorResponseDtoSerializer();
}

class _$DiscussionAuthorResponseDtoSerializer implements PrimitiveSerializer<DiscussionAuthorResponseDto> {
  @override
  final Iterable<Type> types = const [DiscussionAuthorResponseDto, _$DiscussionAuthorResponseDto];

  @override
  final String wireName = r'DiscussionAuthorResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DiscussionAuthorResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'avatar';
    yield object.avatar == null ? null : serializers.serialize(
      object.avatar,
      specifiedType: const FullType.nullable(String),
    );
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType: const FullType(num),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(DiscussionAuthorResponseDtoRoleEnum),
    );
    yield r'playerMarked';
    yield serializers.serialize(
      object.playerMarked,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DiscussionAuthorResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DiscussionAuthorResponseDtoBuilder result,
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
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatar = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.level = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DiscussionAuthorResponseDtoRoleEnum),
          ) as DiscussionAuthorResponseDtoRoleEnum;
          result.role = valueDes;
          break;
        case r'playerMarked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.playerMarked = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DiscussionAuthorResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DiscussionAuthorResponseDtoBuilder();
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

class DiscussionAuthorResponseDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OWNER')
  static const DiscussionAuthorResponseDtoRoleEnum OWNER = _$discussionAuthorResponseDtoRoleEnum_OWNER;
  @BuiltValueEnumConst(wireName: r'COLLABORATOR')
  static const DiscussionAuthorResponseDtoRoleEnum COLLABORATOR = _$discussionAuthorResponseDtoRoleEnum_COLLABORATOR;
  @BuiltValueEnumConst(wireName: r'PARTICIPANT')
  static const DiscussionAuthorResponseDtoRoleEnum PARTICIPANT = _$discussionAuthorResponseDtoRoleEnum_PARTICIPANT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DiscussionAuthorResponseDtoRoleEnum unknownDefaultOpenApi = _$discussionAuthorResponseDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<DiscussionAuthorResponseDtoRoleEnum> get serializer => _$discussionAuthorResponseDtoRoleEnumSerializer;

  const DiscussionAuthorResponseDtoRoleEnum._(String name): super(name);

  static BuiltSet<DiscussionAuthorResponseDtoRoleEnum> get values => _$discussionAuthorResponseDtoRoleEnumValues;
  static DiscussionAuthorResponseDtoRoleEnum valueOf(String name) => _$discussionAuthorResponseDtoRoleEnumValueOf(name);
}
