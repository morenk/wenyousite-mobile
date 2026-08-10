//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moderation_case_response_dto.g.dart';

/// ModerationCaseResponseDto
///
/// Properties:
/// * [id]
/// * [targetType]
/// * [targetId]
/// * [status]
/// * [createdAt]
/// * [updatedAt]
/// * [reports]
/// * [decisions]
@BuiltValue()
abstract class ModerationCaseResponseDto implements Built<ModerationCaseResponseDto, ModerationCaseResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'targetType')
  ModerationCaseResponseDtoTargetTypeEnum get targetType;
  // enum targetTypeEnum {  USER,  THREAD,  POST,  MOMENT,  MOMENT_COMMENT,  DIRECT_MESSAGE,  };

  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  @BuiltValueField(wireName: r'status')
  ModerationCaseResponseDtoStatusEnum get status;
  // enum statusEnum {  OPEN,  RESOLVED,  DISMISSED,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'reports')
  BuiltList<BuiltMap<String, JsonObject?>> get reports;

  @BuiltValueField(wireName: r'decisions')
  BuiltList<BuiltMap<String, JsonObject?>> get decisions;

  ModerationCaseResponseDto._();

  factory ModerationCaseResponseDto([void updates(ModerationCaseResponseDtoBuilder b)]) = _$ModerationCaseResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModerationCaseResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModerationCaseResponseDto> get serializer => _$ModerationCaseResponseDtoSerializer();
}

class _$ModerationCaseResponseDtoSerializer implements PrimitiveSerializer<ModerationCaseResponseDto> {
  @override
  final Iterable<Type> types = const [ModerationCaseResponseDto, _$ModerationCaseResponseDto];

  @override
  final String wireName = r'ModerationCaseResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModerationCaseResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'targetType';
    yield serializers.serialize(
      object.targetType,
      specifiedType: const FullType(ModerationCaseResponseDtoTargetTypeEnum),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ModerationCaseResponseDtoStatusEnum),
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
    yield r'reports';
    yield serializers.serialize(
      object.reports,
      specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
    );
    yield r'decisions';
    yield serializers.serialize(
      object.decisions,
      specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ModerationCaseResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModerationCaseResponseDtoBuilder result,
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
        case r'targetType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ModerationCaseResponseDtoTargetTypeEnum),
          ) as ModerationCaseResponseDtoTargetTypeEnum;
          result.targetType = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ModerationCaseResponseDtoStatusEnum),
          ) as ModerationCaseResponseDtoStatusEnum;
          result.status = valueDes;
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
        case r'reports':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
          ) as BuiltList<BuiltMap<String, JsonObject?>>;
          result.reports.replace(valueDes);
          break;
        case r'decisions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
          ) as BuiltList<BuiltMap<String, JsonObject?>>;
          result.decisions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ModerationCaseResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModerationCaseResponseDtoBuilder();
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

class ModerationCaseResponseDtoTargetTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const ModerationCaseResponseDtoTargetTypeEnum USER = _$moderationCaseResponseDtoTargetTypeEnum_USER;
  @BuiltValueEnumConst(wireName: r'THREAD')
  static const ModerationCaseResponseDtoTargetTypeEnum THREAD = _$moderationCaseResponseDtoTargetTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'POST')
  static const ModerationCaseResponseDtoTargetTypeEnum POST = _$moderationCaseResponseDtoTargetTypeEnum_POST;
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const ModerationCaseResponseDtoTargetTypeEnum MOMENT = _$moderationCaseResponseDtoTargetTypeEnum_MOMENT;
  @BuiltValueEnumConst(wireName: r'MOMENT_COMMENT')
  static const ModerationCaseResponseDtoTargetTypeEnum MOMENT_COMMENT = _$moderationCaseResponseDtoTargetTypeEnum_MOMENT_COMMENT;
  @BuiltValueEnumConst(wireName: r'DIRECT_MESSAGE')
  static const ModerationCaseResponseDtoTargetTypeEnum DIRECT_MESSAGE = _$moderationCaseResponseDtoTargetTypeEnum_DIRECT_MESSAGE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ModerationCaseResponseDtoTargetTypeEnum unknownDefaultOpenApi = _$moderationCaseResponseDtoTargetTypeEnum_unknownDefaultOpenApi;

  static Serializer<ModerationCaseResponseDtoTargetTypeEnum> get serializer => _$moderationCaseResponseDtoTargetTypeEnumSerializer;

  const ModerationCaseResponseDtoTargetTypeEnum._(String name): super(name);

  static BuiltSet<ModerationCaseResponseDtoTargetTypeEnum> get values => _$moderationCaseResponseDtoTargetTypeEnumValues;
  static ModerationCaseResponseDtoTargetTypeEnum valueOf(String name) => _$moderationCaseResponseDtoTargetTypeEnumValueOf(name);
}

class ModerationCaseResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OPEN')
  static const ModerationCaseResponseDtoStatusEnum OPEN = _$moderationCaseResponseDtoStatusEnum_OPEN;
  @BuiltValueEnumConst(wireName: r'RESOLVED')
  static const ModerationCaseResponseDtoStatusEnum RESOLVED = _$moderationCaseResponseDtoStatusEnum_RESOLVED;
  @BuiltValueEnumConst(wireName: r'DISMISSED')
  static const ModerationCaseResponseDtoStatusEnum DISMISSED = _$moderationCaseResponseDtoStatusEnum_DISMISSED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ModerationCaseResponseDtoStatusEnum unknownDefaultOpenApi = _$moderationCaseResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<ModerationCaseResponseDtoStatusEnum> get serializer => _$moderationCaseResponseDtoStatusEnumSerializer;

  const ModerationCaseResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<ModerationCaseResponseDtoStatusEnum> get values => _$moderationCaseResponseDtoStatusEnumValues;
  static ModerationCaseResponseDtoStatusEnum valueOf(String name) => _$moderationCaseResponseDtoStatusEnumValueOf(name);
}
