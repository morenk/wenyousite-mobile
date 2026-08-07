//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_member_response_dto.g.dart';

/// ThreadMemberResponseDto
///
/// Properties:
/// * [id]
/// * [threadId]
/// * [userId]
/// * [role]
/// * [playerMarked]
/// * [joinedAt]
/// * [user]
@BuiltValue()
abstract class ThreadMemberResponseDto implements Built<ThreadMemberResponseDto, ThreadMemberResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'role')
  ThreadMemberResponseDtoRoleEnum get role;
  // enum roleEnum {  OWNER,  COLLABORATOR,  PARTICIPANT,  };

  @BuiltValueField(wireName: r'playerMarked')
  bool get playerMarked;

  @BuiltValueField(wireName: r'joinedAt')
  DateTime get joinedAt;

  @BuiltValueField(wireName: r'user')
  PostAuthorResponseDto get user;

  ThreadMemberResponseDto._();

  factory ThreadMemberResponseDto([void updates(ThreadMemberResponseDtoBuilder b)]) = _$ThreadMemberResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadMemberResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadMemberResponseDto> get serializer => _$ThreadMemberResponseDtoSerializer();
}

class _$ThreadMemberResponseDtoSerializer implements PrimitiveSerializer<ThreadMemberResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadMemberResponseDto, _$ThreadMemberResponseDto];

  @override
  final String wireName = r'ThreadMemberResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadMemberResponseDto object, {
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
      specifiedType: const FullType(ThreadMemberResponseDtoRoleEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadMemberResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadMemberResponseDtoBuilder result,
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
            specifiedType: const FullType(ThreadMemberResponseDtoRoleEnum),
          ) as ThreadMemberResponseDtoRoleEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadMemberResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadMemberResponseDtoBuilder();
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

class ThreadMemberResponseDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OWNER')
  static const ThreadMemberResponseDtoRoleEnum OWNER = _$threadMemberResponseDtoRoleEnum_OWNER;
  @BuiltValueEnumConst(wireName: r'COLLABORATOR')
  static const ThreadMemberResponseDtoRoleEnum COLLABORATOR = _$threadMemberResponseDtoRoleEnum_COLLABORATOR;
  @BuiltValueEnumConst(wireName: r'PARTICIPANT')
  static const ThreadMemberResponseDtoRoleEnum PARTICIPANT = _$threadMemberResponseDtoRoleEnum_PARTICIPANT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ThreadMemberResponseDtoRoleEnum unknownDefaultOpenApi = _$threadMemberResponseDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<ThreadMemberResponseDtoRoleEnum> get serializer => _$threadMemberResponseDtoRoleEnumSerializer;

  const ThreadMemberResponseDtoRoleEnum._(String name): super(name);

  static BuiltSet<ThreadMemberResponseDtoRoleEnum> get values => _$threadMemberResponseDtoRoleEnumValues;
  static ThreadMemberResponseDtoRoleEnum valueOf(String name) => _$threadMemberResponseDtoRoleEnumValueOf(name);
}
