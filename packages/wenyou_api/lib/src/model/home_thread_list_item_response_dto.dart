//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_list_count_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_tag_relation_response_dto.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:wenyou_api/src/model/thread_list_default_subthread_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'home_thread_list_item_response_dto.g.dart';

/// HomeThreadListItemResponseDto
///
/// Properties:
/// * [id]
/// * [title]
/// * [category]
/// * [status]
/// * [visibility]
/// * [published]
/// * [pinned]
/// * [createdAt]
/// * [updatedAt]
/// * [deletedAt]
/// * [owner]
/// * [defaultSubthread]
/// * [topicTags]
/// * [count]
/// * [preview] - 首页列表正文预览
@BuiltValue()
abstract class HomeThreadListItemResponseDto implements Built<HomeThreadListItemResponseDto, HomeThreadListItemResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'category')
  HomeThreadListItemResponseDtoCategoryEnum get category;
  // enum categoryEnum {  DEDUCTION,  NATION,  RPG,  };

  @BuiltValueField(wireName: r'status')
  HomeThreadListItemResponseDtoStatusEnum get status;
  // enum statusEnum {  RECRUITING,  CLOSED,  FINISHED,  };

  @BuiltValueField(wireName: r'visibility')
  HomeThreadListItemResponseDtoVisibilityEnum get visibility;
  // enum visibilityEnum {  PUBLIC,  PRIVATE,  };

  @BuiltValueField(wireName: r'published')
  bool get published;

  @BuiltValueField(wireName: r'pinned')
  bool get pinned;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'owner')
  PostAuthorResponseDto get owner;

  @BuiltValueField(wireName: r'defaultSubthread')
  ThreadListDefaultSubthreadResponseDto? get defaultSubthread;

  @BuiltValueField(wireName: r'topicTags')
  BuiltList<ThreadTagRelationResponseDto> get topicTags;

  @BuiltValueField(wireName: r'_count')
  ThreadListCountResponseDto get count;

  /// 首页列表正文预览
  @BuiltValueField(wireName: r'preview')
  String? get preview;

  HomeThreadListItemResponseDto._();

  factory HomeThreadListItemResponseDto([void updates(HomeThreadListItemResponseDtoBuilder b)]) = _$HomeThreadListItemResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HomeThreadListItemResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HomeThreadListItemResponseDto> get serializer => _$HomeThreadListItemResponseDtoSerializer();
}

class _$HomeThreadListItemResponseDtoSerializer implements PrimitiveSerializer<HomeThreadListItemResponseDto> {
  @override
  final Iterable<Type> types = const [HomeThreadListItemResponseDto, _$HomeThreadListItemResponseDto];

  @override
  final String wireName = r'HomeThreadListItemResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HomeThreadListItemResponseDto object, {
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
      specifiedType: const FullType(HomeThreadListItemResponseDtoCategoryEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(HomeThreadListItemResponseDtoStatusEnum),
    );
    yield r'visibility';
    yield serializers.serialize(
      object.visibility,
      specifiedType: const FullType(HomeThreadListItemResponseDtoVisibilityEnum),
    );
    yield r'published';
    yield serializers.serialize(
      object.published,
      specifiedType: const FullType(bool),
    );
    yield r'pinned';
    yield serializers.serialize(
      object.pinned,
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
    yield r'owner';
    yield serializers.serialize(
      object.owner,
      specifiedType: const FullType(PostAuthorResponseDto),
    );
    yield r'defaultSubthread';
    yield object.defaultSubthread == null ? null : serializers.serialize(
      object.defaultSubthread,
      specifiedType: const FullType.nullable(ThreadListDefaultSubthreadResponseDto),
    );
    yield r'topicTags';
    yield serializers.serialize(
      object.topicTags,
      specifiedType: const FullType(BuiltList, [FullType(ThreadTagRelationResponseDto)]),
    );
    yield r'_count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(ThreadListCountResponseDto),
    );
    if (object.preview != null) {
      yield r'preview';
      yield serializers.serialize(
        object.preview,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    HomeThreadListItemResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HomeThreadListItemResponseDtoBuilder result,
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
            specifiedType: const FullType(HomeThreadListItemResponseDtoCategoryEnum),
          ) as HomeThreadListItemResponseDtoCategoryEnum;
          result.category = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HomeThreadListItemResponseDtoStatusEnum),
          ) as HomeThreadListItemResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HomeThreadListItemResponseDtoVisibilityEnum),
          ) as HomeThreadListItemResponseDtoVisibilityEnum;
          result.visibility = valueDes;
          break;
        case r'published':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.published = valueDes;
          break;
        case r'pinned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pinned = valueDes;
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
        case r'owner':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAuthorResponseDto),
          ) as PostAuthorResponseDto;
          result.owner.replace(valueDes);
          break;
        case r'defaultSubthread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ThreadListDefaultSubthreadResponseDto),
          ) as ThreadListDefaultSubthreadResponseDto?;
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
            specifiedType: const FullType(ThreadListCountResponseDto),
          ) as ThreadListCountResponseDto;
          result.count.replace(valueDes);
          break;
        case r'preview':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.preview = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HomeThreadListItemResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HomeThreadListItemResponseDtoBuilder();
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

class HomeThreadListItemResponseDtoCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'DEDUCTION')
  static const HomeThreadListItemResponseDtoCategoryEnum DEDUCTION = _$homeThreadListItemResponseDtoCategoryEnum_DEDUCTION;
  @BuiltValueEnumConst(wireName: r'NATION')
  static const HomeThreadListItemResponseDtoCategoryEnum NATION = _$homeThreadListItemResponseDtoCategoryEnum_NATION;
  @BuiltValueEnumConst(wireName: r'RPG')
  static const HomeThreadListItemResponseDtoCategoryEnum RPG = _$homeThreadListItemResponseDtoCategoryEnum_RPG;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const HomeThreadListItemResponseDtoCategoryEnum unknownDefaultOpenApi = _$homeThreadListItemResponseDtoCategoryEnum_unknownDefaultOpenApi;

  static Serializer<HomeThreadListItemResponseDtoCategoryEnum> get serializer => _$homeThreadListItemResponseDtoCategoryEnumSerializer;

  const HomeThreadListItemResponseDtoCategoryEnum._(String name): super(name);

  static BuiltSet<HomeThreadListItemResponseDtoCategoryEnum> get values => _$homeThreadListItemResponseDtoCategoryEnumValues;
  static HomeThreadListItemResponseDtoCategoryEnum valueOf(String name) => _$homeThreadListItemResponseDtoCategoryEnumValueOf(name);
}

class HomeThreadListItemResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'RECRUITING')
  static const HomeThreadListItemResponseDtoStatusEnum RECRUITING = _$homeThreadListItemResponseDtoStatusEnum_RECRUITING;
  @BuiltValueEnumConst(wireName: r'CLOSED')
  static const HomeThreadListItemResponseDtoStatusEnum CLOSED = _$homeThreadListItemResponseDtoStatusEnum_CLOSED;
  @BuiltValueEnumConst(wireName: r'FINISHED')
  static const HomeThreadListItemResponseDtoStatusEnum FINISHED = _$homeThreadListItemResponseDtoStatusEnum_FINISHED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const HomeThreadListItemResponseDtoStatusEnum unknownDefaultOpenApi = _$homeThreadListItemResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<HomeThreadListItemResponseDtoStatusEnum> get serializer => _$homeThreadListItemResponseDtoStatusEnumSerializer;

  const HomeThreadListItemResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<HomeThreadListItemResponseDtoStatusEnum> get values => _$homeThreadListItemResponseDtoStatusEnumValues;
  static HomeThreadListItemResponseDtoStatusEnum valueOf(String name) => _$homeThreadListItemResponseDtoStatusEnumValueOf(name);
}

class HomeThreadListItemResponseDtoVisibilityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PUBLIC')
  static const HomeThreadListItemResponseDtoVisibilityEnum PUBLIC = _$homeThreadListItemResponseDtoVisibilityEnum_PUBLIC;
  @BuiltValueEnumConst(wireName: r'PRIVATE')
  static const HomeThreadListItemResponseDtoVisibilityEnum PRIVATE = _$homeThreadListItemResponseDtoVisibilityEnum_PRIVATE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const HomeThreadListItemResponseDtoVisibilityEnum unknownDefaultOpenApi = _$homeThreadListItemResponseDtoVisibilityEnum_unknownDefaultOpenApi;

  static Serializer<HomeThreadListItemResponseDtoVisibilityEnum> get serializer => _$homeThreadListItemResponseDtoVisibilityEnumSerializer;

  const HomeThreadListItemResponseDtoVisibilityEnum._(String name): super(name);

  static BuiltSet<HomeThreadListItemResponseDtoVisibilityEnum> get values => _$homeThreadListItemResponseDtoVisibilityEnumValues;
  static HomeThreadListItemResponseDtoVisibilityEnum valueOf(String name) => _$homeThreadListItemResponseDtoVisibilityEnumValueOf(name);
}
