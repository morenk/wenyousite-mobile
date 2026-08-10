//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moderation_decision_public_response_dto.g.dart';

/// ModerationDecisionPublicResponseDto
///
/// Properties:
/// * [id]
/// * [targetType]
/// * [targetId]
/// * [action]
/// * [policyCode]
/// * [publicExplanation]
/// * [active]
/// * [appeal]
/// * [createdAt]
@BuiltValue()
abstract class ModerationDecisionPublicResponseDto implements Built<ModerationDecisionPublicResponseDto, ModerationDecisionPublicResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'targetType')
  ModerationDecisionPublicResponseDtoTargetTypeEnum get targetType;
  // enum targetTypeEnum {  USER,  THREAD,  POST,  MOMENT,  MOMENT_COMMENT,  DIRECT_MESSAGE,  };

  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  @BuiltValueField(wireName: r'action')
  ModerationDecisionPublicResponseDtoActionEnum get action;
  // enum actionEnum {  HIDE_CONTENT,  SUSPEND_USER,  BAN_USER,  };

  @BuiltValueField(wireName: r'policyCode')
  ModerationDecisionPublicResponseDtoPolicyCodeEnum get policyCode;
  // enum policyCodeEnum {  SPAM,  HARASSMENT,  HATE_OR_THREATS,  SEXUAL_CONTENT,  VIOLENT_CONTENT,  PERSONAL_INFORMATION,  IMPERSONATION_OR_FRAUD,  INTELLECTUAL_PROPERTY,  ILLEGAL_CONTENT,  OTHER,  };

  @BuiltValueField(wireName: r'publicExplanation')
  String get publicExplanation;

  @BuiltValueField(wireName: r'active')
  bool get active;

  @BuiltValueField(wireName: r'appeal')
  BuiltMap<String, JsonObject?>? get appeal;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  ModerationDecisionPublicResponseDto._();

  factory ModerationDecisionPublicResponseDto([void updates(ModerationDecisionPublicResponseDtoBuilder b)]) = _$ModerationDecisionPublicResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModerationDecisionPublicResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModerationDecisionPublicResponseDto> get serializer => _$ModerationDecisionPublicResponseDtoSerializer();
}

class _$ModerationDecisionPublicResponseDtoSerializer implements PrimitiveSerializer<ModerationDecisionPublicResponseDto> {
  @override
  final Iterable<Type> types = const [ModerationDecisionPublicResponseDto, _$ModerationDecisionPublicResponseDto];

  @override
  final String wireName = r'ModerationDecisionPublicResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModerationDecisionPublicResponseDto object, {
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
      specifiedType: const FullType(ModerationDecisionPublicResponseDtoTargetTypeEnum),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(ModerationDecisionPublicResponseDtoActionEnum),
    );
    yield r'policyCode';
    yield serializers.serialize(
      object.policyCode,
      specifiedType: const FullType(ModerationDecisionPublicResponseDtoPolicyCodeEnum),
    );
    yield r'publicExplanation';
    yield serializers.serialize(
      object.publicExplanation,
      specifiedType: const FullType(String),
    );
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
    yield r'appeal';
    yield object.appeal == null ? null : serializers.serialize(
      object.appeal,
      specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
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
    ModerationDecisionPublicResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModerationDecisionPublicResponseDtoBuilder result,
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
            specifiedType: const FullType(ModerationDecisionPublicResponseDtoTargetTypeEnum),
          ) as ModerationDecisionPublicResponseDtoTargetTypeEnum;
          result.targetType = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetId = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ModerationDecisionPublicResponseDtoActionEnum),
          ) as ModerationDecisionPublicResponseDtoActionEnum;
          result.action = valueDes;
          break;
        case r'policyCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ModerationDecisionPublicResponseDtoPolicyCodeEnum),
          ) as ModerationDecisionPublicResponseDtoPolicyCodeEnum;
          result.policyCode = valueDes;
          break;
        case r'publicExplanation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publicExplanation = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.active = valueDes;
          break;
        case r'appeal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.appeal.replace(valueDes);
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
  ModerationDecisionPublicResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModerationDecisionPublicResponseDtoBuilder();
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

class ModerationDecisionPublicResponseDtoTargetTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const ModerationDecisionPublicResponseDtoTargetTypeEnum USER = _$moderationDecisionPublicResponseDtoTargetTypeEnum_USER;
  @BuiltValueEnumConst(wireName: r'THREAD')
  static const ModerationDecisionPublicResponseDtoTargetTypeEnum THREAD = _$moderationDecisionPublicResponseDtoTargetTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'POST')
  static const ModerationDecisionPublicResponseDtoTargetTypeEnum POST = _$moderationDecisionPublicResponseDtoTargetTypeEnum_POST;
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const ModerationDecisionPublicResponseDtoTargetTypeEnum MOMENT = _$moderationDecisionPublicResponseDtoTargetTypeEnum_MOMENT;
  @BuiltValueEnumConst(wireName: r'MOMENT_COMMENT')
  static const ModerationDecisionPublicResponseDtoTargetTypeEnum MOMENT_COMMENT = _$moderationDecisionPublicResponseDtoTargetTypeEnum_MOMENT_COMMENT;
  @BuiltValueEnumConst(wireName: r'DIRECT_MESSAGE')
  static const ModerationDecisionPublicResponseDtoTargetTypeEnum DIRECT_MESSAGE = _$moderationDecisionPublicResponseDtoTargetTypeEnum_DIRECT_MESSAGE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ModerationDecisionPublicResponseDtoTargetTypeEnum unknownDefaultOpenApi = _$moderationDecisionPublicResponseDtoTargetTypeEnum_unknownDefaultOpenApi;

  static Serializer<ModerationDecisionPublicResponseDtoTargetTypeEnum> get serializer => _$moderationDecisionPublicResponseDtoTargetTypeEnumSerializer;

  const ModerationDecisionPublicResponseDtoTargetTypeEnum._(String name): super(name);

  static BuiltSet<ModerationDecisionPublicResponseDtoTargetTypeEnum> get values => _$moderationDecisionPublicResponseDtoTargetTypeEnumValues;
  static ModerationDecisionPublicResponseDtoTargetTypeEnum valueOf(String name) => _$moderationDecisionPublicResponseDtoTargetTypeEnumValueOf(name);
}

class ModerationDecisionPublicResponseDtoActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'HIDE_CONTENT')
  static const ModerationDecisionPublicResponseDtoActionEnum HIDE_CONTENT = _$moderationDecisionPublicResponseDtoActionEnum_HIDE_CONTENT;
  @BuiltValueEnumConst(wireName: r'SUSPEND_USER')
  static const ModerationDecisionPublicResponseDtoActionEnum SUSPEND_USER = _$moderationDecisionPublicResponseDtoActionEnum_SUSPEND_USER;
  @BuiltValueEnumConst(wireName: r'BAN_USER')
  static const ModerationDecisionPublicResponseDtoActionEnum BAN_USER = _$moderationDecisionPublicResponseDtoActionEnum_BAN_USER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ModerationDecisionPublicResponseDtoActionEnum unknownDefaultOpenApi = _$moderationDecisionPublicResponseDtoActionEnum_unknownDefaultOpenApi;

  static Serializer<ModerationDecisionPublicResponseDtoActionEnum> get serializer => _$moderationDecisionPublicResponseDtoActionEnumSerializer;

  const ModerationDecisionPublicResponseDtoActionEnum._(String name): super(name);

  static BuiltSet<ModerationDecisionPublicResponseDtoActionEnum> get values => _$moderationDecisionPublicResponseDtoActionEnumValues;
  static ModerationDecisionPublicResponseDtoActionEnum valueOf(String name) => _$moderationDecisionPublicResponseDtoActionEnumValueOf(name);
}

class ModerationDecisionPublicResponseDtoPolicyCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SPAM')
  static const ModerationDecisionPublicResponseDtoPolicyCodeEnum SPAM = _$moderationDecisionPublicResponseDtoPolicyCodeEnum_SPAM;
  @BuiltValueEnumConst(wireName: r'HARASSMENT')
  static const ModerationDecisionPublicResponseDtoPolicyCodeEnum HARASSMENT = _$moderationDecisionPublicResponseDtoPolicyCodeEnum_HARASSMENT;
  @BuiltValueEnumConst(wireName: r'HATE_OR_THREATS')
  static const ModerationDecisionPublicResponseDtoPolicyCodeEnum HATE_OR_THREATS = _$moderationDecisionPublicResponseDtoPolicyCodeEnum_HATE_OR_THREATS;
  @BuiltValueEnumConst(wireName: r'SEXUAL_CONTENT')
  static const ModerationDecisionPublicResponseDtoPolicyCodeEnum SEXUAL_CONTENT = _$moderationDecisionPublicResponseDtoPolicyCodeEnum_SEXUAL_CONTENT;
  @BuiltValueEnumConst(wireName: r'VIOLENT_CONTENT')
  static const ModerationDecisionPublicResponseDtoPolicyCodeEnum VIOLENT_CONTENT = _$moderationDecisionPublicResponseDtoPolicyCodeEnum_VIOLENT_CONTENT;
  @BuiltValueEnumConst(wireName: r'PERSONAL_INFORMATION')
  static const ModerationDecisionPublicResponseDtoPolicyCodeEnum PERSONAL_INFORMATION = _$moderationDecisionPublicResponseDtoPolicyCodeEnum_PERSONAL_INFORMATION;
  @BuiltValueEnumConst(wireName: r'IMPERSONATION_OR_FRAUD')
  static const ModerationDecisionPublicResponseDtoPolicyCodeEnum IMPERSONATION_OR_FRAUD = _$moderationDecisionPublicResponseDtoPolicyCodeEnum_IMPERSONATION_OR_FRAUD;
  @BuiltValueEnumConst(wireName: r'INTELLECTUAL_PROPERTY')
  static const ModerationDecisionPublicResponseDtoPolicyCodeEnum INTELLECTUAL_PROPERTY = _$moderationDecisionPublicResponseDtoPolicyCodeEnum_INTELLECTUAL_PROPERTY;
  @BuiltValueEnumConst(wireName: r'ILLEGAL_CONTENT')
  static const ModerationDecisionPublicResponseDtoPolicyCodeEnum ILLEGAL_CONTENT = _$moderationDecisionPublicResponseDtoPolicyCodeEnum_ILLEGAL_CONTENT;
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ModerationDecisionPublicResponseDtoPolicyCodeEnum OTHER = _$moderationDecisionPublicResponseDtoPolicyCodeEnum_OTHER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ModerationDecisionPublicResponseDtoPolicyCodeEnum unknownDefaultOpenApi = _$moderationDecisionPublicResponseDtoPolicyCodeEnum_unknownDefaultOpenApi;

  static Serializer<ModerationDecisionPublicResponseDtoPolicyCodeEnum> get serializer => _$moderationDecisionPublicResponseDtoPolicyCodeEnumSerializer;

  const ModerationDecisionPublicResponseDtoPolicyCodeEnum._(String name): super(name);

  static BuiltSet<ModerationDecisionPublicResponseDtoPolicyCodeEnum> get values => _$moderationDecisionPublicResponseDtoPolicyCodeEnumValues;
  static ModerationDecisionPublicResponseDtoPolicyCodeEnum valueOf(String name) => _$moderationDecisionPublicResponseDtoPolicyCodeEnumValueOf(name);
}
