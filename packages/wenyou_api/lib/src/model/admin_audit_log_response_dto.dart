//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_audit_actor_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_audit_log_response_dto.g.dart';

/// AdminAuditLogResponseDto
///
/// Properties:
/// * [id]
/// * [action]
/// * [targetType]
/// * [targetId]
/// * [reportId]
/// * [reason]
/// * [metadata]
/// * [actor]
/// * [createdAt]
@BuiltValue()
abstract class AdminAuditLogResponseDto implements Built<AdminAuditLogResponseDto, AdminAuditLogResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'action')
  AdminAuditLogResponseDtoActionEnum get action;
  // enum actionEnum {  SUPER_ADMIN_BOOTSTRAPPED,  ADMIN_ROLE_GRANTED,  ADMIN_ROLE_REVOKED,  USER_SUSPENDED,  USER_BANNED,  USER_SANCTION_REVOKED,  CONTENT_HIDDEN,  CONTENT_RESTORED,  REPORT_RESOLVED,  REPORT_DISMISSED,  SYSTEM_NOTIFICATION_SENT,  THREAD_CATEGORY_CREATED,  THREAD_CATEGORY_UPDATED,  TAG_CREATED,  TAG_UPDATED,  ADMIN_INVITED,  ADMIN_INVITE_ACCEPTED,  ADMIN_INVITE_CANCELED,  SUPER_ADMIN_TRANSFERRED,  ADMIN_SESSION_REVOKED,  CASE_RESOLVED,  CASE_DISMISSED,  APPEAL_SUBMITTED,  APPEAL_UPHELD,  APPEAL_OVERTURNED,  USER_SESSIONS_REVOKED,  PASSWORD_RESET_REQUESTED_BY_ADMIN,  NOTIFICATION_CAMPAIGN_SCHEDULED,  NOTIFICATION_CAMPAIGN_CANCELED,  THREAD_CATEGORY_MERGED,  TAG_MERGED,  SITE_SETTINGS_UPDATED,  };

  @BuiltValueField(wireName: r'targetType')
  AdminAuditLogResponseDtoTargetTypeEnum get targetType;
  // enum targetTypeEnum {  USER,  THREAD,  POST,  MOMENT,  MOMENT_COMMENT,  REPORT,  SYSTEM_NOTIFICATION,  THREAD_CATEGORY,  TAG,  MODERATION_CASE,  MODERATION_DECISION,  MODERATION_APPEAL,  ADMIN_INVITE,  ADMIN_SESSION,  NOTIFICATION_CAMPAIGN,  SITE_SETTINGS,  };

  @BuiltValueField(wireName: r'targetId')
  String? get targetId;

  @BuiltValueField(wireName: r'reportId')
  String? get reportId;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'metadata')
  BuiltMap<String, JsonObject?>? get metadata;

  @BuiltValueField(wireName: r'actor')
  AdminAuditActorResponseDto? get actor;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  AdminAuditLogResponseDto._();

  factory AdminAuditLogResponseDto([void updates(AdminAuditLogResponseDtoBuilder b)]) = _$AdminAuditLogResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAuditLogResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAuditLogResponseDto> get serializer => _$AdminAuditLogResponseDtoSerializer();
}

class _$AdminAuditLogResponseDtoSerializer implements PrimitiveSerializer<AdminAuditLogResponseDto> {
  @override
  final Iterable<Type> types = const [AdminAuditLogResponseDto, _$AdminAuditLogResponseDto];

  @override
  final String wireName = r'AdminAuditLogResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAuditLogResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(AdminAuditLogResponseDtoActionEnum),
    );
    yield r'targetType';
    yield serializers.serialize(
      object.targetType,
      specifiedType: const FullType(AdminAuditLogResponseDtoTargetTypeEnum),
    );
    yield r'targetId';
    yield object.targetId == null ? null : serializers.serialize(
      object.targetId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'reportId';
    yield object.reportId == null ? null : serializers.serialize(
      object.reportId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'reason';
    yield object.reason == null ? null : serializers.serialize(
      object.reason,
      specifiedType: const FullType.nullable(String),
    );
    yield r'metadata';
    yield object.metadata == null ? null : serializers.serialize(
      object.metadata,
      specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'actor';
    yield object.actor == null ? null : serializers.serialize(
      object.actor,
      specifiedType: const FullType.nullable(AdminAuditActorResponseDto),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminAuditLogResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAuditLogResponseDtoBuilder result,
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
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminAuditLogResponseDtoActionEnum),
          ) as AdminAuditLogResponseDtoActionEnum;
          result.action = valueDes;
          break;
        case r'targetType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminAuditLogResponseDtoTargetTypeEnum),
          ) as AdminAuditLogResponseDtoTargetTypeEnum;
          result.targetType = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetId = valueDes;
          break;
        case r'reportId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reportId = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.metadata.replace(valueDes);
          break;
        case r'actor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AdminAuditActorResponseDto),
          ) as AdminAuditActorResponseDto?;
          if (valueDes == null) continue;
          result.actor.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminAuditLogResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAuditLogResponseDtoBuilder();
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

class AdminAuditLogResponseDtoActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN_BOOTSTRAPPED')
  static const AdminAuditLogResponseDtoActionEnum SUPER_ADMIN_BOOTSTRAPPED = _$adminAuditLogResponseDtoActionEnum_SUPER_ADMIN_BOOTSTRAPPED;
  @BuiltValueEnumConst(wireName: r'ADMIN_ROLE_GRANTED')
  static const AdminAuditLogResponseDtoActionEnum ADMIN_ROLE_GRANTED = _$adminAuditLogResponseDtoActionEnum_ADMIN_ROLE_GRANTED;
  @BuiltValueEnumConst(wireName: r'ADMIN_ROLE_REVOKED')
  static const AdminAuditLogResponseDtoActionEnum ADMIN_ROLE_REVOKED = _$adminAuditLogResponseDtoActionEnum_ADMIN_ROLE_REVOKED;
  @BuiltValueEnumConst(wireName: r'USER_SUSPENDED')
  static const AdminAuditLogResponseDtoActionEnum USER_SUSPENDED = _$adminAuditLogResponseDtoActionEnum_USER_SUSPENDED;
  @BuiltValueEnumConst(wireName: r'USER_BANNED')
  static const AdminAuditLogResponseDtoActionEnum USER_BANNED = _$adminAuditLogResponseDtoActionEnum_USER_BANNED;
  @BuiltValueEnumConst(wireName: r'USER_SANCTION_REVOKED')
  static const AdminAuditLogResponseDtoActionEnum USER_SANCTION_REVOKED = _$adminAuditLogResponseDtoActionEnum_USER_SANCTION_REVOKED;
  @BuiltValueEnumConst(wireName: r'CONTENT_HIDDEN')
  static const AdminAuditLogResponseDtoActionEnum CONTENT_HIDDEN = _$adminAuditLogResponseDtoActionEnum_CONTENT_HIDDEN;
  @BuiltValueEnumConst(wireName: r'CONTENT_RESTORED')
  static const AdminAuditLogResponseDtoActionEnum CONTENT_RESTORED = _$adminAuditLogResponseDtoActionEnum_CONTENT_RESTORED;
  @BuiltValueEnumConst(wireName: r'REPORT_RESOLVED')
  static const AdminAuditLogResponseDtoActionEnum REPORT_RESOLVED = _$adminAuditLogResponseDtoActionEnum_REPORT_RESOLVED;
  @BuiltValueEnumConst(wireName: r'REPORT_DISMISSED')
  static const AdminAuditLogResponseDtoActionEnum REPORT_DISMISSED = _$adminAuditLogResponseDtoActionEnum_REPORT_DISMISSED;
  @BuiltValueEnumConst(wireName: r'SYSTEM_NOTIFICATION_SENT')
  static const AdminAuditLogResponseDtoActionEnum SYSTEM_NOTIFICATION_SENT = _$adminAuditLogResponseDtoActionEnum_SYSTEM_NOTIFICATION_SENT;
  @BuiltValueEnumConst(wireName: r'THREAD_CATEGORY_CREATED')
  static const AdminAuditLogResponseDtoActionEnum THREAD_CATEGORY_CREATED = _$adminAuditLogResponseDtoActionEnum_THREAD_CATEGORY_CREATED;
  @BuiltValueEnumConst(wireName: r'THREAD_CATEGORY_UPDATED')
  static const AdminAuditLogResponseDtoActionEnum THREAD_CATEGORY_UPDATED = _$adminAuditLogResponseDtoActionEnum_THREAD_CATEGORY_UPDATED;
  @BuiltValueEnumConst(wireName: r'TAG_CREATED')
  static const AdminAuditLogResponseDtoActionEnum TAG_CREATED = _$adminAuditLogResponseDtoActionEnum_TAG_CREATED;
  @BuiltValueEnumConst(wireName: r'TAG_UPDATED')
  static const AdminAuditLogResponseDtoActionEnum TAG_UPDATED = _$adminAuditLogResponseDtoActionEnum_TAG_UPDATED;
  @BuiltValueEnumConst(wireName: r'ADMIN_INVITED')
  static const AdminAuditLogResponseDtoActionEnum ADMIN_INVITED = _$adminAuditLogResponseDtoActionEnum_ADMIN_INVITED;
  @BuiltValueEnumConst(wireName: r'ADMIN_INVITE_ACCEPTED')
  static const AdminAuditLogResponseDtoActionEnum ADMIN_INVITE_ACCEPTED = _$adminAuditLogResponseDtoActionEnum_ADMIN_INVITE_ACCEPTED;
  @BuiltValueEnumConst(wireName: r'ADMIN_INVITE_CANCELED')
  static const AdminAuditLogResponseDtoActionEnum ADMIN_INVITE_CANCELED = _$adminAuditLogResponseDtoActionEnum_ADMIN_INVITE_CANCELED;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN_TRANSFERRED')
  static const AdminAuditLogResponseDtoActionEnum SUPER_ADMIN_TRANSFERRED = _$adminAuditLogResponseDtoActionEnum_SUPER_ADMIN_TRANSFERRED;
  @BuiltValueEnumConst(wireName: r'ADMIN_SESSION_REVOKED')
  static const AdminAuditLogResponseDtoActionEnum ADMIN_SESSION_REVOKED = _$adminAuditLogResponseDtoActionEnum_ADMIN_SESSION_REVOKED;
  @BuiltValueEnumConst(wireName: r'CASE_RESOLVED')
  static const AdminAuditLogResponseDtoActionEnum CASE_RESOLVED = _$adminAuditLogResponseDtoActionEnum_CASE_RESOLVED;
  @BuiltValueEnumConst(wireName: r'CASE_DISMISSED')
  static const AdminAuditLogResponseDtoActionEnum CASE_DISMISSED = _$adminAuditLogResponseDtoActionEnum_CASE_DISMISSED;
  @BuiltValueEnumConst(wireName: r'APPEAL_SUBMITTED')
  static const AdminAuditLogResponseDtoActionEnum APPEAL_SUBMITTED = _$adminAuditLogResponseDtoActionEnum_APPEAL_SUBMITTED;
  @BuiltValueEnumConst(wireName: r'APPEAL_UPHELD')
  static const AdminAuditLogResponseDtoActionEnum APPEAL_UPHELD = _$adminAuditLogResponseDtoActionEnum_APPEAL_UPHELD;
  @BuiltValueEnumConst(wireName: r'APPEAL_OVERTURNED')
  static const AdminAuditLogResponseDtoActionEnum APPEAL_OVERTURNED = _$adminAuditLogResponseDtoActionEnum_APPEAL_OVERTURNED;
  @BuiltValueEnumConst(wireName: r'USER_SESSIONS_REVOKED')
  static const AdminAuditLogResponseDtoActionEnum USER_SESSIONS_REVOKED = _$adminAuditLogResponseDtoActionEnum_USER_SESSIONS_REVOKED;
  @BuiltValueEnumConst(wireName: r'PASSWORD_RESET_REQUESTED_BY_ADMIN')
  static const AdminAuditLogResponseDtoActionEnum PASSWORD_RESET_REQUESTED_BY_ADMIN = _$adminAuditLogResponseDtoActionEnum_PASSWORD_RESET_REQUESTED_BY_ADMIN;
  @BuiltValueEnumConst(wireName: r'NOTIFICATION_CAMPAIGN_SCHEDULED')
  static const AdminAuditLogResponseDtoActionEnum NOTIFICATION_CAMPAIGN_SCHEDULED = _$adminAuditLogResponseDtoActionEnum_NOTIFICATION_CAMPAIGN_SCHEDULED;
  @BuiltValueEnumConst(wireName: r'NOTIFICATION_CAMPAIGN_CANCELED')
  static const AdminAuditLogResponseDtoActionEnum NOTIFICATION_CAMPAIGN_CANCELED = _$adminAuditLogResponseDtoActionEnum_NOTIFICATION_CAMPAIGN_CANCELED;
  @BuiltValueEnumConst(wireName: r'THREAD_CATEGORY_MERGED')
  static const AdminAuditLogResponseDtoActionEnum THREAD_CATEGORY_MERGED = _$adminAuditLogResponseDtoActionEnum_THREAD_CATEGORY_MERGED;
  @BuiltValueEnumConst(wireName: r'TAG_MERGED')
  static const AdminAuditLogResponseDtoActionEnum TAG_MERGED = _$adminAuditLogResponseDtoActionEnum_TAG_MERGED;
  @BuiltValueEnumConst(wireName: r'SITE_SETTINGS_UPDATED')
  static const AdminAuditLogResponseDtoActionEnum SITE_SETTINGS_UPDATED = _$adminAuditLogResponseDtoActionEnum_SITE_SETTINGS_UPDATED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminAuditLogResponseDtoActionEnum unknownDefaultOpenApi = _$adminAuditLogResponseDtoActionEnum_unknownDefaultOpenApi;

  static Serializer<AdminAuditLogResponseDtoActionEnum> get serializer => _$adminAuditLogResponseDtoActionEnumSerializer;

  const AdminAuditLogResponseDtoActionEnum._(String name): super(name);

  static BuiltSet<AdminAuditLogResponseDtoActionEnum> get values => _$adminAuditLogResponseDtoActionEnumValues;
  static AdminAuditLogResponseDtoActionEnum valueOf(String name) => _$adminAuditLogResponseDtoActionEnumValueOf(name);
}

class AdminAuditLogResponseDtoTargetTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const AdminAuditLogResponseDtoTargetTypeEnum USER = _$adminAuditLogResponseDtoTargetTypeEnum_USER;
  @BuiltValueEnumConst(wireName: r'THREAD')
  static const AdminAuditLogResponseDtoTargetTypeEnum THREAD = _$adminAuditLogResponseDtoTargetTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'POST')
  static const AdminAuditLogResponseDtoTargetTypeEnum POST = _$adminAuditLogResponseDtoTargetTypeEnum_POST;
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const AdminAuditLogResponseDtoTargetTypeEnum MOMENT = _$adminAuditLogResponseDtoTargetTypeEnum_MOMENT;
  @BuiltValueEnumConst(wireName: r'MOMENT_COMMENT')
  static const AdminAuditLogResponseDtoTargetTypeEnum MOMENT_COMMENT = _$adminAuditLogResponseDtoTargetTypeEnum_MOMENT_COMMENT;
  @BuiltValueEnumConst(wireName: r'REPORT')
  static const AdminAuditLogResponseDtoTargetTypeEnum REPORT = _$adminAuditLogResponseDtoTargetTypeEnum_REPORT;
  @BuiltValueEnumConst(wireName: r'SYSTEM_NOTIFICATION')
  static const AdminAuditLogResponseDtoTargetTypeEnum SYSTEM_NOTIFICATION = _$adminAuditLogResponseDtoTargetTypeEnum_SYSTEM_NOTIFICATION;
  @BuiltValueEnumConst(wireName: r'THREAD_CATEGORY')
  static const AdminAuditLogResponseDtoTargetTypeEnum THREAD_CATEGORY = _$adminAuditLogResponseDtoTargetTypeEnum_THREAD_CATEGORY;
  @BuiltValueEnumConst(wireName: r'TAG')
  static const AdminAuditLogResponseDtoTargetTypeEnum TAG = _$adminAuditLogResponseDtoTargetTypeEnum_TAG;
  @BuiltValueEnumConst(wireName: r'MODERATION_CASE')
  static const AdminAuditLogResponseDtoTargetTypeEnum MODERATION_CASE = _$adminAuditLogResponseDtoTargetTypeEnum_MODERATION_CASE;
  @BuiltValueEnumConst(wireName: r'MODERATION_DECISION')
  static const AdminAuditLogResponseDtoTargetTypeEnum MODERATION_DECISION = _$adminAuditLogResponseDtoTargetTypeEnum_MODERATION_DECISION;
  @BuiltValueEnumConst(wireName: r'MODERATION_APPEAL')
  static const AdminAuditLogResponseDtoTargetTypeEnum MODERATION_APPEAL = _$adminAuditLogResponseDtoTargetTypeEnum_MODERATION_APPEAL;
  @BuiltValueEnumConst(wireName: r'ADMIN_INVITE')
  static const AdminAuditLogResponseDtoTargetTypeEnum ADMIN_INVITE = _$adminAuditLogResponseDtoTargetTypeEnum_ADMIN_INVITE;
  @BuiltValueEnumConst(wireName: r'ADMIN_SESSION')
  static const AdminAuditLogResponseDtoTargetTypeEnum ADMIN_SESSION = _$adminAuditLogResponseDtoTargetTypeEnum_ADMIN_SESSION;
  @BuiltValueEnumConst(wireName: r'NOTIFICATION_CAMPAIGN')
  static const AdminAuditLogResponseDtoTargetTypeEnum NOTIFICATION_CAMPAIGN = _$adminAuditLogResponseDtoTargetTypeEnum_NOTIFICATION_CAMPAIGN;
  @BuiltValueEnumConst(wireName: r'SITE_SETTINGS')
  static const AdminAuditLogResponseDtoTargetTypeEnum SITE_SETTINGS = _$adminAuditLogResponseDtoTargetTypeEnum_SITE_SETTINGS;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminAuditLogResponseDtoTargetTypeEnum unknownDefaultOpenApi = _$adminAuditLogResponseDtoTargetTypeEnum_unknownDefaultOpenApi;

  static Serializer<AdminAuditLogResponseDtoTargetTypeEnum> get serializer => _$adminAuditLogResponseDtoTargetTypeEnumSerializer;

  const AdminAuditLogResponseDtoTargetTypeEnum._(String name): super(name);

  static BuiltSet<AdminAuditLogResponseDtoTargetTypeEnum> get values => _$adminAuditLogResponseDtoTargetTypeEnumValues;
  static AdminAuditLogResponseDtoTargetTypeEnum valueOf(String name) => _$adminAuditLogResponseDtoTargetTypeEnumValueOf(name);
}
