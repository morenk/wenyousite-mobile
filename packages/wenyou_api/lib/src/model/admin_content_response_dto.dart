//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_hidden_content_user_response_dto.dart';
import 'package:wenyou_api/src/model/admin_content_tag_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_content_response_dto.g.dart';

/// AdminContentResponseDto
///
/// Properties:
/// * [id]
/// * [type]
/// * [title]
/// * [summary]
/// * [author]
/// * [createdAt]
/// * [updatedAt]
/// * [hidden]
/// * [parentHidden]
/// * [canRestore]
/// * [restoreBlockedReason]
/// * [threadId]
/// * [parentPostId]
/// * [momentId]
/// * [parentCommentId]
/// * [category]
/// * [tags]
/// * [version]
@BuiltValue()
abstract class AdminContentResponseDto implements Built<AdminContentResponseDto, AdminContentResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'type')
  AdminContentResponseDtoTypeEnum get type;
  // enum typeEnum {  thread,  post,  moment,  moment_comment,  };

  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'summary')
  String get summary;

  @BuiltValueField(wireName: r'author')
  AdminHiddenContentUserResponseDto get author;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'hidden')
  bool get hidden;

  @BuiltValueField(wireName: r'parentHidden')
  bool get parentHidden;

  @BuiltValueField(wireName: r'canRestore')
  bool get canRestore;

  @BuiltValueField(wireName: r'restoreBlockedReason')
  String? get restoreBlockedReason;

  @BuiltValueField(wireName: r'threadId')
  String? get threadId;

  @BuiltValueField(wireName: r'parentPostId')
  String? get parentPostId;

  @BuiltValueField(wireName: r'momentId')
  String? get momentId;

  @BuiltValueField(wireName: r'parentCommentId')
  String? get parentCommentId;

  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'tags')
  BuiltList<AdminContentTagDto> get tags;

  @BuiltValueField(wireName: r'version')
  num? get version;

  AdminContentResponseDto._();

  factory AdminContentResponseDto([void updates(AdminContentResponseDtoBuilder b)]) = _$AdminContentResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminContentResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminContentResponseDto> get serializer => _$AdminContentResponseDtoSerializer();
}

class _$AdminContentResponseDtoSerializer implements PrimitiveSerializer<AdminContentResponseDto> {
  @override
  final Iterable<Type> types = const [AdminContentResponseDto, _$AdminContentResponseDto];

  @override
  final String wireName = r'AdminContentResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminContentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(AdminContentResponseDtoTypeEnum),
    );
    yield r'title';
    yield object.title == null ? null : serializers.serialize(
      object.title,
      specifiedType: const FullType.nullable(String),
    );
    yield r'summary';
    yield serializers.serialize(
      object.summary,
      specifiedType: const FullType(String),
    );
    yield r'author';
    yield serializers.serialize(
      object.author,
      specifiedType: const FullType(AdminHiddenContentUserResponseDto),
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
    yield r'hidden';
    yield serializers.serialize(
      object.hidden,
      specifiedType: const FullType(bool),
    );
    yield r'parentHidden';
    yield serializers.serialize(
      object.parentHidden,
      specifiedType: const FullType(bool),
    );
    yield r'canRestore';
    yield serializers.serialize(
      object.canRestore,
      specifiedType: const FullType(bool),
    );
    yield r'restoreBlockedReason';
    yield object.restoreBlockedReason == null ? null : serializers.serialize(
      object.restoreBlockedReason,
      specifiedType: const FullType.nullable(String),
    );
    yield r'threadId';
    yield object.threadId == null ? null : serializers.serialize(
      object.threadId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'parentPostId';
    yield object.parentPostId == null ? null : serializers.serialize(
      object.parentPostId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'momentId';
    yield object.momentId == null ? null : serializers.serialize(
      object.momentId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'parentCommentId';
    yield object.parentCommentId == null ? null : serializers.serialize(
      object.parentCommentId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'category';
    yield object.category == null ? null : serializers.serialize(
      object.category,
      specifiedType: const FullType.nullable(String),
    );
    yield r'tags';
    yield serializers.serialize(
      object.tags,
      specifiedType: const FullType(BuiltList, [FullType(AdminContentTagDto)]),
    );
    yield r'version';
    yield object.version == null ? null : serializers.serialize(
      object.version,
      specifiedType: const FullType.nullable(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminContentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminContentResponseDtoBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminContentResponseDtoTypeEnum),
          ) as AdminContentResponseDtoTypeEnum;
          result.type = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.title = valueDes;
          break;
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.summary = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminHiddenContentUserResponseDto),
          ) as AdminHiddenContentUserResponseDto;
          result.author.replace(valueDes);
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
        case r'hidden':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hidden = valueDes;
          break;
        case r'parentHidden':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.parentHidden = valueDes;
          break;
        case r'canRestore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canRestore = valueDes;
          break;
        case r'restoreBlockedReason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.restoreBlockedReason = valueDes;
          break;
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.threadId = valueDes;
          break;
        case r'parentPostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentPostId = valueDes;
          break;
        case r'momentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.momentId = valueDes;
          break;
        case r'parentCommentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentCommentId = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.category = valueDes;
          break;
        case r'tags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminContentTagDto)]),
          ) as BuiltList<AdminContentTagDto>;
          result.tags.replace(valueDes);
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminContentResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminContentResponseDtoBuilder();
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

class AdminContentResponseDtoTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'thread')
  static const AdminContentResponseDtoTypeEnum thread = _$adminContentResponseDtoTypeEnum_thread;
  @BuiltValueEnumConst(wireName: r'post')
  static const AdminContentResponseDtoTypeEnum post = _$adminContentResponseDtoTypeEnum_post;
  @BuiltValueEnumConst(wireName: r'moment')
  static const AdminContentResponseDtoTypeEnum moment = _$adminContentResponseDtoTypeEnum_moment;
  @BuiltValueEnumConst(wireName: r'moment_comment')
  static const AdminContentResponseDtoTypeEnum momentComment = _$adminContentResponseDtoTypeEnum_momentComment;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminContentResponseDtoTypeEnum unknownDefaultOpenApi = _$adminContentResponseDtoTypeEnum_unknownDefaultOpenApi;

  static Serializer<AdminContentResponseDtoTypeEnum> get serializer => _$adminContentResponseDtoTypeEnumSerializer;

  const AdminContentResponseDtoTypeEnum._(String name): super(name);

  static BuiltSet<AdminContentResponseDtoTypeEnum> get values => _$adminContentResponseDtoTypeEnumValues;
  static AdminContentResponseDtoTypeEnum valueOf(String name) => _$adminContentResponseDtoTypeEnumValueOf(name);
}
