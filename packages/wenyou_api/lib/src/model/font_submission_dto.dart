//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_job_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_submission_dto.g.dart';

/// FontSubmissionDto
///
/// Properties:
/// * [submissionId]
/// * [familyId]
/// * [familyRevision] - 当前家族修订；首次源上传使用此值。已绑定源的重放不重新校验旧修订。
/// * [name]
/// * [language]
/// * [sortOrder]
/// * [authorizationRuleVersion] - 上传即确认分发、转码和分片；服务端记录实际上传者、时间及源 SHA，不能替代字体原始许可。
/// * [job] - null 表示尚未完成源绑定；非 null 时无需重传，直接恢复查询/处理。
/// * [createdAt]
/// * [updatedAt]
@BuiltValue()
abstract class FontSubmissionDto implements Built<FontSubmissionDto, FontSubmissionDtoBuilder> {
  @BuiltValueField(wireName: r'submissionId')
  String get submissionId;

  @BuiltValueField(wireName: r'familyId')
  String get familyId;

  /// 当前家族修订；首次源上传使用此值。已绑定源的重放不重新校验旧修订。
  @BuiltValueField(wireName: r'familyRevision')
  int get familyRevision;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'language')
  FontSubmissionDtoLanguageEnum get language;
  // enum languageEnum {  zh,  ja,  en,  other,  };

  @BuiltValueField(wireName: r'sortOrder')
  int get sortOrder;

  /// 上传即确认分发、转码和分片；服务端记录实际上传者、时间及源 SHA，不能替代字体原始许可。
  @BuiltValueField(wireName: r'authorizationRuleVersion')
  FontSubmissionDtoAuthorizationRuleVersionEnum get authorizationRuleVersion;
  // enum authorizationRuleVersionEnum {  admin-font-upload-v1,  };

  /// null 表示尚未完成源绑定；非 null 时无需重传，直接恢复查询/处理。
  @BuiltValueField(wireName: r'job')
  FontJobDto? get job;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  FontSubmissionDto._();

  factory FontSubmissionDto([void updates(FontSubmissionDtoBuilder b)]) = _$FontSubmissionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontSubmissionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontSubmissionDto> get serializer => _$FontSubmissionDtoSerializer();
}

class _$FontSubmissionDtoSerializer implements PrimitiveSerializer<FontSubmissionDto> {
  @override
  final Iterable<Type> types = const [FontSubmissionDto, _$FontSubmissionDto];

  @override
  final String wireName = r'FontSubmissionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontSubmissionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'submissionId';
    yield serializers.serialize(
      object.submissionId,
      specifiedType: const FullType(String),
    );
    yield r'familyId';
    yield serializers.serialize(
      object.familyId,
      specifiedType: const FullType(String),
    );
    yield r'familyRevision';
    yield serializers.serialize(
      object.familyRevision,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'language';
    yield serializers.serialize(
      object.language,
      specifiedType: const FullType(FontSubmissionDtoLanguageEnum),
    );
    yield r'sortOrder';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(int),
    );
    yield r'authorizationRuleVersion';
    yield serializers.serialize(
      object.authorizationRuleVersion,
      specifiedType: const FullType(FontSubmissionDtoAuthorizationRuleVersionEnum),
    );
    yield r'job';
    yield object.job == null ? null : serializers.serialize(
      object.job,
      specifiedType: const FullType.nullable(FontJobDto),
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
    FontSubmissionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontSubmissionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'submissionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.submissionId = valueDes;
          break;
        case r'familyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.familyId = valueDes;
          break;
        case r'familyRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.familyRevision = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'language':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontSubmissionDtoLanguageEnum),
          ) as FontSubmissionDtoLanguageEnum;
          result.language = valueDes;
          break;
        case r'sortOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sortOrder = valueDes;
          break;
        case r'authorizationRuleVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontSubmissionDtoAuthorizationRuleVersionEnum),
          ) as FontSubmissionDtoAuthorizationRuleVersionEnum;
          result.authorizationRuleVersion = valueDes;
          break;
        case r'job':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(FontJobDto),
          ) as FontJobDto?;
          if (valueDes == null) continue;
          result.job.replace(valueDes);
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
  FontSubmissionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontSubmissionDtoBuilder();
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

class FontSubmissionDtoLanguageEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'zh')
  static const FontSubmissionDtoLanguageEnum zh = _$fontSubmissionDtoLanguageEnum_zh;
  @BuiltValueEnumConst(wireName: r'ja')
  static const FontSubmissionDtoLanguageEnum ja = _$fontSubmissionDtoLanguageEnum_ja;
  @BuiltValueEnumConst(wireName: r'en')
  static const FontSubmissionDtoLanguageEnum en = _$fontSubmissionDtoLanguageEnum_en;
  @BuiltValueEnumConst(wireName: r'other')
  static const FontSubmissionDtoLanguageEnum other = _$fontSubmissionDtoLanguageEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontSubmissionDtoLanguageEnum unknownDefaultOpenApi = _$fontSubmissionDtoLanguageEnum_unknownDefaultOpenApi;

  static Serializer<FontSubmissionDtoLanguageEnum> get serializer => _$fontSubmissionDtoLanguageEnumSerializer;

  const FontSubmissionDtoLanguageEnum._(String name): super(name);

  static BuiltSet<FontSubmissionDtoLanguageEnum> get values => _$fontSubmissionDtoLanguageEnumValues;
  static FontSubmissionDtoLanguageEnum valueOf(String name) => _$fontSubmissionDtoLanguageEnumValueOf(name);
}

class FontSubmissionDtoAuthorizationRuleVersionEnum extends EnumClass {

  /// 上传即确认分发、转码和分片；服务端记录实际上传者、时间及源 SHA，不能替代字体原始许可。
  @BuiltValueEnumConst(wireName: r'admin-font-upload-v1')
  static const FontSubmissionDtoAuthorizationRuleVersionEnum adminFontUploadV1 = _$fontSubmissionDtoAuthorizationRuleVersionEnum_adminFontUploadV1;
  /// 上传即确认分发、转码和分片；服务端记录实际上传者、时间及源 SHA，不能替代字体原始许可。
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontSubmissionDtoAuthorizationRuleVersionEnum unknownDefaultOpenApi = _$fontSubmissionDtoAuthorizationRuleVersionEnum_unknownDefaultOpenApi;

  static Serializer<FontSubmissionDtoAuthorizationRuleVersionEnum> get serializer => _$fontSubmissionDtoAuthorizationRuleVersionEnumSerializer;

  const FontSubmissionDtoAuthorizationRuleVersionEnum._(String name): super(name);

  static BuiltSet<FontSubmissionDtoAuthorizationRuleVersionEnum> get values => _$fontSubmissionDtoAuthorizationRuleVersionEnumValues;
  static FontSubmissionDtoAuthorizationRuleVersionEnum valueOf(String name) => _$fontSubmissionDtoAuthorizationRuleVersionEnumValueOf(name);
}
