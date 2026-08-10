//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moderation_appeal_response_dto.g.dart';

/// ModerationAppealResponseDto
///
/// Properties:
/// * [id]
/// * [statement]
/// * [status]
/// * [decision]
/// * [appellant]
/// * [createdAt]
@BuiltValue()
abstract class ModerationAppealResponseDto implements Built<ModerationAppealResponseDto, ModerationAppealResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'statement')
  String get statement;

  @BuiltValueField(wireName: r'status')
  ModerationAppealResponseDtoStatusEnum get status;
  // enum statusEnum {  PENDING,  UPHELD,  OVERTURNED,  };

  @BuiltValueField(wireName: r'decision')
  BuiltMap<String, JsonObject?> get decision;

  @BuiltValueField(wireName: r'appellant')
  BuiltMap<String, JsonObject?> get appellant;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  ModerationAppealResponseDto._();

  factory ModerationAppealResponseDto([void updates(ModerationAppealResponseDtoBuilder b)]) = _$ModerationAppealResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModerationAppealResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModerationAppealResponseDto> get serializer => _$ModerationAppealResponseDtoSerializer();
}

class _$ModerationAppealResponseDtoSerializer implements PrimitiveSerializer<ModerationAppealResponseDto> {
  @override
  final Iterable<Type> types = const [ModerationAppealResponseDto, _$ModerationAppealResponseDto];

  @override
  final String wireName = r'ModerationAppealResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModerationAppealResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'statement';
    yield serializers.serialize(
      object.statement,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ModerationAppealResponseDtoStatusEnum),
    );
    yield r'decision';
    yield serializers.serialize(
      object.decision,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'appellant';
    yield serializers.serialize(
      object.appellant,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
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
    ModerationAppealResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModerationAppealResponseDtoBuilder result,
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
        case r'statement':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.statement = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ModerationAppealResponseDtoStatusEnum),
          ) as ModerationAppealResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'decision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.decision.replace(valueDes);
          break;
        case r'appellant':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.appellant.replace(valueDes);
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
  ModerationAppealResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModerationAppealResponseDtoBuilder();
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

class ModerationAppealResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PENDING')
  static const ModerationAppealResponseDtoStatusEnum PENDING = _$moderationAppealResponseDtoStatusEnum_PENDING;
  @BuiltValueEnumConst(wireName: r'UPHELD')
  static const ModerationAppealResponseDtoStatusEnum UPHELD = _$moderationAppealResponseDtoStatusEnum_UPHELD;
  @BuiltValueEnumConst(wireName: r'OVERTURNED')
  static const ModerationAppealResponseDtoStatusEnum OVERTURNED = _$moderationAppealResponseDtoStatusEnum_OVERTURNED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ModerationAppealResponseDtoStatusEnum unknownDefaultOpenApi = _$moderationAppealResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<ModerationAppealResponseDtoStatusEnum> get serializer => _$moderationAppealResponseDtoStatusEnumSerializer;

  const ModerationAppealResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<ModerationAppealResponseDtoStatusEnum> get values => _$moderationAppealResponseDtoStatusEnumValues;
  static ModerationAppealResponseDtoStatusEnum valueOf(String name) => _$moderationAppealResponseDtoStatusEnumValueOf(name);
}
