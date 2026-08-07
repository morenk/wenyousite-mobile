//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_members_update_member_request.g.dart';

/// ThreadMembersUpdateMemberRequest
///
/// Properties:
/// * [role]
/// * [playerMarked]
@BuiltValue()
abstract class ThreadMembersUpdateMemberRequest implements Built<ThreadMembersUpdateMemberRequest, ThreadMembersUpdateMemberRequestBuilder> {
  @BuiltValueField(wireName: r'role')
  ThreadMembersUpdateMemberRequestRoleEnum? get role;
  // enum roleEnum {  COLLABORATOR,  PARTICIPANT,  };

  @BuiltValueField(wireName: r'playerMarked')
  bool? get playerMarked;

  ThreadMembersUpdateMemberRequest._();

  factory ThreadMembersUpdateMemberRequest([void updates(ThreadMembersUpdateMemberRequestBuilder b)]) = _$ThreadMembersUpdateMemberRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadMembersUpdateMemberRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadMembersUpdateMemberRequest> get serializer => _$ThreadMembersUpdateMemberRequestSerializer();
}

class _$ThreadMembersUpdateMemberRequestSerializer implements PrimitiveSerializer<ThreadMembersUpdateMemberRequest> {
  @override
  final Iterable<Type> types = const [ThreadMembersUpdateMemberRequest, _$ThreadMembersUpdateMemberRequest];

  @override
  final String wireName = r'ThreadMembersUpdateMemberRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadMembersUpdateMemberRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(ThreadMembersUpdateMemberRequestRoleEnum),
      );
    }
    if (object.playerMarked != null) {
      yield r'playerMarked';
      yield serializers.serialize(
        object.playerMarked,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadMembersUpdateMemberRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadMembersUpdateMemberRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadMembersUpdateMemberRequestRoleEnum),
          ) as ThreadMembersUpdateMemberRequestRoleEnum;
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
  ThreadMembersUpdateMemberRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadMembersUpdateMemberRequestBuilder();
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

class ThreadMembersUpdateMemberRequestRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'COLLABORATOR')
  static const ThreadMembersUpdateMemberRequestRoleEnum COLLABORATOR = _$threadMembersUpdateMemberRequestRoleEnum_COLLABORATOR;
  @BuiltValueEnumConst(wireName: r'PARTICIPANT')
  static const ThreadMembersUpdateMemberRequestRoleEnum PARTICIPANT = _$threadMembersUpdateMemberRequestRoleEnum_PARTICIPANT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ThreadMembersUpdateMemberRequestRoleEnum unknownDefaultOpenApi = _$threadMembersUpdateMemberRequestRoleEnum_unknownDefaultOpenApi;

  static Serializer<ThreadMembersUpdateMemberRequestRoleEnum> get serializer => _$threadMembersUpdateMemberRequestRoleEnumSerializer;

  const ThreadMembersUpdateMemberRequestRoleEnum._(String name): super(name);

  static BuiltSet<ThreadMembersUpdateMemberRequestRoleEnum> get values => _$threadMembersUpdateMemberRequestRoleEnumValues;
  static ThreadMembersUpdateMemberRequestRoleEnum valueOf(String name) => _$threadMembersUpdateMemberRequestRoleEnumValueOf(name);
}
