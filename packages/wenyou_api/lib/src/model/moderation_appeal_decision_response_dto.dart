//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moderation_appeal_decision_response_dto.g.dart';

/// ModerationAppealDecisionResponseDto
///
/// Properties:
/// * [id]
/// * [targetType]
/// * [targetId]
/// * [action]
/// * [policyCode]
/// * [publicExplanation]
/// * [active]
/// * [createdAt]
@BuiltValue()
abstract class ModerationAppealDecisionResponseDto implements Built<ModerationAppealDecisionResponseDto, ModerationAppealDecisionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'targetType')
  ModerationAppealDecisionResponseDtoTargetTypeEnum get targetType;
  // enum targetTypeEnum {  USER,  THREAD,  POST,  MOMENT,  MOMENT_COMMENT,  DIRECT_MESSAGE,  };

  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  @BuiltValueField(wireName: r'action')
  ModerationAppealDecisionResponseDtoActionEnum get action;
  // enum actionEnum {  HIDE_CONTENT,  SUSPEND_USER,  BAN_USER,  };

  @BuiltValueField(wireName: r'policyCode')
  ModerationAppealDecisionResponseDtoPolicyCodeEnum get policyCode;
  // enum policyCodeEnum {  SPAM,  HARASSMENT,  HATE_OR_THREATS,  SEXUAL_CONTENT,  VIOLENT_CONTENT,  PERSONAL_INFORMATION,  IMPERSONATION_OR_FRAUD,  INTELLECTUAL_PROPERTY,  ILLEGAL_CONTENT,  OTHER,  };

  @BuiltValueField(wireName: r'publicExplanation')
  String get publicExplanation;

  @BuiltValueField(wireName: r'active')
  bool get active;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  ModerationAppealDecisionResponseDto._();

  factory ModerationAppealDecisionResponseDto([void updates(ModerationAppealDecisionResponseDtoBuilder b)]) = _$ModerationAppealDecisionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModerationAppealDecisionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModerationAppealDecisionResponseDto> get serializer => _$ModerationAppealDecisionResponseDtoSerializer();
}

class _$ModerationAppealDecisionResponseDtoSerializer implements PrimitiveSerializer<ModerationAppealDecisionResponseDto> {
  @override
  final Iterable<Type> types = const [ModerationAppealDecisionResponseDto, _$ModerationAppealDecisionResponseDto];

  @override
  final String wireName = r'ModerationAppealDecisionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModerationAppealDecisionResponseDto object, {
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
      specifiedType: const FullType(ModerationAppealDecisionResponseDtoTargetTypeEnum),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(ModerationAppealDecisionResponseDtoActionEnum),
    );
    yield r'policyCode';
    yield serializers.serialize(
      object.policyCode,
      specifiedType: const FullType(ModerationAppealDecisionResponseDtoPolicyCodeEnum),
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
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ModerationAppealDecisionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModerationAppealDecisionResponseDtoBuilder result,
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
            specifiedType: const FullType(ModerationAppealDecisionResponseDtoTargetTypeEnum),
          ) as ModerationAppealDecisionResponseDtoTargetTypeEnum;
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
            specifiedType: const FullType(ModerationAppealDecisionResponseDtoActionEnum),
          ) as ModerationAppealDecisionResponseDtoActionEnum;
          result.action = valueDes;
          break;
        case r'policyCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ModerationAppealDecisionResponseDtoPolicyCodeEnum),
          ) as ModerationAppealDecisionResponseDtoPolicyCodeEnum;
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
  ModerationAppealDecisionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModerationAppealDecisionResponseDtoBuilder();
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

class ModerationAppealDecisionResponseDtoTargetTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const ModerationAppealDecisionResponseDtoTargetTypeEnum USER = _$moderationAppealDecisionResponseDtoTargetTypeEnum_USER;
  @BuiltValueEnumConst(wireName: r'THREAD')
  static const ModerationAppealDecisionResponseDtoTargetTypeEnum THREAD = _$moderationAppealDecisionResponseDtoTargetTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'POST')
  static const ModerationAppealDecisionResponseDtoTargetTypeEnum POST = _$moderationAppealDecisionResponseDtoTargetTypeEnum_POST;
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const ModerationAppealDecisionResponseDtoTargetTypeEnum MOMENT = _$moderationAppealDecisionResponseDtoTargetTypeEnum_MOMENT;
  @BuiltValueEnumConst(wireName: r'MOMENT_COMMENT')
  static const ModerationAppealDecisionResponseDtoTargetTypeEnum MOMENT_COMMENT = _$moderationAppealDecisionResponseDtoTargetTypeEnum_MOMENT_COMMENT;
  @BuiltValueEnumConst(wireName: r'DIRECT_MESSAGE')
  static const ModerationAppealDecisionResponseDtoTargetTypeEnum DIRECT_MESSAGE = _$moderationAppealDecisionResponseDtoTargetTypeEnum_DIRECT_MESSAGE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ModerationAppealDecisionResponseDtoTargetTypeEnum unknownDefaultOpenApi = _$moderationAppealDecisionResponseDtoTargetTypeEnum_unknownDefaultOpenApi;

  static Serializer<ModerationAppealDecisionResponseDtoTargetTypeEnum> get serializer => _$moderationAppealDecisionResponseDtoTargetTypeEnumSerializer;

  const ModerationAppealDecisionResponseDtoTargetTypeEnum._(String name): super(name);

  static BuiltSet<ModerationAppealDecisionResponseDtoTargetTypeEnum> get values => _$moderationAppealDecisionResponseDtoTargetTypeEnumValues;
  static ModerationAppealDecisionResponseDtoTargetTypeEnum valueOf(String name) => _$moderationAppealDecisionResponseDtoTargetTypeEnumValueOf(name);
}

class ModerationAppealDecisionResponseDtoActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'HIDE_CONTENT')
  static const ModerationAppealDecisionResponseDtoActionEnum HIDE_CONTENT = _$moderationAppealDecisionResponseDtoActionEnum_HIDE_CONTENT;
  @BuiltValueEnumConst(wireName: r'SUSPEND_USER')
  static const ModerationAppealDecisionResponseDtoActionEnum SUSPEND_USER = _$moderationAppealDecisionResponseDtoActionEnum_SUSPEND_USER;
  @BuiltValueEnumConst(wireName: r'BAN_USER')
  static const ModerationAppealDecisionResponseDtoActionEnum BAN_USER = _$moderationAppealDecisionResponseDtoActionEnum_BAN_USER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ModerationAppealDecisionResponseDtoActionEnum unknownDefaultOpenApi = _$moderationAppealDecisionResponseDtoActionEnum_unknownDefaultOpenApi;

  static Serializer<ModerationAppealDecisionResponseDtoActionEnum> get serializer => _$moderationAppealDecisionResponseDtoActionEnumSerializer;

  const ModerationAppealDecisionResponseDtoActionEnum._(String name): super(name);

  static BuiltSet<ModerationAppealDecisionResponseDtoActionEnum> get values => _$moderationAppealDecisionResponseDtoActionEnumValues;
  static ModerationAppealDecisionResponseDtoActionEnum valueOf(String name) => _$moderationAppealDecisionResponseDtoActionEnumValueOf(name);
}

class ModerationAppealDecisionResponseDtoPolicyCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SPAM')
  static const ModerationAppealDecisionResponseDtoPolicyCodeEnum SPAM = _$moderationAppealDecisionResponseDtoPolicyCodeEnum_SPAM;
  @BuiltValueEnumConst(wireName: r'HARASSMENT')
  static const ModerationAppealDecisionResponseDtoPolicyCodeEnum HARASSMENT = _$moderationAppealDecisionResponseDtoPolicyCodeEnum_HARASSMENT;
  @BuiltValueEnumConst(wireName: r'HATE_OR_THREATS')
  static const ModerationAppealDecisionResponseDtoPolicyCodeEnum HATE_OR_THREATS = _$moderationAppealDecisionResponseDtoPolicyCodeEnum_HATE_OR_THREATS;
  @BuiltValueEnumConst(wireName: r'SEXUAL_CONTENT')
  static const ModerationAppealDecisionResponseDtoPolicyCodeEnum SEXUAL_CONTENT = _$moderationAppealDecisionResponseDtoPolicyCodeEnum_SEXUAL_CONTENT;
  @BuiltValueEnumConst(wireName: r'VIOLENT_CONTENT')
  static const ModerationAppealDecisionResponseDtoPolicyCodeEnum VIOLENT_CONTENT = _$moderationAppealDecisionResponseDtoPolicyCodeEnum_VIOLENT_CONTENT;
  @BuiltValueEnumConst(wireName: r'PERSONAL_INFORMATION')
  static const ModerationAppealDecisionResponseDtoPolicyCodeEnum PERSONAL_INFORMATION = _$moderationAppealDecisionResponseDtoPolicyCodeEnum_PERSONAL_INFORMATION;
  @BuiltValueEnumConst(wireName: r'IMPERSONATION_OR_FRAUD')
  static const ModerationAppealDecisionResponseDtoPolicyCodeEnum IMPERSONATION_OR_FRAUD = _$moderationAppealDecisionResponseDtoPolicyCodeEnum_IMPERSONATION_OR_FRAUD;
  @BuiltValueEnumConst(wireName: r'INTELLECTUAL_PROPERTY')
  static const ModerationAppealDecisionResponseDtoPolicyCodeEnum INTELLECTUAL_PROPERTY = _$moderationAppealDecisionResponseDtoPolicyCodeEnum_INTELLECTUAL_PROPERTY;
  @BuiltValueEnumConst(wireName: r'ILLEGAL_CONTENT')
  static const ModerationAppealDecisionResponseDtoPolicyCodeEnum ILLEGAL_CONTENT = _$moderationAppealDecisionResponseDtoPolicyCodeEnum_ILLEGAL_CONTENT;
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ModerationAppealDecisionResponseDtoPolicyCodeEnum OTHER = _$moderationAppealDecisionResponseDtoPolicyCodeEnum_OTHER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ModerationAppealDecisionResponseDtoPolicyCodeEnum unknownDefaultOpenApi = _$moderationAppealDecisionResponseDtoPolicyCodeEnum_unknownDefaultOpenApi;

  static Serializer<ModerationAppealDecisionResponseDtoPolicyCodeEnum> get serializer => _$moderationAppealDecisionResponseDtoPolicyCodeEnumSerializer;

  const ModerationAppealDecisionResponseDtoPolicyCodeEnum._(String name): super(name);

  static BuiltSet<ModerationAppealDecisionResponseDtoPolicyCodeEnum> get values => _$moderationAppealDecisionResponseDtoPolicyCodeEnumValues;
  static ModerationAppealDecisionResponseDtoPolicyCodeEnum valueOf(String name) => _$moderationAppealDecisionResponseDtoPolicyCodeEnumValueOf(name);
}
