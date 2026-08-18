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

part 'own_bookmark_thread_response_dto.g.dart';

/// OwnBookmarkThreadResponseDto
///
/// Properties:
/// * [id]
/// * [title]
/// * [category] - 动态分类 slug
/// * [status]
/// * [visibility]
/// * [published]
/// * [pinned]
/// * [tipTotal] - 用户投入的累计打赏升数
/// * [createdAt]
/// * [updatedAt]
/// * [deletedAt]
/// * [owner]
/// * [defaultSubthread]
/// * [topicTags]
/// * [count]
/// * [preview] - 默认主贴正文的纯文本预览
/// * [coverImages] - 默认主贴正文中的第一张普通图片 URL；无图时返回空数组
/// * [bookmarkId] - 收藏记录 ID
/// * [bookmarkFolderId] - 所属收藏夹 ID
@BuiltValue()
abstract class OwnBookmarkThreadResponseDto implements Built<OwnBookmarkThreadResponseDto, OwnBookmarkThreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  /// 动态分类 slug
  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'status')
  OwnBookmarkThreadResponseDtoStatusEnum get status;
  // enum statusEnum {  RECRUITING,  CLOSED,  FINISHED,  };

  @BuiltValueField(wireName: r'visibility')
  OwnBookmarkThreadResponseDtoVisibilityEnum get visibility;
  // enum visibilityEnum {  PUBLIC,  PRIVATE,  };

  @BuiltValueField(wireName: r'published')
  bool get published;

  @BuiltValueField(wireName: r'pinned')
  bool get pinned;

  /// 用户投入的累计打赏升数
  @BuiltValueField(wireName: r'tipTotal')
  String get tipTotal;

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

  /// 默认主贴正文的纯文本预览
  @BuiltValueField(wireName: r'preview')
  String get preview;

  /// 默认主贴正文中的第一张普通图片 URL；无图时返回空数组
  @BuiltValueField(wireName: r'coverImages')
  BuiltList<String> get coverImages;

  /// 收藏记录 ID
  @BuiltValueField(wireName: r'bookmarkId')
  String get bookmarkId;

  /// 所属收藏夹 ID
  @BuiltValueField(wireName: r'bookmarkFolderId')
  String get bookmarkFolderId;

  OwnBookmarkThreadResponseDto._();

  factory OwnBookmarkThreadResponseDto([void updates(OwnBookmarkThreadResponseDtoBuilder b)]) = _$OwnBookmarkThreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnBookmarkThreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnBookmarkThreadResponseDto> get serializer => _$OwnBookmarkThreadResponseDtoSerializer();
}

class _$OwnBookmarkThreadResponseDtoSerializer implements PrimitiveSerializer<OwnBookmarkThreadResponseDto> {
  @override
  final Iterable<Type> types = const [OwnBookmarkThreadResponseDto, _$OwnBookmarkThreadResponseDto];

  @override
  final String wireName = r'OwnBookmarkThreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnBookmarkThreadResponseDto object, {
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
    yield object.category == null ? null : serializers.serialize(
      object.category,
      specifiedType: const FullType.nullable(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(OwnBookmarkThreadResponseDtoStatusEnum),
    );
    yield r'visibility';
    yield serializers.serialize(
      object.visibility,
      specifiedType: const FullType(OwnBookmarkThreadResponseDtoVisibilityEnum),
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
    yield r'tipTotal';
    yield serializers.serialize(
      object.tipTotal,
      specifiedType: const FullType(String),
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
    yield r'preview';
    yield serializers.serialize(
      object.preview,
      specifiedType: const FullType(String),
    );
    yield r'coverImages';
    yield serializers.serialize(
      object.coverImages,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'bookmarkId';
    yield serializers.serialize(
      object.bookmarkId,
      specifiedType: const FullType(String),
    );
    yield r'bookmarkFolderId';
    yield serializers.serialize(
      object.bookmarkFolderId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnBookmarkThreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OwnBookmarkThreadResponseDtoBuilder result,
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.category = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OwnBookmarkThreadResponseDtoStatusEnum),
          ) as OwnBookmarkThreadResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OwnBookmarkThreadResponseDtoVisibilityEnum),
          ) as OwnBookmarkThreadResponseDtoVisibilityEnum;
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
        case r'tipTotal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tipTotal = valueDes;
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
        case r'coverImages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.coverImages.replace(valueDes);
          break;
        case r'bookmarkId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bookmarkId = valueDes;
          break;
        case r'bookmarkFolderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bookmarkFolderId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnBookmarkThreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnBookmarkThreadResponseDtoBuilder();
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

class OwnBookmarkThreadResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'RECRUITING')
  static const OwnBookmarkThreadResponseDtoStatusEnum RECRUITING = _$ownBookmarkThreadResponseDtoStatusEnum_RECRUITING;
  @BuiltValueEnumConst(wireName: r'CLOSED')
  static const OwnBookmarkThreadResponseDtoStatusEnum CLOSED = _$ownBookmarkThreadResponseDtoStatusEnum_CLOSED;
  @BuiltValueEnumConst(wireName: r'FINISHED')
  static const OwnBookmarkThreadResponseDtoStatusEnum FINISHED = _$ownBookmarkThreadResponseDtoStatusEnum_FINISHED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const OwnBookmarkThreadResponseDtoStatusEnum unknownDefaultOpenApi = _$ownBookmarkThreadResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<OwnBookmarkThreadResponseDtoStatusEnum> get serializer => _$ownBookmarkThreadResponseDtoStatusEnumSerializer;

  const OwnBookmarkThreadResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<OwnBookmarkThreadResponseDtoStatusEnum> get values => _$ownBookmarkThreadResponseDtoStatusEnumValues;
  static OwnBookmarkThreadResponseDtoStatusEnum valueOf(String name) => _$ownBookmarkThreadResponseDtoStatusEnumValueOf(name);
}

class OwnBookmarkThreadResponseDtoVisibilityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PUBLIC')
  static const OwnBookmarkThreadResponseDtoVisibilityEnum PUBLIC = _$ownBookmarkThreadResponseDtoVisibilityEnum_PUBLIC;
  @BuiltValueEnumConst(wireName: r'PRIVATE')
  static const OwnBookmarkThreadResponseDtoVisibilityEnum PRIVATE = _$ownBookmarkThreadResponseDtoVisibilityEnum_PRIVATE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const OwnBookmarkThreadResponseDtoVisibilityEnum unknownDefaultOpenApi = _$ownBookmarkThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi;

  static Serializer<OwnBookmarkThreadResponseDtoVisibilityEnum> get serializer => _$ownBookmarkThreadResponseDtoVisibilityEnumSerializer;

  const OwnBookmarkThreadResponseDtoVisibilityEnum._(String name): super(name);

  static BuiltSet<OwnBookmarkThreadResponseDtoVisibilityEnum> get values => _$ownBookmarkThreadResponseDtoVisibilityEnumValues;
  static OwnBookmarkThreadResponseDtoVisibilityEnum valueOf(String name) => _$ownBookmarkThreadResponseDtoVisibilityEnumValueOf(name);
}
