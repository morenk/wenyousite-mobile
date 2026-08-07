//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/joined_thread_reference_response_dto.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'joined_thread_member_response_dto.g.dart';

/// JoinedThreadMemberResponseDto
///
/// Properties:
/// * [id]
/// * [threadId]
/// * [userId]
/// * [role]
/// * [playerMarked]
/// * [joinedAt]
/// * [user]
/// * [thread]
@BuiltValue()
abstract class JoinedThreadMemberResponseDto implements Built<JoinedThreadMemberResponseDto, JoinedThreadMemberResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'role')
  JoinedThreadMemberResponseDtoRoleEnum get role;
  // enum roleEnum {  OWNER,  COLLABORATOR,  PARTICIPANT,  };

  @BuiltValueField(wireName: r'playerMarked')
  bool get playerMarked;

  @BuiltValueField(wireName: r'joinedAt')
  DateTime get joinedAt;

  @BuiltValueField(wireName: r'user')
  PostAuthorResponseDto get user;

  @BuiltValueField(wireName: r'thread')
  JoinedThreadReferenceResponseDto get thread;

  JoinedThreadMemberResponseDto._();

  factory JoinedThreadMemberResponseDto([void updates(JoinedThreadMemberResponseDtoBuilder b)]) = _$JoinedThreadMemberResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(JoinedThreadMemberResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<JoinedThreadMemberResponseDto> get serializer => _$JoinedThreadMemberResponseDtoSerializer();
}

class _$JoinedThreadMemberResponseDtoSerializer implements PrimitiveSerializer<JoinedThreadMemberResponseDto> {
  @override
  final Iterable<Type> types = const [JoinedThreadMemberResponseDto, _$JoinedThreadMemberResponseDto];

  @override
  final String wireName = r'JoinedThreadMemberResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    JoinedThreadMemberResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'threadId';
    yield serializers.serialize(
      object.threadId,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(JoinedThreadMemberResponseDtoRoleEnum),
    );
    yield r'playerMarked';
    yield serializers.serialize(
      object.playerMarked,
      specifiedType: const FullType(bool),
    );
    yield r'joinedAt';
    yield serializers.serialize(
      object.joinedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(PostAuthorResponseDto),
    );
    yield r'thread';
    yield serializers.serialize(
      object.thread,
      specifiedType: const FullType(JoinedThreadReferenceResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    JoinedThreadMemberResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required JoinedThreadMemberResponseDtoBuilder result,
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
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threadId = valueDes;
          break;
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JoinedThreadMemberResponseDtoRoleEnum),
          ) as JoinedThreadMemberResponseDtoRoleEnum;
          result.role = valueDes;
          break;
        case r'playerMarked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.playerMarked = valueDes;
          break;
        case r'joinedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.joinedAt = valueDes;
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAuthorResponseDto),
          ) as PostAuthorResponseDto;
          result.user.replace(valueDes);
          break;
        case r'thread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JoinedThreadReferenceResponseDto),
          ) as JoinedThreadReferenceResponseDto;
          result.thread.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  JoinedThreadMemberResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = JoinedThreadMemberResponseDtoBuilder();
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

class JoinedThreadMemberResponseDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OWNER')
  static const JoinedThreadMemberResponseDtoRoleEnum OWNER = _$joinedThreadMemberResponseDtoRoleEnum_OWNER;
  @BuiltValueEnumConst(wireName: r'COLLABORATOR')
  static const JoinedThreadMemberResponseDtoRoleEnum COLLABORATOR = _$joinedThreadMemberResponseDtoRoleEnum_COLLABORATOR;
  @BuiltValueEnumConst(wireName: r'PARTICIPANT')
  static const JoinedThreadMemberResponseDtoRoleEnum PARTICIPANT = _$joinedThreadMemberResponseDtoRoleEnum_PARTICIPANT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const JoinedThreadMemberResponseDtoRoleEnum unknownDefaultOpenApi = _$joinedThreadMemberResponseDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<JoinedThreadMemberResponseDtoRoleEnum> get serializer => _$joinedThreadMemberResponseDtoRoleEnumSerializer;

  const JoinedThreadMemberResponseDtoRoleEnum._(String name): super(name);

  static BuiltSet<JoinedThreadMemberResponseDtoRoleEnum> get values => _$joinedThreadMemberResponseDtoRoleEnumValues;
  static JoinedThreadMemberResponseDtoRoleEnum valueOf(String name) => _$joinedThreadMemberResponseDtoRoleEnumValueOf(name);
}
