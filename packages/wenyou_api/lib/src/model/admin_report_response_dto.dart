//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/report_user_summary_dto.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_report_response_dto.g.dart';

/// AdminReportResponseDto
///
/// Properties:
/// * [id]
/// * [reporterId]
/// * [targetType]
/// * [targetId]
/// * [reasonCode]
/// * [details]
/// * [targetSnapshot]
/// * [status]
/// * [handledBy]
/// * [handledAt]
/// * [resolutionNote]
/// * [createdAt]
/// * [updatedAt]
/// * [reporter]
/// * [handler]
/// * [targetState]
@BuiltValue()
abstract class AdminReportResponseDto implements Built<AdminReportResponseDto, AdminReportResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'reporterId')
  String? get reporterId;

  @BuiltValueField(wireName: r'targetType')
  AdminReportResponseDtoTargetTypeEnum get targetType;
  // enum targetTypeEnum {  USER,  THREAD,  POST,  MOMENT,  MOMENT_COMMENT,  };

  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  @BuiltValueField(wireName: r'reasonCode')
  AdminReportResponseDtoReasonCodeEnum get reasonCode;
  // enum reasonCodeEnum {  SPAM,  HARASSMENT,  HATE_OR_THREATS,  SEXUAL_CONTENT,  VIOLENT_CONTENT,  PERSONAL_INFORMATION,  ILLEGAL_CONTENT,  OTHER,  };

  @BuiltValueField(wireName: r'details')
  String? get details;

  @BuiltValueField(wireName: r'targetSnapshot')
  BuiltMap<String, JsonObject?>? get targetSnapshot;

  @BuiltValueField(wireName: r'status')
  AdminReportResponseDtoStatusEnum get status;
  // enum statusEnum {  PENDING,  RESOLVED,  DISMISSED,  };

  @BuiltValueField(wireName: r'handledBy')
  String? get handledBy;

  @BuiltValueField(wireName: r'handledAt')
  DateTime? get handledAt;

  @BuiltValueField(wireName: r'resolutionNote')
  String? get resolutionNote;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'reporter')
  ReportUserSummaryDto? get reporter;

  @BuiltValueField(wireName: r'handler')
  ReportUserSummaryDto? get handler;

  @BuiltValueField(wireName: r'targetState')
  BuiltMap<String, JsonObject?>? get targetState;

  AdminReportResponseDto._();

  factory AdminReportResponseDto([void updates(AdminReportResponseDtoBuilder b)]) = _$AdminReportResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminReportResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminReportResponseDto> get serializer => _$AdminReportResponseDtoSerializer();
}

class _$AdminReportResponseDtoSerializer implements PrimitiveSerializer<AdminReportResponseDto> {
  @override
  final Iterable<Type> types = const [AdminReportResponseDto, _$AdminReportResponseDto];

  @override
  final String wireName = r'AdminReportResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminReportResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'reporterId';
    yield object.reporterId == null ? null : serializers.serialize(
      object.reporterId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'targetType';
    yield serializers.serialize(
      object.targetType,
      specifiedType: const FullType(AdminReportResponseDtoTargetTypeEnum),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'reasonCode';
    yield serializers.serialize(
      object.reasonCode,
      specifiedType: const FullType(AdminReportResponseDtoReasonCodeEnum),
    );
    yield r'details';
    yield object.details == null ? null : serializers.serialize(
      object.details,
      specifiedType: const FullType.nullable(String),
    );
    yield r'targetSnapshot';
    yield object.targetSnapshot == null ? null : serializers.serialize(
      object.targetSnapshot,
      specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdminReportResponseDtoStatusEnum),
    );
    yield r'handledBy';
    yield object.handledBy == null ? null : serializers.serialize(
      object.handledBy,
      specifiedType: const FullType.nullable(String),
    );
    yield r'handledAt';
    yield object.handledAt == null ? null : serializers.serialize(
      object.handledAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'resolutionNote';
    yield object.resolutionNote == null ? null : serializers.serialize(
      object.resolutionNote,
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
    yield r'reporter';
    yield object.reporter == null ? null : serializers.serialize(
      object.reporter,
      specifiedType: const FullType.nullable(ReportUserSummaryDto),
    );
    yield r'handler';
    yield object.handler == null ? null : serializers.serialize(
      object.handler,
      specifiedType: const FullType.nullable(ReportUserSummaryDto),
    );
    if (object.targetState != null) {
      yield r'targetState';
      yield serializers.serialize(
        object.targetState,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminReportResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminReportResponseDtoBuilder result,
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
        case r'reporterId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reporterId = valueDes;
          break;
        case r'targetType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminReportResponseDtoTargetTypeEnum),
          ) as AdminReportResponseDtoTargetTypeEnum;
          result.targetType = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetId = valueDes;
          break;
        case r'reasonCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminReportResponseDtoReasonCodeEnum),
          ) as AdminReportResponseDtoReasonCodeEnum;
          result.reasonCode = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.details = valueDes;
          break;
        case r'targetSnapshot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.targetSnapshot.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminReportResponseDtoStatusEnum),
          ) as AdminReportResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'handledBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.handledBy = valueDes;
          break;
        case r'handledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.handledAt = valueDes;
          break;
        case r'resolutionNote':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resolutionNote = valueDes;
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
        case r'reporter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ReportUserSummaryDto),
          ) as ReportUserSummaryDto?;
          if (valueDes == null) continue;
          result.reporter.replace(valueDes);
          break;
        case r'handler':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ReportUserSummaryDto),
          ) as ReportUserSummaryDto?;
          if (valueDes == null) continue;
          result.handler.replace(valueDes);
          break;
        case r'targetState':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.targetState.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminReportResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminReportResponseDtoBuilder();
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

class AdminReportResponseDtoTargetTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const AdminReportResponseDtoTargetTypeEnum USER = _$adminReportResponseDtoTargetTypeEnum_USER;
  @BuiltValueEnumConst(wireName: r'THREAD')
  static const AdminReportResponseDtoTargetTypeEnum THREAD = _$adminReportResponseDtoTargetTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'POST')
  static const AdminReportResponseDtoTargetTypeEnum POST = _$adminReportResponseDtoTargetTypeEnum_POST;
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const AdminReportResponseDtoTargetTypeEnum MOMENT = _$adminReportResponseDtoTargetTypeEnum_MOMENT;
  @BuiltValueEnumConst(wireName: r'MOMENT_COMMENT')
  static const AdminReportResponseDtoTargetTypeEnum MOMENT_COMMENT = _$adminReportResponseDtoTargetTypeEnum_MOMENT_COMMENT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminReportResponseDtoTargetTypeEnum unknownDefaultOpenApi = _$adminReportResponseDtoTargetTypeEnum_unknownDefaultOpenApi;

  static Serializer<AdminReportResponseDtoTargetTypeEnum> get serializer => _$adminReportResponseDtoTargetTypeEnumSerializer;

  const AdminReportResponseDtoTargetTypeEnum._(String name): super(name);

  static BuiltSet<AdminReportResponseDtoTargetTypeEnum> get values => _$adminReportResponseDtoTargetTypeEnumValues;
  static AdminReportResponseDtoTargetTypeEnum valueOf(String name) => _$adminReportResponseDtoTargetTypeEnumValueOf(name);
}

class AdminReportResponseDtoReasonCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SPAM')
  static const AdminReportResponseDtoReasonCodeEnum SPAM = _$adminReportResponseDtoReasonCodeEnum_SPAM;
  @BuiltValueEnumConst(wireName: r'HARASSMENT')
  static const AdminReportResponseDtoReasonCodeEnum HARASSMENT = _$adminReportResponseDtoReasonCodeEnum_HARASSMENT;
  @BuiltValueEnumConst(wireName: r'HATE_OR_THREATS')
  static const AdminReportResponseDtoReasonCodeEnum HATE_OR_THREATS = _$adminReportResponseDtoReasonCodeEnum_HATE_OR_THREATS;
  @BuiltValueEnumConst(wireName: r'SEXUAL_CONTENT')
  static const AdminReportResponseDtoReasonCodeEnum SEXUAL_CONTENT = _$adminReportResponseDtoReasonCodeEnum_SEXUAL_CONTENT;
  @BuiltValueEnumConst(wireName: r'VIOLENT_CONTENT')
  static const AdminReportResponseDtoReasonCodeEnum VIOLENT_CONTENT = _$adminReportResponseDtoReasonCodeEnum_VIOLENT_CONTENT;
  @BuiltValueEnumConst(wireName: r'PERSONAL_INFORMATION')
  static const AdminReportResponseDtoReasonCodeEnum PERSONAL_INFORMATION = _$adminReportResponseDtoReasonCodeEnum_PERSONAL_INFORMATION;
  @BuiltValueEnumConst(wireName: r'ILLEGAL_CONTENT')
  static const AdminReportResponseDtoReasonCodeEnum ILLEGAL_CONTENT = _$adminReportResponseDtoReasonCodeEnum_ILLEGAL_CONTENT;
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const AdminReportResponseDtoReasonCodeEnum OTHER = _$adminReportResponseDtoReasonCodeEnum_OTHER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminReportResponseDtoReasonCodeEnum unknownDefaultOpenApi = _$adminReportResponseDtoReasonCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminReportResponseDtoReasonCodeEnum> get serializer => _$adminReportResponseDtoReasonCodeEnumSerializer;

  const AdminReportResponseDtoReasonCodeEnum._(String name): super(name);

  static BuiltSet<AdminReportResponseDtoReasonCodeEnum> get values => _$adminReportResponseDtoReasonCodeEnumValues;
  static AdminReportResponseDtoReasonCodeEnum valueOf(String name) => _$adminReportResponseDtoReasonCodeEnumValueOf(name);
}

class AdminReportResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PENDING')
  static const AdminReportResponseDtoStatusEnum PENDING = _$adminReportResponseDtoStatusEnum_PENDING;
  @BuiltValueEnumConst(wireName: r'RESOLVED')
  static const AdminReportResponseDtoStatusEnum RESOLVED = _$adminReportResponseDtoStatusEnum_RESOLVED;
  @BuiltValueEnumConst(wireName: r'DISMISSED')
  static const AdminReportResponseDtoStatusEnum DISMISSED = _$adminReportResponseDtoStatusEnum_DISMISSED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminReportResponseDtoStatusEnum unknownDefaultOpenApi = _$adminReportResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<AdminReportResponseDtoStatusEnum> get serializer => _$adminReportResponseDtoStatusEnumSerializer;

  const AdminReportResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<AdminReportResponseDtoStatusEnum> get values => _$adminReportResponseDtoStatusEnumValues;
  static AdminReportResponseDtoStatusEnum valueOf(String name) => _$adminReportResponseDtoStatusEnumValueOf(name);
}
