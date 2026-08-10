//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resolve_moderation_case_dto.g.dart';

/// ResolveModerationCaseDto
///
/// Properties:
/// * [outcome]
/// * [action]
/// * [policyCode] - 适用的站务规则分类
/// * [publicExplanation] - 向被处置用户公开
/// * [internalNote] - 仅管理员可见
/// * [suspendUntil] - 暂停账号时必填
@BuiltValue()
abstract class ResolveModerationCaseDto implements Built<ResolveModerationCaseDto, ResolveModerationCaseDtoBuilder> {
  @BuiltValueField(wireName: r'outcome')
  ResolveModerationCaseDtoOutcomeEnum get outcome;
  // enum outcomeEnum {  RESOLVED,  DISMISSED,  };

  @BuiltValueField(wireName: r'action')
  ResolveModerationCaseDtoActionEnum? get action;
  // enum actionEnum {  HIDE_CONTENT,  SUSPEND_USER,  BAN_USER,  };

  /// 适用的站务规则分类
  @BuiltValueField(wireName: r'policyCode')
  ResolveModerationCaseDtoPolicyCodeEnum get policyCode;
  // enum policyCodeEnum {  SPAM,  HARASSMENT,  HATE_OR_THREATS,  SEXUAL_CONTENT,  VIOLENT_CONTENT,  PERSONAL_INFORMATION,  IMPERSONATION_OR_FRAUD,  INTELLECTUAL_PROPERTY,  ILLEGAL_CONTENT,  OTHER,  };

  /// 向被处置用户公开
  @BuiltValueField(wireName: r'publicExplanation')
  String get publicExplanation;

  /// 仅管理员可见
  @BuiltValueField(wireName: r'internalNote')
  String? get internalNote;

  /// 暂停账号时必填
  @BuiltValueField(wireName: r'suspendUntil')
  DateTime? get suspendUntil;

  ResolveModerationCaseDto._();

  factory ResolveModerationCaseDto([void updates(ResolveModerationCaseDtoBuilder b)]) = _$ResolveModerationCaseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResolveModerationCaseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResolveModerationCaseDto> get serializer => _$ResolveModerationCaseDtoSerializer();
}

class _$ResolveModerationCaseDtoSerializer implements PrimitiveSerializer<ResolveModerationCaseDto> {
  @override
  final Iterable<Type> types = const [ResolveModerationCaseDto, _$ResolveModerationCaseDto];

  @override
  final String wireName = r'ResolveModerationCaseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResolveModerationCaseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'outcome';
    yield serializers.serialize(
      object.outcome,
      specifiedType: const FullType(ResolveModerationCaseDtoOutcomeEnum),
    );
    if (object.action != null) {
      yield r'action';
      yield serializers.serialize(
        object.action,
        specifiedType: const FullType(ResolveModerationCaseDtoActionEnum),
      );
    }
    yield r'policyCode';
    yield serializers.serialize(
      object.policyCode,
      specifiedType: const FullType(ResolveModerationCaseDtoPolicyCodeEnum),
    );
    yield r'publicExplanation';
    yield serializers.serialize(
      object.publicExplanation,
      specifiedType: const FullType(String),
    );
    if (object.internalNote != null) {
      yield r'internalNote';
      yield serializers.serialize(
        object.internalNote,
        specifiedType: const FullType(String),
      );
    }
    if (object.suspendUntil != null) {
      yield r'suspendUntil';
      yield serializers.serialize(
        object.suspendUntil,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ResolveModerationCaseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ResolveModerationCaseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'outcome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResolveModerationCaseDtoOutcomeEnum),
          ) as ResolveModerationCaseDtoOutcomeEnum;
          result.outcome = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResolveModerationCaseDtoActionEnum),
          ) as ResolveModerationCaseDtoActionEnum;
          result.action = valueDes;
          break;
        case r'policyCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResolveModerationCaseDtoPolicyCodeEnum),
          ) as ResolveModerationCaseDtoPolicyCodeEnum;
          result.policyCode = valueDes;
          break;
        case r'publicExplanation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publicExplanation = valueDes;
          break;
        case r'internalNote':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.internalNote = valueDes;
          break;
        case r'suspendUntil':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.suspendUntil = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResolveModerationCaseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResolveModerationCaseDtoBuilder();
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

class ResolveModerationCaseDtoOutcomeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'RESOLVED')
  static const ResolveModerationCaseDtoOutcomeEnum RESOLVED = _$resolveModerationCaseDtoOutcomeEnum_RESOLVED;
  @BuiltValueEnumConst(wireName: r'DISMISSED')
  static const ResolveModerationCaseDtoOutcomeEnum DISMISSED = _$resolveModerationCaseDtoOutcomeEnum_DISMISSED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ResolveModerationCaseDtoOutcomeEnum unknownDefaultOpenApi = _$resolveModerationCaseDtoOutcomeEnum_unknownDefaultOpenApi;

  static Serializer<ResolveModerationCaseDtoOutcomeEnum> get serializer => _$resolveModerationCaseDtoOutcomeEnumSerializer;

  const ResolveModerationCaseDtoOutcomeEnum._(String name): super(name);

  static BuiltSet<ResolveModerationCaseDtoOutcomeEnum> get values => _$resolveModerationCaseDtoOutcomeEnumValues;
  static ResolveModerationCaseDtoOutcomeEnum valueOf(String name) => _$resolveModerationCaseDtoOutcomeEnumValueOf(name);
}

class ResolveModerationCaseDtoActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'HIDE_CONTENT')
  static const ResolveModerationCaseDtoActionEnum HIDE_CONTENT = _$resolveModerationCaseDtoActionEnum_HIDE_CONTENT;
  @BuiltValueEnumConst(wireName: r'SUSPEND_USER')
  static const ResolveModerationCaseDtoActionEnum SUSPEND_USER = _$resolveModerationCaseDtoActionEnum_SUSPEND_USER;
  @BuiltValueEnumConst(wireName: r'BAN_USER')
  static const ResolveModerationCaseDtoActionEnum BAN_USER = _$resolveModerationCaseDtoActionEnum_BAN_USER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ResolveModerationCaseDtoActionEnum unknownDefaultOpenApi = _$resolveModerationCaseDtoActionEnum_unknownDefaultOpenApi;

  static Serializer<ResolveModerationCaseDtoActionEnum> get serializer => _$resolveModerationCaseDtoActionEnumSerializer;

  const ResolveModerationCaseDtoActionEnum._(String name): super(name);

  static BuiltSet<ResolveModerationCaseDtoActionEnum> get values => _$resolveModerationCaseDtoActionEnumValues;
  static ResolveModerationCaseDtoActionEnum valueOf(String name) => _$resolveModerationCaseDtoActionEnumValueOf(name);
}

class ResolveModerationCaseDtoPolicyCodeEnum extends EnumClass {

  /// 适用的站务规则分类
  @BuiltValueEnumConst(wireName: r'SPAM')
  static const ResolveModerationCaseDtoPolicyCodeEnum SPAM = _$resolveModerationCaseDtoPolicyCodeEnum_SPAM;
  /// 适用的站务规则分类
  @BuiltValueEnumConst(wireName: r'HARASSMENT')
  static const ResolveModerationCaseDtoPolicyCodeEnum HARASSMENT = _$resolveModerationCaseDtoPolicyCodeEnum_HARASSMENT;
  /// 适用的站务规则分类
  @BuiltValueEnumConst(wireName: r'HATE_OR_THREATS')
  static const ResolveModerationCaseDtoPolicyCodeEnum HATE_OR_THREATS = _$resolveModerationCaseDtoPolicyCodeEnum_HATE_OR_THREATS;
  /// 适用的站务规则分类
  @BuiltValueEnumConst(wireName: r'SEXUAL_CONTENT')
  static const ResolveModerationCaseDtoPolicyCodeEnum SEXUAL_CONTENT = _$resolveModerationCaseDtoPolicyCodeEnum_SEXUAL_CONTENT;
  /// 适用的站务规则分类
  @BuiltValueEnumConst(wireName: r'VIOLENT_CONTENT')
  static const ResolveModerationCaseDtoPolicyCodeEnum VIOLENT_CONTENT = _$resolveModerationCaseDtoPolicyCodeEnum_VIOLENT_CONTENT;
  /// 适用的站务规则分类
  @BuiltValueEnumConst(wireName: r'PERSONAL_INFORMATION')
  static const ResolveModerationCaseDtoPolicyCodeEnum PERSONAL_INFORMATION = _$resolveModerationCaseDtoPolicyCodeEnum_PERSONAL_INFORMATION;
  /// 适用的站务规则分类
  @BuiltValueEnumConst(wireName: r'IMPERSONATION_OR_FRAUD')
  static const ResolveModerationCaseDtoPolicyCodeEnum IMPERSONATION_OR_FRAUD = _$resolveModerationCaseDtoPolicyCodeEnum_IMPERSONATION_OR_FRAUD;
  /// 适用的站务规则分类
  @BuiltValueEnumConst(wireName: r'INTELLECTUAL_PROPERTY')
  static const ResolveModerationCaseDtoPolicyCodeEnum INTELLECTUAL_PROPERTY = _$resolveModerationCaseDtoPolicyCodeEnum_INTELLECTUAL_PROPERTY;
  /// 适用的站务规则分类
  @BuiltValueEnumConst(wireName: r'ILLEGAL_CONTENT')
  static const ResolveModerationCaseDtoPolicyCodeEnum ILLEGAL_CONTENT = _$resolveModerationCaseDtoPolicyCodeEnum_ILLEGAL_CONTENT;
  /// 适用的站务规则分类
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ResolveModerationCaseDtoPolicyCodeEnum OTHER = _$resolveModerationCaseDtoPolicyCodeEnum_OTHER;
  /// 适用的站务规则分类
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ResolveModerationCaseDtoPolicyCodeEnum unknownDefaultOpenApi = _$resolveModerationCaseDtoPolicyCodeEnum_unknownDefaultOpenApi;

  static Serializer<ResolveModerationCaseDtoPolicyCodeEnum> get serializer => _$resolveModerationCaseDtoPolicyCodeEnumSerializer;

  const ResolveModerationCaseDtoPolicyCodeEnum._(String name): super(name);

  static BuiltSet<ResolveModerationCaseDtoPolicyCodeEnum> get values => _$resolveModerationCaseDtoPolicyCodeEnumValues;
  static ResolveModerationCaseDtoPolicyCodeEnum valueOf(String name) => _$resolveModerationCaseDtoPolicyCodeEnumValueOf(name);
}
