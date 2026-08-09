//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resolve_report_dto.g.dart';

/// ResolveReportDto
///
/// Properties:
/// * [outcome]
/// * [note] - 同时作为关联处罚的理由
/// * [action]
/// * [suspendUntil] - SUSPEND_USER 时必填
@BuiltValue()
abstract class ResolveReportDto implements Built<ResolveReportDto, ResolveReportDtoBuilder> {
  @BuiltValueField(wireName: r'outcome')
  ResolveReportDtoOutcomeEnum get outcome;
  // enum outcomeEnum {  RESOLVED,  DISMISSED,  };

  /// 同时作为关联处罚的理由
  @BuiltValueField(wireName: r'note')
  String get note;

  @BuiltValueField(wireName: r'action')
  ResolveReportDtoActionEnum? get action;
  // enum actionEnum {  NONE,  HIDE_CONTENT,  SUSPEND_USER,  BAN_USER,  };

  /// SUSPEND_USER 时必填
  @BuiltValueField(wireName: r'suspendUntil')
  DateTime? get suspendUntil;

  ResolveReportDto._();

  factory ResolveReportDto([void updates(ResolveReportDtoBuilder b)]) = _$ResolveReportDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResolveReportDtoBuilder b) => b
      ..action = ResolveReportDtoActionEnum.valueOf('NONE');

  @BuiltValueSerializer(custom: true)
  static Serializer<ResolveReportDto> get serializer => _$ResolveReportDtoSerializer();
}

class _$ResolveReportDtoSerializer implements PrimitiveSerializer<ResolveReportDto> {
  @override
  final Iterable<Type> types = const [ResolveReportDto, _$ResolveReportDto];

  @override
  final String wireName = r'ResolveReportDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResolveReportDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'outcome';
    yield serializers.serialize(
      object.outcome,
      specifiedType: const FullType(ResolveReportDtoOutcomeEnum),
    );
    yield r'note';
    yield serializers.serialize(
      object.note,
      specifiedType: const FullType(String),
    );
    if (object.action != null) {
      yield r'action';
      yield serializers.serialize(
        object.action,
        specifiedType: const FullType(ResolveReportDtoActionEnum),
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
    ResolveReportDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ResolveReportDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'outcome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResolveReportDtoOutcomeEnum),
          ) as ResolveReportDtoOutcomeEnum;
          result.outcome = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResolveReportDtoActionEnum),
          ) as ResolveReportDtoActionEnum;
          result.action = valueDes;
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
  ResolveReportDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResolveReportDtoBuilder();
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

class ResolveReportDtoOutcomeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'RESOLVED')
  static const ResolveReportDtoOutcomeEnum RESOLVED = _$resolveReportDtoOutcomeEnum_RESOLVED;
  @BuiltValueEnumConst(wireName: r'DISMISSED')
  static const ResolveReportDtoOutcomeEnum DISMISSED = _$resolveReportDtoOutcomeEnum_DISMISSED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ResolveReportDtoOutcomeEnum unknownDefaultOpenApi = _$resolveReportDtoOutcomeEnum_unknownDefaultOpenApi;

  static Serializer<ResolveReportDtoOutcomeEnum> get serializer => _$resolveReportDtoOutcomeEnumSerializer;

  const ResolveReportDtoOutcomeEnum._(String name): super(name);

  static BuiltSet<ResolveReportDtoOutcomeEnum> get values => _$resolveReportDtoOutcomeEnumValues;
  static ResolveReportDtoOutcomeEnum valueOf(String name) => _$resolveReportDtoOutcomeEnumValueOf(name);
}

class ResolveReportDtoActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'NONE')
  static const ResolveReportDtoActionEnum NONE = _$resolveReportDtoActionEnum_NONE;
  @BuiltValueEnumConst(wireName: r'HIDE_CONTENT')
  static const ResolveReportDtoActionEnum HIDE_CONTENT = _$resolveReportDtoActionEnum_HIDE_CONTENT;
  @BuiltValueEnumConst(wireName: r'SUSPEND_USER')
  static const ResolveReportDtoActionEnum SUSPEND_USER = _$resolveReportDtoActionEnum_SUSPEND_USER;
  @BuiltValueEnumConst(wireName: r'BAN_USER')
  static const ResolveReportDtoActionEnum BAN_USER = _$resolveReportDtoActionEnum_BAN_USER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ResolveReportDtoActionEnum unknownDefaultOpenApi = _$resolveReportDtoActionEnum_unknownDefaultOpenApi;

  static Serializer<ResolveReportDtoActionEnum> get serializer => _$resolveReportDtoActionEnumSerializer;

  const ResolveReportDtoActionEnum._(String name): super(name);

  static BuiltSet<ResolveReportDtoActionEnum> get values => _$resolveReportDtoActionEnumValues;
  static ResolveReportDtoActionEnum valueOf(String name) => _$resolveReportDtoActionEnumValueOf(name);
}
