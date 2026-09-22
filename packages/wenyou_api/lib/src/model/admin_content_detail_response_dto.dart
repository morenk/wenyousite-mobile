//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_hidden_content_user_response_dto.dart';
import 'package:wenyou_api/src/model/admin_content_tag_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_audit_log_response_dto.dart';
import 'package:wenyou_api/src/model/admin_content_media_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_content_detail_response_dto.g.dart';

/// AdminContentDetailResponseDto
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
/// * [content]
/// * [mediaIds]
/// * [media]
/// * [auditLogs]
@BuiltValue()
abstract class AdminContentDetailResponseDto implements Built<AdminContentDetailResponseDto, AdminContentDetailResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'type')
  AdminContentDetailResponseDtoTypeEnum get type;
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

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'mediaIds')
  BuiltList<String> get mediaIds;

  @BuiltValueField(wireName: r'media')
  BuiltList<AdminContentMediaDto> get media;

  @BuiltValueField(wireName: r'auditLogs')
  BuiltList<AdminAuditLogResponseDto> get auditLogs;

  AdminContentDetailResponseDto._();

  factory AdminContentDetailResponseDto([void updates(AdminContentDetailResponseDtoBuilder b)]) = _$AdminContentDetailResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminContentDetailResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminContentDetailResponseDto> get serializer => _$AdminContentDetailResponseDtoSerializer();
}

class _$AdminContentDetailResponseDtoSerializer implements PrimitiveSerializer<AdminContentDetailResponseDto> {
  @override
  final Iterable<Type> types = const [AdminContentDetailResponseDto, _$AdminContentDetailResponseDto];

  @override
  final String wireName = r'AdminContentDetailResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminContentDetailResponseDto object, {
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
      specifiedType: const FullType(AdminContentDetailResponseDtoTypeEnum),
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
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'mediaIds';
    yield serializers.serialize(
      object.mediaIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'media';
    yield serializers.serialize(
      object.media,
      specifiedType: const FullType(BuiltList, [FullType(AdminContentMediaDto)]),
    );
    yield r'auditLogs';
    yield serializers.serialize(
      object.auditLogs,
      specifiedType: const FullType(BuiltList, [FullType(AdminAuditLogResponseDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminContentDetailResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminContentDetailResponseDtoBuilder result,
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
            specifiedType: const FullType(AdminContentDetailResponseDtoTypeEnum),
          ) as AdminContentDetailResponseDtoTypeEnum;
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
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'mediaIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.mediaIds.replace(valueDes);
          break;
        case r'media':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminContentMediaDto)]),
          ) as BuiltList<AdminContentMediaDto>;
          result.media.replace(valueDes);
          break;
        case r'auditLogs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminAuditLogResponseDto)]),
          ) as BuiltList<AdminAuditLogResponseDto>;
          result.auditLogs.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminContentDetailResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminContentDetailResponseDtoBuilder();
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

class AdminContentDetailResponseDtoTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'thread')
  static const AdminContentDetailResponseDtoTypeEnum thread = _$adminContentDetailResponseDtoTypeEnum_thread;
  @BuiltValueEnumConst(wireName: r'post')
  static const AdminContentDetailResponseDtoTypeEnum post = _$adminContentDetailResponseDtoTypeEnum_post;
  @BuiltValueEnumConst(wireName: r'moment')
  static const AdminContentDetailResponseDtoTypeEnum moment = _$adminContentDetailResponseDtoTypeEnum_moment;
  @BuiltValueEnumConst(wireName: r'moment_comment')
  static const AdminContentDetailResponseDtoTypeEnum momentComment = _$adminContentDetailResponseDtoTypeEnum_momentComment;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminContentDetailResponseDtoTypeEnum unknownDefaultOpenApi = _$adminContentDetailResponseDtoTypeEnum_unknownDefaultOpenApi;

  static Serializer<AdminContentDetailResponseDtoTypeEnum> get serializer => _$adminContentDetailResponseDtoTypeEnumSerializer;

  const AdminContentDetailResponseDtoTypeEnum._(String name): super(name);

  static BuiltSet<AdminContentDetailResponseDtoTypeEnum> get values => _$adminContentDetailResponseDtoTypeEnumValues;
  static AdminContentDetailResponseDtoTypeEnum valueOf(String name) => _$adminContentDetailResponseDtoTypeEnumValueOf(name);
}
