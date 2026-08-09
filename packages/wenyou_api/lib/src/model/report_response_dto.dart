//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'report_response_dto.g.dart';

/// ReportResponseDto
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
@BuiltValue()
abstract class ReportResponseDto implements Built<ReportResponseDto, ReportResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'reporterId')
  String? get reporterId;

  @BuiltValueField(wireName: r'targetType')
  ReportResponseDtoTargetTypeEnum get targetType;
  // enum targetTypeEnum {  USER,  THREAD,  POST,  MOMENT,  MOMENT_COMMENT,  };

  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  @BuiltValueField(wireName: r'reasonCode')
  ReportResponseDtoReasonCodeEnum get reasonCode;
  // enum reasonCodeEnum {  SPAM,  HARASSMENT,  HATE_OR_THREATS,  SEXUAL_CONTENT,  VIOLENT_CONTENT,  PERSONAL_INFORMATION,  ILLEGAL_CONTENT,  OTHER,  };

  @BuiltValueField(wireName: r'details')
  String? get details;

  @BuiltValueField(wireName: r'targetSnapshot')
  BuiltMap<String, JsonObject?>? get targetSnapshot;

  @BuiltValueField(wireName: r'status')
  ReportResponseDtoStatusEnum get status;
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

  ReportResponseDto._();

  factory ReportResponseDto([void updates(ReportResponseDtoBuilder b)]) = _$ReportResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportResponseDto> get serializer => _$ReportResponseDtoSerializer();
}

class _$ReportResponseDtoSerializer implements PrimitiveSerializer<ReportResponseDto> {
  @override
  final Iterable<Type> types = const [ReportResponseDto, _$ReportResponseDto];

  @override
  final String wireName = r'ReportResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportResponseDto object, {
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
      specifiedType: const FullType(ReportResponseDtoTargetTypeEnum),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'reasonCode';
    yield serializers.serialize(
      object.reasonCode,
      specifiedType: const FullType(ReportResponseDtoReasonCodeEnum),
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
      specifiedType: const FullType(ReportResponseDtoStatusEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ReportResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportResponseDtoBuilder result,
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
            specifiedType: const FullType(ReportResponseDtoTargetTypeEnum),
          ) as ReportResponseDtoTargetTypeEnum;
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
            specifiedType: const FullType(ReportResponseDtoReasonCodeEnum),
          ) as ReportResponseDtoReasonCodeEnum;
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
            specifiedType: const FullType(ReportResponseDtoStatusEnum),
          ) as ReportResponseDtoStatusEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReportResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportResponseDtoBuilder();
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

class ReportResponseDtoTargetTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const ReportResponseDtoTargetTypeEnum USER = _$reportResponseDtoTargetTypeEnum_USER;
  @BuiltValueEnumConst(wireName: r'THREAD')
  static const ReportResponseDtoTargetTypeEnum THREAD = _$reportResponseDtoTargetTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'POST')
  static const ReportResponseDtoTargetTypeEnum POST = _$reportResponseDtoTargetTypeEnum_POST;
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const ReportResponseDtoTargetTypeEnum MOMENT = _$reportResponseDtoTargetTypeEnum_MOMENT;
  @BuiltValueEnumConst(wireName: r'MOMENT_COMMENT')
  static const ReportResponseDtoTargetTypeEnum MOMENT_COMMENT = _$reportResponseDtoTargetTypeEnum_MOMENT_COMMENT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ReportResponseDtoTargetTypeEnum unknownDefaultOpenApi = _$reportResponseDtoTargetTypeEnum_unknownDefaultOpenApi;

  static Serializer<ReportResponseDtoTargetTypeEnum> get serializer => _$reportResponseDtoTargetTypeEnumSerializer;

  const ReportResponseDtoTargetTypeEnum._(String name): super(name);

  static BuiltSet<ReportResponseDtoTargetTypeEnum> get values => _$reportResponseDtoTargetTypeEnumValues;
  static ReportResponseDtoTargetTypeEnum valueOf(String name) => _$reportResponseDtoTargetTypeEnumValueOf(name);
}

class ReportResponseDtoReasonCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SPAM')
  static const ReportResponseDtoReasonCodeEnum SPAM = _$reportResponseDtoReasonCodeEnum_SPAM;
  @BuiltValueEnumConst(wireName: r'HARASSMENT')
  static const ReportResponseDtoReasonCodeEnum HARASSMENT = _$reportResponseDtoReasonCodeEnum_HARASSMENT;
  @BuiltValueEnumConst(wireName: r'HATE_OR_THREATS')
  static const ReportResponseDtoReasonCodeEnum HATE_OR_THREATS = _$reportResponseDtoReasonCodeEnum_HATE_OR_THREATS;
  @BuiltValueEnumConst(wireName: r'SEXUAL_CONTENT')
  static const ReportResponseDtoReasonCodeEnum SEXUAL_CONTENT = _$reportResponseDtoReasonCodeEnum_SEXUAL_CONTENT;
  @BuiltValueEnumConst(wireName: r'VIOLENT_CONTENT')
  static const ReportResponseDtoReasonCodeEnum VIOLENT_CONTENT = _$reportResponseDtoReasonCodeEnum_VIOLENT_CONTENT;
  @BuiltValueEnumConst(wireName: r'PERSONAL_INFORMATION')
  static const ReportResponseDtoReasonCodeEnum PERSONAL_INFORMATION = _$reportResponseDtoReasonCodeEnum_PERSONAL_INFORMATION;
  @BuiltValueEnumConst(wireName: r'ILLEGAL_CONTENT')
  static const ReportResponseDtoReasonCodeEnum ILLEGAL_CONTENT = _$reportResponseDtoReasonCodeEnum_ILLEGAL_CONTENT;
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ReportResponseDtoReasonCodeEnum OTHER = _$reportResponseDtoReasonCodeEnum_OTHER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ReportResponseDtoReasonCodeEnum unknownDefaultOpenApi = _$reportResponseDtoReasonCodeEnum_unknownDefaultOpenApi;

  static Serializer<ReportResponseDtoReasonCodeEnum> get serializer => _$reportResponseDtoReasonCodeEnumSerializer;

  const ReportResponseDtoReasonCodeEnum._(String name): super(name);

  static BuiltSet<ReportResponseDtoReasonCodeEnum> get values => _$reportResponseDtoReasonCodeEnumValues;
  static ReportResponseDtoReasonCodeEnum valueOf(String name) => _$reportResponseDtoReasonCodeEnumValueOf(name);
}

class ReportResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PENDING')
  static const ReportResponseDtoStatusEnum PENDING = _$reportResponseDtoStatusEnum_PENDING;
  @BuiltValueEnumConst(wireName: r'RESOLVED')
  static const ReportResponseDtoStatusEnum RESOLVED = _$reportResponseDtoStatusEnum_RESOLVED;
  @BuiltValueEnumConst(wireName: r'DISMISSED')
  static const ReportResponseDtoStatusEnum DISMISSED = _$reportResponseDtoStatusEnum_DISMISSED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ReportResponseDtoStatusEnum unknownDefaultOpenApi = _$reportResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<ReportResponseDtoStatusEnum> get serializer => _$reportResponseDtoStatusEnumSerializer;

  const ReportResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<ReportResponseDtoStatusEnum> get values => _$reportResponseDtoStatusEnumValues;
  static ReportResponseDtoStatusEnum valueOf(String name) => _$reportResponseDtoStatusEnumValueOf(name);
}
