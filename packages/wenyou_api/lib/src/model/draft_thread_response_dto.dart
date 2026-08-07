//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/draft_thread_count_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_tag_relation_response_dto.dart';
import 'package:wenyou_api/src/model/draft_default_subthread_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'draft_thread_response_dto.g.dart';

/// DraftThreadResponseDto
///
/// Properties:
/// * [id]
/// * [title]
/// * [category]
/// * [status]
/// * [visibility]
/// * [published]
/// * [createdAt]
/// * [updatedAt]
/// * [deletedAt]
/// * [defaultSubthreadId]
/// * [defaultSubthread]
/// * [topicTags]
/// * [count]
@BuiltValue()
abstract class DraftThreadResponseDto implements Built<DraftThreadResponseDto, DraftThreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'category')
  DraftThreadResponseDtoCategoryEnum get category;
  // enum categoryEnum {  DEDUCTION,  NATION,  RPG,  };

  @BuiltValueField(wireName: r'status')
  DraftThreadResponseDtoStatusEnum get status;
  // enum statusEnum {  RECRUITING,  CLOSED,  FINISHED,  };

  @BuiltValueField(wireName: r'visibility')
  DraftThreadResponseDtoVisibilityEnum get visibility;
  // enum visibilityEnum {  PUBLIC,  PRIVATE,  };

  @BuiltValueField(wireName: r'published')
  bool get published;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'defaultSubthreadId')
  String? get defaultSubthreadId;

  @BuiltValueField(wireName: r'defaultSubthread')
  DraftDefaultSubthreadResponseDto? get defaultSubthread;

  @BuiltValueField(wireName: r'topicTags')
  BuiltList<ThreadTagRelationResponseDto> get topicTags;

  @BuiltValueField(wireName: r'_count')
  DraftThreadCountResponseDto get count;

  DraftThreadResponseDto._();

  factory DraftThreadResponseDto([void updates(DraftThreadResponseDtoBuilder b)]) = _$DraftThreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DraftThreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DraftThreadResponseDto> get serializer => _$DraftThreadResponseDtoSerializer();
}

class _$DraftThreadResponseDtoSerializer implements PrimitiveSerializer<DraftThreadResponseDto> {
  @override
  final Iterable<Type> types = const [DraftThreadResponseDto, _$DraftThreadResponseDto];

  @override
  final String wireName = r'DraftThreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DraftThreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(DraftThreadResponseDtoCategoryEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DraftThreadResponseDtoStatusEnum),
    );
    yield r'visibility';
    yield serializers.serialize(
      object.visibility,
      specifiedType: const FullType(DraftThreadResponseDtoVisibilityEnum),
    );
    yield r'published';
    yield serializers.serialize(
      object.published,
      specifiedType: const FullType(bool),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'deletedAt';
    yield object.deletedAt == null ? null : serializers.serialize(
      object.deletedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'defaultSubthreadId';
    yield object.defaultSubthreadId == null ? null : serializers.serialize(
      object.defaultSubthreadId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'defaultSubthread';
    yield object.defaultSubthread == null ? null : serializers.serialize(
      object.defaultSubthread,
      specifiedType: const FullType.nullable(DraftDefaultSubthreadResponseDto),
    );
    yield r'topicTags';
    yield serializers.serialize(
      object.topicTags,
      specifiedType: const FullType(BuiltList, [FullType(ThreadTagRelationResponseDto)]),
    );
    yield r'_count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(DraftThreadCountResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DraftThreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DraftThreadResponseDtoBuilder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DraftThreadResponseDtoCategoryEnum),
          ) as DraftThreadResponseDtoCategoryEnum;
          result.category = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DraftThreadResponseDtoStatusEnum),
          ) as DraftThreadResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DraftThreadResponseDtoVisibilityEnum),
          ) as DraftThreadResponseDtoVisibilityEnum;
          result.visibility = valueDes;
          break;
        case r'published':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.published = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'deletedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        case r'defaultSubthreadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.defaultSubthreadId = valueDes;
          break;
        case r'defaultSubthread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DraftDefaultSubthreadResponseDto),
          ) as DraftDefaultSubthreadResponseDto?;
          if (valueDes == null) continue;
          result.defaultSubthread.replace(valueDes);
          break;
        case r'topicTags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ThreadTagRelationResponseDto)]),
          ) as BuiltList<ThreadTagRelationResponseDto>;
          result.topicTags.replace(valueDes);
          break;
        case r'_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DraftThreadCountResponseDto),
          ) as DraftThreadCountResponseDto;
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
  DraftThreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DraftThreadResponseDtoBuilder();
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

class DraftThreadResponseDtoCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'DEDUCTION')
  static const DraftThreadResponseDtoCategoryEnum DEDUCTION = _$draftThreadResponseDtoCategoryEnum_DEDUCTION;
  @BuiltValueEnumConst(wireName: r'NATION')
  static const DraftThreadResponseDtoCategoryEnum NATION = _$draftThreadResponseDtoCategoryEnum_NATION;
  @BuiltValueEnumConst(wireName: r'RPG')
  static const DraftThreadResponseDtoCategoryEnum RPG = _$draftThreadResponseDtoCategoryEnum_RPG;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DraftThreadResponseDtoCategoryEnum unknownDefaultOpenApi = _$draftThreadResponseDtoCategoryEnum_unknownDefaultOpenApi;

  static Serializer<DraftThreadResponseDtoCategoryEnum> get serializer => _$draftThreadResponseDtoCategoryEnumSerializer;

  const DraftThreadResponseDtoCategoryEnum._(String name): super(name);

  static BuiltSet<DraftThreadResponseDtoCategoryEnum> get values => _$draftThreadResponseDtoCategoryEnumValues;
  static DraftThreadResponseDtoCategoryEnum valueOf(String name) => _$draftThreadResponseDtoCategoryEnumValueOf(name);
}

class DraftThreadResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'RECRUITING')
  static const DraftThreadResponseDtoStatusEnum RECRUITING = _$draftThreadResponseDtoStatusEnum_RECRUITING;
  @BuiltValueEnumConst(wireName: r'CLOSED')
  static const DraftThreadResponseDtoStatusEnum CLOSED = _$draftThreadResponseDtoStatusEnum_CLOSED;
  @BuiltValueEnumConst(wireName: r'FINISHED')
  static const DraftThreadResponseDtoStatusEnum FINISHED = _$draftThreadResponseDtoStatusEnum_FINISHED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DraftThreadResponseDtoStatusEnum unknownDefaultOpenApi = _$draftThreadResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<DraftThreadResponseDtoStatusEnum> get serializer => _$draftThreadResponseDtoStatusEnumSerializer;

  const DraftThreadResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<DraftThreadResponseDtoStatusEnum> get values => _$draftThreadResponseDtoStatusEnumValues;
  static DraftThreadResponseDtoStatusEnum valueOf(String name) => _$draftThreadResponseDtoStatusEnumValueOf(name);
}

class DraftThreadResponseDtoVisibilityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PUBLIC')
  static const DraftThreadResponseDtoVisibilityEnum PUBLIC = _$draftThreadResponseDtoVisibilityEnum_PUBLIC;
  @BuiltValueEnumConst(wireName: r'PRIVATE')
  static const DraftThreadResponseDtoVisibilityEnum PRIVATE = _$draftThreadResponseDtoVisibilityEnum_PRIVATE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DraftThreadResponseDtoVisibilityEnum unknownDefaultOpenApi = _$draftThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi;

  static Serializer<DraftThreadResponseDtoVisibilityEnum> get serializer => _$draftThreadResponseDtoVisibilityEnumSerializer;

  const DraftThreadResponseDtoVisibilityEnum._(String name): super(name);

  static BuiltSet<DraftThreadResponseDtoVisibilityEnum> get values => _$draftThreadResponseDtoVisibilityEnumValues;
  static DraftThreadResponseDtoVisibilityEnum valueOf(String name) => _$draftThreadResponseDtoVisibilityEnumValueOf(name);
}
