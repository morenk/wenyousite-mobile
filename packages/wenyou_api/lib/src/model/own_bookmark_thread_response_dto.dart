//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:wenyou_api/src/model/bookmark_thread_count_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'own_bookmark_thread_response_dto.g.dart';

/// OwnBookmarkThreadResponseDto
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
/// * [count]
/// * [bookmarkId] - 收藏记录 ID
@BuiltValue()
abstract class OwnBookmarkThreadResponseDto implements Built<OwnBookmarkThreadResponseDto, OwnBookmarkThreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'category')
  OwnBookmarkThreadResponseDtoCategoryEnum get category;
  // enum categoryEnum {  DEDUCTION,  NATION,  RPG,  };

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

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'owner')
  PostAuthorResponseDto get owner;

  @BuiltValueField(wireName: r'_count')
  BookmarkThreadCountResponseDto get count;

  /// 收藏记录 ID
  @BuiltValueField(wireName: r'bookmarkId')
  String? get bookmarkId;

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
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(OwnBookmarkThreadResponseDtoCategoryEnum),
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
    yield r'_count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(BookmarkThreadCountResponseDto),
    );
    if (object.bookmarkId != null) {
      yield r'bookmarkId';
      yield serializers.serialize(
        object.bookmarkId,
        specifiedType: const FullType(String),
      );
    }
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
            specifiedType: const FullType(OwnBookmarkThreadResponseDtoCategoryEnum),
          ) as OwnBookmarkThreadResponseDtoCategoryEnum;
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
        case r'_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BookmarkThreadCountResponseDto),
          ) as BookmarkThreadCountResponseDto;
          result.count.replace(valueDes);
          break;
        case r'bookmarkId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bookmarkId = valueDes;
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

class OwnBookmarkThreadResponseDtoCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'DEDUCTION')
  static const OwnBookmarkThreadResponseDtoCategoryEnum DEDUCTION = _$ownBookmarkThreadResponseDtoCategoryEnum_DEDUCTION;
  @BuiltValueEnumConst(wireName: r'NATION')
  static const OwnBookmarkThreadResponseDtoCategoryEnum NATION = _$ownBookmarkThreadResponseDtoCategoryEnum_NATION;
  @BuiltValueEnumConst(wireName: r'RPG')
  static const OwnBookmarkThreadResponseDtoCategoryEnum RPG = _$ownBookmarkThreadResponseDtoCategoryEnum_RPG;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const OwnBookmarkThreadResponseDtoCategoryEnum unknownDefaultOpenApi = _$ownBookmarkThreadResponseDtoCategoryEnum_unknownDefaultOpenApi;

  static Serializer<OwnBookmarkThreadResponseDtoCategoryEnum> get serializer => _$ownBookmarkThreadResponseDtoCategoryEnumSerializer;

  const OwnBookmarkThreadResponseDtoCategoryEnum._(String name): super(name);

  static BuiltSet<OwnBookmarkThreadResponseDtoCategoryEnum> get values => _$ownBookmarkThreadResponseDtoCategoryEnumValues;
  static OwnBookmarkThreadResponseDtoCategoryEnum valueOf(String name) => _$ownBookmarkThreadResponseDtoCategoryEnumValueOf(name);
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
