//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_media_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_card_response_dto.g.dart';

/// MomentCardResponseDto
///
/// Properties:
/// * [id]
/// * [authorId]
/// * [author]
/// * [title]
/// * [contentExcerpt] - 纯文本正文摘要
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
/// * [createdAt]
/// * [updatedAt]
@BuiltValue()
abstract class MomentCardResponseDto implements Built<MomentCardResponseDto, MomentCardResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'authorId')
  String get authorId;

  @BuiltValueField(wireName: r'author')
  PostAuthorResponseDto get author;

  @BuiltValueField(wireName: r'title')
  String get title;

  /// 纯文本正文摘要
  @BuiltValueField(wireName: r'contentExcerpt')
  String get contentExcerpt;

  @BuiltValueField(wireName: r'coverType')
  MomentCardResponseDtoCoverTypeEnum get coverType;
  // enum coverTypeEnum {  IMAGE,  TEXT,  };

  @BuiltValueField(wireName: r'textCoverTheme')
  MomentCardResponseDtoTextCoverThemeEnum get textCoverTheme;
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

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  MomentCardResponseDto._();

  factory MomentCardResponseDto([void updates(MomentCardResponseDtoBuilder b)]) = _$MomentCardResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentCardResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentCardResponseDto> get serializer => _$MomentCardResponseDtoSerializer();
}

class _$MomentCardResponseDtoSerializer implements PrimitiveSerializer<MomentCardResponseDto> {
  @override
  final Iterable<Type> types = const [MomentCardResponseDto, _$MomentCardResponseDto];

  @override
  final String wireName = r'MomentCardResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentCardResponseDto object, {
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
      specifiedType: const FullType(MomentCardResponseDtoCoverTypeEnum),
    );
    yield r'textCoverTheme';
    yield serializers.serialize(
      object.textCoverTheme,
      specifiedType: const FullType(MomentCardResponseDtoTextCoverThemeEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    MomentCardResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentCardResponseDtoBuilder result,
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
            specifiedType: const FullType(MomentCardResponseDtoCoverTypeEnum),
          ) as MomentCardResponseDtoCoverTypeEnum;
          result.coverType = valueDes;
          break;
        case r'textCoverTheme':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentCardResponseDtoTextCoverThemeEnum),
          ) as MomentCardResponseDtoTextCoverThemeEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MomentCardResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentCardResponseDtoBuilder();
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

class MomentCardResponseDtoCoverTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'IMAGE')
  static const MomentCardResponseDtoCoverTypeEnum IMAGE = _$momentCardResponseDtoCoverTypeEnum_IMAGE;
  @BuiltValueEnumConst(wireName: r'TEXT')
  static const MomentCardResponseDtoCoverTypeEnum TEXT = _$momentCardResponseDtoCoverTypeEnum_TEXT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const MomentCardResponseDtoCoverTypeEnum unknownDefaultOpenApi = _$momentCardResponseDtoCoverTypeEnum_unknownDefaultOpenApi;

  static Serializer<MomentCardResponseDtoCoverTypeEnum> get serializer => _$momentCardResponseDtoCoverTypeEnumSerializer;

  const MomentCardResponseDtoCoverTypeEnum._(String name): super(name);

  static BuiltSet<MomentCardResponseDtoCoverTypeEnum> get values => _$momentCardResponseDtoCoverTypeEnumValues;
  static MomentCardResponseDtoCoverTypeEnum valueOf(String name) => _$momentCardResponseDtoCoverTypeEnumValueOf(name);
}

class MomentCardResponseDtoTextCoverThemeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ROSE')
  static const MomentCardResponseDtoTextCoverThemeEnum ROSE = _$momentCardResponseDtoTextCoverThemeEnum_ROSE;
  @BuiltValueEnumConst(wireName: r'LILAC')
  static const MomentCardResponseDtoTextCoverThemeEnum LILAC = _$momentCardResponseDtoTextCoverThemeEnum_LILAC;
  @BuiltValueEnumConst(wireName: r'MINT')
  static const MomentCardResponseDtoTextCoverThemeEnum MINT = _$momentCardResponseDtoTextCoverThemeEnum_MINT;
  @BuiltValueEnumConst(wireName: r'AMBER')
  static const MomentCardResponseDtoTextCoverThemeEnum AMBER = _$momentCardResponseDtoTextCoverThemeEnum_AMBER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const MomentCardResponseDtoTextCoverThemeEnum unknownDefaultOpenApi = _$momentCardResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi;

  static Serializer<MomentCardResponseDtoTextCoverThemeEnum> get serializer => _$momentCardResponseDtoTextCoverThemeEnumSerializer;

  const MomentCardResponseDtoTextCoverThemeEnum._(String name): super(name);

  static BuiltSet<MomentCardResponseDtoTextCoverThemeEnum> get values => _$momentCardResponseDtoTextCoverThemeEnumValues;
  static MomentCardResponseDtoTextCoverThemeEnum valueOf(String name) => _$momentCardResponseDtoTextCoverThemeEnumValueOf(name);
}
