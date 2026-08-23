//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_media_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'own_moment_bookmark_response_dto.g.dart';

/// OwnMomentBookmarkResponseDto
///
/// Properties:
/// * [id]
/// * [authorId]
/// * [author]
/// * [title]
/// * [contentExcerpt] - 正文纯文本摘要；传送门降级为自定义名称或默认名称“传送门”
/// * [coverType]
/// * [textCoverTheme]
/// * [coverMedia]
/// * [imageCount]
/// * [likeCount]
/// * [commentCount]
/// * [bookmarkCount]
/// * [tipTotal]
/// * [viewerLiked]
/// * [viewerBookmarked]
/// * [canInteract] - 是否允许新增点赞、评论、收藏和加油；字段缺失时客户端按 true 兼容旧服务
/// * [createdAt]
/// * [updatedAt]
/// * [bookmarkFolderId] - 所属私有收藏夹 ID
@BuiltValue()
abstract class OwnMomentBookmarkResponseDto implements Built<OwnMomentBookmarkResponseDto, OwnMomentBookmarkResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'authorId')
  String get authorId;

  @BuiltValueField(wireName: r'author')
  PostAuthorResponseDto get author;

  @BuiltValueField(wireName: r'title')
  String get title;

  /// 正文纯文本摘要；传送门降级为自定义名称或默认名称“传送门”
  @BuiltValueField(wireName: r'contentExcerpt')
  String get contentExcerpt;

  @BuiltValueField(wireName: r'coverType')
  OwnMomentBookmarkResponseDtoCoverTypeEnum get coverType;
  // enum coverTypeEnum {  IMAGE,  TEXT,  };

  @BuiltValueField(wireName: r'textCoverTheme')
  OwnMomentBookmarkResponseDtoTextCoverThemeEnum get textCoverTheme;
  // enum textCoverThemeEnum {  ROSE,  LILAC,  MINT,  AMBER,  };

  @BuiltValueField(wireName: r'coverMedia')
  MomentMediaResponseDto? get coverMedia;

  @BuiltValueField(wireName: r'imageCount')
  num get imageCount;

  @BuiltValueField(wireName: r'likeCount')
  num get likeCount;

  @BuiltValueField(wireName: r'commentCount')
  num get commentCount;

  @BuiltValueField(wireName: r'bookmarkCount')
  num get bookmarkCount;

  @BuiltValueField(wireName: r'tipTotal')
  String get tipTotal;

  @BuiltValueField(wireName: r'viewerLiked')
  bool get viewerLiked;

  @BuiltValueField(wireName: r'viewerBookmarked')
  bool get viewerBookmarked;

  /// 是否允许新增点赞、评论、收藏和加油；字段缺失时客户端按 true 兼容旧服务
  @BuiltValueField(wireName: r'canInteract')
  bool? get canInteract;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  /// 所属私有收藏夹 ID
  @BuiltValueField(wireName: r'bookmarkFolderId')
  String get bookmarkFolderId;

  OwnMomentBookmarkResponseDto._();

  factory OwnMomentBookmarkResponseDto([void updates(OwnMomentBookmarkResponseDtoBuilder b)]) = _$OwnMomentBookmarkResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnMomentBookmarkResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnMomentBookmarkResponseDto> get serializer => _$OwnMomentBookmarkResponseDtoSerializer();
}

class _$OwnMomentBookmarkResponseDtoSerializer implements PrimitiveSerializer<OwnMomentBookmarkResponseDto> {
  @override
  final Iterable<Type> types = const [OwnMomentBookmarkResponseDto, _$OwnMomentBookmarkResponseDto];

  @override
  final String wireName = r'OwnMomentBookmarkResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnMomentBookmarkResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'authorId';
    yield serializers.serialize(
      object.authorId,
      specifiedType: const FullType(String),
    );
    yield r'author';
    yield serializers.serialize(
      object.author,
      specifiedType: const FullType(PostAuthorResponseDto),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'contentExcerpt';
    yield serializers.serialize(
      object.contentExcerpt,
      specifiedType: const FullType(String),
    );
    yield r'coverType';
    yield serializers.serialize(
      object.coverType,
      specifiedType: const FullType(OwnMomentBookmarkResponseDtoCoverTypeEnum),
    );
    yield r'textCoverTheme';
    yield serializers.serialize(
      object.textCoverTheme,
      specifiedType: const FullType(OwnMomentBookmarkResponseDtoTextCoverThemeEnum),
    );
    yield r'coverMedia';
    yield object.coverMedia == null ? null : serializers.serialize(
      object.coverMedia,
      specifiedType: const FullType.nullable(MomentMediaResponseDto),
    );
    yield r'imageCount';
    yield serializers.serialize(
      object.imageCount,
      specifiedType: const FullType(num),
    );
    yield r'likeCount';
    yield serializers.serialize(
      object.likeCount,
      specifiedType: const FullType(num),
    );
    yield r'commentCount';
    yield serializers.serialize(
      object.commentCount,
      specifiedType: const FullType(num),
    );
    yield r'bookmarkCount';
    yield serializers.serialize(
      object.bookmarkCount,
      specifiedType: const FullType(num),
    );
    yield r'tipTotal';
    yield serializers.serialize(
      object.tipTotal,
      specifiedType: const FullType(String),
    );
    yield r'viewerLiked';
    yield serializers.serialize(
      object.viewerLiked,
      specifiedType: const FullType(bool),
    );
    yield r'viewerBookmarked';
    yield serializers.serialize(
      object.viewerBookmarked,
      specifiedType: const FullType(bool),
    );
    if (object.canInteract != null) {
      yield r'canInteract';
      yield serializers.serialize(
        object.canInteract,
        specifiedType: const FullType(bool),
      );
    }
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
    yield r'bookmarkFolderId';
    yield serializers.serialize(
      object.bookmarkFolderId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnMomentBookmarkResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OwnMomentBookmarkResponseDtoBuilder result,
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
        case r'authorId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authorId = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAuthorResponseDto),
          ) as PostAuthorResponseDto;
          result.author.replace(valueDes);
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'contentExcerpt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentExcerpt = valueDes;
          break;
        case r'coverType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OwnMomentBookmarkResponseDtoCoverTypeEnum),
          ) as OwnMomentBookmarkResponseDtoCoverTypeEnum;
          result.coverType = valueDes;
          break;
        case r'textCoverTheme':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OwnMomentBookmarkResponseDtoTextCoverThemeEnum),
          ) as OwnMomentBookmarkResponseDtoTextCoverThemeEnum;
          result.textCoverTheme = valueDes;
          break;
        case r'coverMedia':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MomentMediaResponseDto),
          ) as MomentMediaResponseDto?;
          if (valueDes == null) continue;
          result.coverMedia.replace(valueDes);
          break;
        case r'imageCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.imageCount = valueDes;
          break;
        case r'likeCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.likeCount = valueDes;
          break;
        case r'commentCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.commentCount = valueDes;
          break;
        case r'bookmarkCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.bookmarkCount = valueDes;
          break;
        case r'tipTotal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tipTotal = valueDes;
          break;
        case r'viewerLiked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.viewerLiked = valueDes;
          break;
        case r'viewerBookmarked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.viewerBookmarked = valueDes;
          break;
        case r'canInteract':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canInteract = valueDes;
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
  OwnMomentBookmarkResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnMomentBookmarkResponseDtoBuilder();
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

class OwnMomentBookmarkResponseDtoCoverTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'IMAGE')
  static const OwnMomentBookmarkResponseDtoCoverTypeEnum IMAGE = _$ownMomentBookmarkResponseDtoCoverTypeEnum_IMAGE;
  @BuiltValueEnumConst(wireName: r'TEXT')
  static const OwnMomentBookmarkResponseDtoCoverTypeEnum TEXT = _$ownMomentBookmarkResponseDtoCoverTypeEnum_TEXT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const OwnMomentBookmarkResponseDtoCoverTypeEnum unknownDefaultOpenApi = _$ownMomentBookmarkResponseDtoCoverTypeEnum_unknownDefaultOpenApi;

  static Serializer<OwnMomentBookmarkResponseDtoCoverTypeEnum> get serializer => _$ownMomentBookmarkResponseDtoCoverTypeEnumSerializer;

  const OwnMomentBookmarkResponseDtoCoverTypeEnum._(String name): super(name);

  static BuiltSet<OwnMomentBookmarkResponseDtoCoverTypeEnum> get values => _$ownMomentBookmarkResponseDtoCoverTypeEnumValues;
  static OwnMomentBookmarkResponseDtoCoverTypeEnum valueOf(String name) => _$ownMomentBookmarkResponseDtoCoverTypeEnumValueOf(name);
}

class OwnMomentBookmarkResponseDtoTextCoverThemeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ROSE')
  static const OwnMomentBookmarkResponseDtoTextCoverThemeEnum ROSE = _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_ROSE;
  @BuiltValueEnumConst(wireName: r'LILAC')
  static const OwnMomentBookmarkResponseDtoTextCoverThemeEnum LILAC = _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_LILAC;
  @BuiltValueEnumConst(wireName: r'MINT')
  static const OwnMomentBookmarkResponseDtoTextCoverThemeEnum MINT = _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_MINT;
  @BuiltValueEnumConst(wireName: r'AMBER')
  static const OwnMomentBookmarkResponseDtoTextCoverThemeEnum AMBER = _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_AMBER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const OwnMomentBookmarkResponseDtoTextCoverThemeEnum unknownDefaultOpenApi = _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi;

  static Serializer<OwnMomentBookmarkResponseDtoTextCoverThemeEnum> get serializer => _$ownMomentBookmarkResponseDtoTextCoverThemeEnumSerializer;

  const OwnMomentBookmarkResponseDtoTextCoverThemeEnum._(String name): super(name);

  static BuiltSet<OwnMomentBookmarkResponseDtoTextCoverThemeEnum> get values => _$ownMomentBookmarkResponseDtoTextCoverThemeEnumValues;
  static OwnMomentBookmarkResponseDtoTextCoverThemeEnum valueOf(String name) => _$ownMomentBookmarkResponseDtoTextCoverThemeEnumValueOf(name);
}
