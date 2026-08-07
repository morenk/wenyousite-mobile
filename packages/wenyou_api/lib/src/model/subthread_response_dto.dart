//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/subthread_thread_reference_response_dto.dart';
import 'package:wenyou_api/src/model/subthread_count_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subthread_response_dto.g.dart';

/// SubthreadResponseDto
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
/// * [count]
/// * [thread]
@BuiltValue()
abstract class SubthreadResponseDto implements Built<SubthreadResponseDto, SubthreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'sortOrder')
  num get sortOrder;

  @BuiltValueField(wireName: r'postingPolicy')
  SubthreadResponseDtoPostingPolicyEnum get postingPolicy;
  // enum postingPolicyEnum {  PARTICIPANTS,  COLLABORATORS,  PLAYERS,  };

  @BuiltValueField(wireName: r'version')
  num get version;

  @BuiltValueField(wireName: r'lastPostAt')
  DateTime? get lastPostAt;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'_count')
  SubthreadCountResponseDto get count;

  @BuiltValueField(wireName: r'thread')
  SubthreadThreadReferenceResponseDto? get thread;

  SubthreadResponseDto._();

  factory SubthreadResponseDto([void updates(SubthreadResponseDtoBuilder b)]) = _$SubthreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubthreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubthreadResponseDto> get serializer => _$SubthreadResponseDtoSerializer();
}

class _$SubthreadResponseDtoSerializer implements PrimitiveSerializer<SubthreadResponseDto> {
  @override
  final Iterable<Type> types = const [SubthreadResponseDto, _$SubthreadResponseDto];

  @override
  final String wireName = r'SubthreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubthreadResponseDto object, {
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
      specifiedType: const FullType(SubthreadResponseDtoPostingPolicyEnum),
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
    yield r'_count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(SubthreadCountResponseDto),
    );
    if (object.thread != null) {
      yield r'thread';
      yield serializers.serialize(
        object.thread,
        specifiedType: const FullType(SubthreadThreadReferenceResponseDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SubthreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubthreadResponseDtoBuilder result,
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
            specifiedType: const FullType(SubthreadResponseDtoPostingPolicyEnum),
          ) as SubthreadResponseDtoPostingPolicyEnum;
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
        case r'_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SubthreadCountResponseDto),
          ) as SubthreadCountResponseDto;
          result.count.replace(valueDes);
          break;
        case r'thread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SubthreadThreadReferenceResponseDto),
          ) as SubthreadThreadReferenceResponseDto;
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
  SubthreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubthreadResponseDtoBuilder();
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

class SubthreadResponseDtoPostingPolicyEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PARTICIPANTS')
  static const SubthreadResponseDtoPostingPolicyEnum PARTICIPANTS = _$subthreadResponseDtoPostingPolicyEnum_PARTICIPANTS;
  @BuiltValueEnumConst(wireName: r'COLLABORATORS')
  static const SubthreadResponseDtoPostingPolicyEnum COLLABORATORS = _$subthreadResponseDtoPostingPolicyEnum_COLLABORATORS;
  @BuiltValueEnumConst(wireName: r'PLAYERS')
  static const SubthreadResponseDtoPostingPolicyEnum PLAYERS = _$subthreadResponseDtoPostingPolicyEnum_PLAYERS;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SubthreadResponseDtoPostingPolicyEnum unknownDefaultOpenApi = _$subthreadResponseDtoPostingPolicyEnum_unknownDefaultOpenApi;

  static Serializer<SubthreadResponseDtoPostingPolicyEnum> get serializer => _$subthreadResponseDtoPostingPolicyEnumSerializer;

  const SubthreadResponseDtoPostingPolicyEnum._(String name): super(name);

  static BuiltSet<SubthreadResponseDtoPostingPolicyEnum> get values => _$subthreadResponseDtoPostingPolicyEnumValues;
  static SubthreadResponseDtoPostingPolicyEnum valueOf(String name) => _$subthreadResponseDtoPostingPolicyEnumValueOf(name);
}
