//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
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
/// * [reason]
/// * [status]
/// * [handledBy]
/// * [handledAt]
/// * [createdAt]
@BuiltValue()
abstract class ReportResponseDto implements Built<ReportResponseDto, ReportResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'reporterId')
  String get reporterId;

  @BuiltValueField(wireName: r'targetType')
  String get targetType;

  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'status')
  ReportResponseDtoStatusEnum get status;
  // enum statusEnum {  PENDING,  RESOLVED,  DISMISSED,  };

  @BuiltValueField(wireName: r'handledBy')
  String? get handledBy;

  @BuiltValueField(wireName: r'handledAt')
  DateTime? get handledAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

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
    yield serializers.serialize(
      object.reporterId,
      specifiedType: const FullType(String),
    );
    yield r'targetType';
    yield serializers.serialize(
      object.targetType,
      specifiedType: const FullType(String),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
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
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
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
            specifiedType: const FullType(String),
          ) as String;
          result.reporterId = valueDes;
          break;
        case r'targetType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetType = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetId = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
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
