//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_capabilities_response_dto.dart';
import 'package:wenyou_api/src/model/thread_tag_relation_response_dto.dart';
import 'package:wenyou_api/src/model/thread_count_response_dto.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:wenyou_api/src/model/current_thread_membership_response_dto.dart';
import 'package:wenyou_api/src/model/thread_subthread_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_detail_response_dto.g.dart';

/// ThreadDetailResponseDto
///
/// Properties:
/// * [id]
/// * [title]
/// * [ownerId]
/// * [category] - 动态分类 slug
/// * [status]
/// * [visibility]
/// * [published]
/// * [publishedAt]
/// * [pinned]
/// * [pinnedAt]
/// * [viewCount]
/// * [version]
/// * [likeCount]
/// * [tipTotal] - 用户投入的累计打赏升数
/// * [defaultSubthreadId]
/// * [createdAt]
/// * [updatedAt]
/// * [deletedAt]
/// * [owner]
/// * [subthreads]
/// * [topicTags] - 平台主题标签关联
/// * [count]
/// * [isBookmarked]
/// * [bookmarkId]
/// * [bookmarkFolderId] - 当前收藏所属收藏夹 ID
/// * [isLiked]
/// * [currentMembership]
/// * [capabilities]
@BuiltValue()
abstract class ThreadDetailResponseDto implements Built<ThreadDetailResponseDto, ThreadDetailResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'ownerId')
  String get ownerId;

  /// 动态分类 slug
  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'status')
  ThreadDetailResponseDtoStatusEnum get status;
  // enum statusEnum {  RECRUITING,  CLOSED,  FINISHED,  };

  @BuiltValueField(wireName: r'visibility')
  ThreadDetailResponseDtoVisibilityEnum get visibility;
  // enum visibilityEnum {  PUBLIC,  PRIVATE,  };

  @BuiltValueField(wireName: r'published')
  bool get published;

  @BuiltValueField(wireName: r'publishedAt')
  DateTime? get publishedAt;

  @BuiltValueField(wireName: r'pinned')
  bool get pinned;

  @BuiltValueField(wireName: r'pinnedAt')
  DateTime? get pinnedAt;

  @BuiltValueField(wireName: r'viewCount')
  num get viewCount;

  @BuiltValueField(wireName: r'version')
  num get version;

  @BuiltValueField(wireName: r'likeCount')
  num get likeCount;

  /// 用户投入的累计打赏升数
  @BuiltValueField(wireName: r'tipTotal')
  String get tipTotal;

  @BuiltValueField(wireName: r'defaultSubthreadId')
  String? get defaultSubthreadId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'owner')
  PostAuthorResponseDto get owner;

  @BuiltValueField(wireName: r'subthreads')
  BuiltList<ThreadSubthreadResponseDto> get subthreads;

  /// 平台主题标签关联
  @BuiltValueField(wireName: r'topicTags')
  BuiltList<ThreadTagRelationResponseDto> get topicTags;

  @BuiltValueField(wireName: r'_count')
  ThreadCountResponseDto get count;

  @BuiltValueField(wireName: r'isBookmarked')
  bool? get isBookmarked;

  @BuiltValueField(wireName: r'bookmarkId')
  String? get bookmarkId;

  /// 当前收藏所属收藏夹 ID
  @BuiltValueField(wireName: r'bookmarkFolderId')
  String? get bookmarkFolderId;

  @BuiltValueField(wireName: r'isLiked')
  bool? get isLiked;

  @BuiltValueField(wireName: r'currentMembership')
  CurrentThreadMembershipResponseDto? get currentMembership;

  @BuiltValueField(wireName: r'capabilities')
  ThreadCapabilitiesResponseDto? get capabilities;

  ThreadDetailResponseDto._();

  factory ThreadDetailResponseDto([void updates(ThreadDetailResponseDtoBuilder b)]) = _$ThreadDetailResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadDetailResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadDetailResponseDto> get serializer => _$ThreadDetailResponseDtoSerializer();
}

class _$ThreadDetailResponseDtoSerializer implements PrimitiveSerializer<ThreadDetailResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadDetailResponseDto, _$ThreadDetailResponseDto];

  @override
  final String wireName = r'ThreadDetailResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadDetailResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield object.title == null ? null : serializers.serialize(
      object.title,
      specifiedType: const FullType.nullable(String),
    );
    yield r'ownerId';
    yield serializers.serialize(
      object.ownerId,
      specifiedType: const FullType(String),
    );
    yield r'category';
    yield object.category == null ? null : serializers.serialize(
      object.category,
      specifiedType: const FullType.nullable(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ThreadDetailResponseDtoStatusEnum),
    );
    yield r'visibility';
    yield serializers.serialize(
      object.visibility,
      specifiedType: const FullType(ThreadDetailResponseDtoVisibilityEnum),
    );
    yield r'published';
    yield serializers.serialize(
      object.published,
      specifiedType: const FullType(bool),
    );
    yield r'publishedAt';
    yield object.publishedAt == null ? null : serializers.serialize(
      object.publishedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'pinned';
    yield serializers.serialize(
      object.pinned,
      specifiedType: const FullType(bool),
    );
    yield r'pinnedAt';
    yield object.pinnedAt == null ? null : serializers.serialize(
      object.pinnedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'viewCount';
    yield serializers.serialize(
      object.viewCount,
      specifiedType: const FullType(num),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
    yield r'likeCount';
    yield serializers.serialize(
      object.likeCount,
      specifiedType: const FullType(num),
    );
    yield r'tipTotal';
    yield serializers.serialize(
      object.tipTotal,
      specifiedType: const FullType(String),
    );
    yield r'defaultSubthreadId';
    yield object.defaultSubthreadId == null ? null : serializers.serialize(
      object.defaultSubthreadId,
      specifiedType: const FullType.nullable(String),
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
    yield r'subthreads';
    yield serializers.serialize(
      object.subthreads,
      specifiedType: const FullType(BuiltList, [FullType(ThreadSubthreadResponseDto)]),
    );
    yield r'topicTags';
    yield serializers.serialize(
      object.topicTags,
      specifiedType: const FullType(BuiltList, [FullType(ThreadTagRelationResponseDto)]),
    );
    yield r'_count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(ThreadCountResponseDto),
    );
    if (object.isBookmarked != null) {
      yield r'isBookmarked';
      yield serializers.serialize(
        object.isBookmarked,
        specifiedType: const FullType(bool),
      );
    }
    if (object.bookmarkId != null) {
      yield r'bookmarkId';
      yield serializers.serialize(
        object.bookmarkId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.bookmarkFolderId != null) {
      yield r'bookmarkFolderId';
      yield serializers.serialize(
        object.bookmarkFolderId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.isLiked != null) {
      yield r'isLiked';
      yield serializers.serialize(
        object.isLiked,
        specifiedType: const FullType(bool),
      );
    }
    if (object.currentMembership != null) {
      yield r'currentMembership';
      yield serializers.serialize(
        object.currentMembership,
        specifiedType: const FullType.nullable(CurrentThreadMembershipResponseDto),
      );
    }
    if (object.capabilities != null) {
      yield r'capabilities';
      yield serializers.serialize(
        object.capabilities,
        specifiedType: const FullType(ThreadCapabilitiesResponseDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadDetailResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadDetailResponseDtoBuilder result,
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.title = valueDes;
          break;
        case r'ownerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ownerId = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.category = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadDetailResponseDtoStatusEnum),
          ) as ThreadDetailResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadDetailResponseDtoVisibilityEnum),
          ) as ThreadDetailResponseDtoVisibilityEnum;
          result.visibility = valueDes;
          break;
        case r'published':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.published = valueDes;
          break;
        case r'publishedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.publishedAt = valueDes;
          break;
        case r'pinned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pinned = valueDes;
          break;
        case r'pinnedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.pinnedAt = valueDes;
          break;
        case r'viewCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.viewCount = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        case r'likeCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.likeCount = valueDes;
          break;
        case r'tipTotal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tipTotal = valueDes;
          break;
        case r'defaultSubthreadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.defaultSubthreadId = valueDes;
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
        case r'subthreads':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ThreadSubthreadResponseDto)]),
          ) as BuiltList<ThreadSubthreadResponseDto>;
          result.subthreads.replace(valueDes);
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
            specifiedType: const FullType(ThreadCountResponseDto),
          ) as ThreadCountResponseDto;
          result.count.replace(valueDes);
          break;
        case r'isBookmarked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isBookmarked = valueDes;
          break;
        case r'bookmarkId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bookmarkId = valueDes;
          break;
        case r'bookmarkFolderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bookmarkFolderId = valueDes;
          break;
        case r'isLiked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isLiked = valueDes;
          break;
        case r'currentMembership':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CurrentThreadMembershipResponseDto),
          ) as CurrentThreadMembershipResponseDto?;
          if (valueDes == null) continue;
          result.currentMembership.replace(valueDes);
          break;
        case r'capabilities':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadCapabilitiesResponseDto),
          ) as ThreadCapabilitiesResponseDto;
          result.capabilities.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadDetailResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadDetailResponseDtoBuilder();
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

class ThreadDetailResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'RECRUITING')
  static const ThreadDetailResponseDtoStatusEnum RECRUITING = _$threadDetailResponseDtoStatusEnum_RECRUITING;
  @BuiltValueEnumConst(wireName: r'CLOSED')
  static const ThreadDetailResponseDtoStatusEnum CLOSED = _$threadDetailResponseDtoStatusEnum_CLOSED;
  @BuiltValueEnumConst(wireName: r'FINISHED')
  static const ThreadDetailResponseDtoStatusEnum FINISHED = _$threadDetailResponseDtoStatusEnum_FINISHED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ThreadDetailResponseDtoStatusEnum unknownDefaultOpenApi = _$threadDetailResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<ThreadDetailResponseDtoStatusEnum> get serializer => _$threadDetailResponseDtoStatusEnumSerializer;

  const ThreadDetailResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<ThreadDetailResponseDtoStatusEnum> get values => _$threadDetailResponseDtoStatusEnumValues;
  static ThreadDetailResponseDtoStatusEnum valueOf(String name) => _$threadDetailResponseDtoStatusEnumValueOf(name);
}

class ThreadDetailResponseDtoVisibilityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PUBLIC')
  static const ThreadDetailResponseDtoVisibilityEnum PUBLIC = _$threadDetailResponseDtoVisibilityEnum_PUBLIC;
  @BuiltValueEnumConst(wireName: r'PRIVATE')
  static const ThreadDetailResponseDtoVisibilityEnum PRIVATE = _$threadDetailResponseDtoVisibilityEnum_PRIVATE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ThreadDetailResponseDtoVisibilityEnum unknownDefaultOpenApi = _$threadDetailResponseDtoVisibilityEnum_unknownDefaultOpenApi;

  static Serializer<ThreadDetailResponseDtoVisibilityEnum> get serializer => _$threadDetailResponseDtoVisibilityEnumSerializer;

  const ThreadDetailResponseDtoVisibilityEnum._(String name): super(name);

  static BuiltSet<ThreadDetailResponseDtoVisibilityEnum> get values => _$threadDetailResponseDtoVisibilityEnumValues;
  static ThreadDetailResponseDtoVisibilityEnum valueOf(String name) => _$threadDetailResponseDtoVisibilityEnumValueOf(name);
}
