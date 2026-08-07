//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_subthread_count_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_body_post_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_subthread_response_dto.g.dart';

/// ThreadSubthreadResponseDto
///
/// Properties:
/// * [id]
/// * [threadId]
/// * [title]
/// * [sortOrder]
/// * [postingPolicy]
/// * [version]
/// * [lastPostAt]
/// * [deletedAt]
/// * [createdAt]
/// * [bodyPost]
/// * [count]
@BuiltValue()
abstract class ThreadSubthreadResponseDto implements Built<ThreadSubthreadResponseDto, ThreadSubthreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'sortOrder')
  num get sortOrder;

  @BuiltValueField(wireName: r'postingPolicy')
  ThreadSubthreadResponseDtoPostingPolicyEnum get postingPolicy;
  // enum postingPolicyEnum {  PARTICIPANTS,  COLLABORATORS,  PLAYERS,  };

  @BuiltValueField(wireName: r'version')
  num get version;

  @BuiltValueField(wireName: r'lastPostAt')
  DateTime? get lastPostAt;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'bodyPost')
  ThreadBodyPostResponseDto? get bodyPost;

  @BuiltValueField(wireName: r'_count')
  ThreadSubthreadCountResponseDto get count;

  ThreadSubthreadResponseDto._();

  factory ThreadSubthreadResponseDto([void updates(ThreadSubthreadResponseDtoBuilder b)]) = _$ThreadSubthreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadSubthreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadSubthreadResponseDto> get serializer => _$ThreadSubthreadResponseDtoSerializer();
}

class _$ThreadSubthreadResponseDtoSerializer implements PrimitiveSerializer<ThreadSubthreadResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadSubthreadResponseDto, _$ThreadSubthreadResponseDto];

  @override
  final String wireName = r'ThreadSubthreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadSubthreadResponseDto object, {
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
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'sortOrder';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(num),
    );
    yield r'postingPolicy';
    yield serializers.serialize(
      object.postingPolicy,
      specifiedType: const FullType(ThreadSubthreadResponseDtoPostingPolicyEnum),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
    yield r'lastPostAt';
    yield object.lastPostAt == null ? null : serializers.serialize(
      object.lastPostAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'deletedAt';
    yield object.deletedAt == null ? null : serializers.serialize(
      object.deletedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'bodyPost';
    yield object.bodyPost == null ? null : serializers.serialize(
      object.bodyPost,
      specifiedType: const FullType.nullable(ThreadBodyPostResponseDto),
    );
    yield r'_count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(ThreadSubthreadCountResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadSubthreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadSubthreadResponseDtoBuilder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'sortOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.sortOrder = valueDes;
          break;
        case r'postingPolicy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadSubthreadResponseDtoPostingPolicyEnum),
          ) as ThreadSubthreadResponseDtoPostingPolicyEnum;
          result.postingPolicy = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        case r'lastPostAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastPostAt = valueDes;
          break;
        case r'deletedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'bodyPost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ThreadBodyPostResponseDto),
          ) as ThreadBodyPostResponseDto?;
          if (valueDes == null) continue;
          result.bodyPost.replace(valueDes);
          break;
        case r'_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadSubthreadCountResponseDto),
          ) as ThreadSubthreadCountResponseDto;
          result.count.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadSubthreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadSubthreadResponseDtoBuilder();
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

class ThreadSubthreadResponseDtoPostingPolicyEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PARTICIPANTS')
  static const ThreadSubthreadResponseDtoPostingPolicyEnum PARTICIPANTS = _$threadSubthreadResponseDtoPostingPolicyEnum_PARTICIPANTS;
  @BuiltValueEnumConst(wireName: r'COLLABORATORS')
  static const ThreadSubthreadResponseDtoPostingPolicyEnum COLLABORATORS = _$threadSubthreadResponseDtoPostingPolicyEnum_COLLABORATORS;
  @BuiltValueEnumConst(wireName: r'PLAYERS')
  static const ThreadSubthreadResponseDtoPostingPolicyEnum PLAYERS = _$threadSubthreadResponseDtoPostingPolicyEnum_PLAYERS;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ThreadSubthreadResponseDtoPostingPolicyEnum unknownDefaultOpenApi = _$threadSubthreadResponseDtoPostingPolicyEnum_unknownDefaultOpenApi;

  static Serializer<ThreadSubthreadResponseDtoPostingPolicyEnum> get serializer => _$threadSubthreadResponseDtoPostingPolicyEnumSerializer;

  const ThreadSubthreadResponseDtoPostingPolicyEnum._(String name): super(name);

  static BuiltSet<ThreadSubthreadResponseDtoPostingPolicyEnum> get values => _$threadSubthreadResponseDtoPostingPolicyEnumValues;
  static ThreadSubthreadResponseDtoPostingPolicyEnum valueOf(String name) => _$threadSubthreadResponseDtoPostingPolicyEnumValueOf(name);
}
