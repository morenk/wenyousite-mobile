//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_font_submission_dto.g.dart';

/// CreateFontSubmissionDto
///
/// Properties:
/// * [submissionId] - 客户端为一次提交生成并持久化 UUID v4；超时、刷新和并发重试复用。
/// * [name]
/// * [language]
/// * [familyId] - 为已有家族上传新版时提供；须同时提供 expectedFamilyRevision。
/// * [expectedFamilyRevision]
@BuiltValue()
abstract class CreateFontSubmissionDto implements Built<CreateFontSubmissionDto, CreateFontSubmissionDtoBuilder> {
  /// 客户端为一次提交生成并持久化 UUID v4；超时、刷新和并发重试复用。
  @BuiltValueField(wireName: r'submissionId')
  String get submissionId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'language')
  CreateFontSubmissionDtoLanguageEnum? get language;
  // enum languageEnum {  zh,  ja,  en,  other,  };

  /// 为已有家族上传新版时提供；须同时提供 expectedFamilyRevision。
  @BuiltValueField(wireName: r'familyId')
  String? get familyId;

  @BuiltValueField(wireName: r'expectedFamilyRevision')
  int? get expectedFamilyRevision;

  CreateFontSubmissionDto._();

  factory CreateFontSubmissionDto([void updates(CreateFontSubmissionDtoBuilder b)]) = _$CreateFontSubmissionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateFontSubmissionDtoBuilder b) => b
      ..language = CreateFontSubmissionDtoLanguageEnum.valueOf('other');

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateFontSubmissionDto> get serializer => _$CreateFontSubmissionDtoSerializer();
}

class _$CreateFontSubmissionDtoSerializer implements PrimitiveSerializer<CreateFontSubmissionDto> {
  @override
  final Iterable<Type> types = const [CreateFontSubmissionDto, _$CreateFontSubmissionDto];

  @override
  final String wireName = r'CreateFontSubmissionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateFontSubmissionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'submissionId';
    yield serializers.serialize(
      object.submissionId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.language != null) {
      yield r'language';
      yield serializers.serialize(
        object.language,
        specifiedType: const FullType(CreateFontSubmissionDtoLanguageEnum),
      );
    }
    if (object.familyId != null) {
      yield r'familyId';
      yield serializers.serialize(
        object.familyId,
        specifiedType: const FullType(String),
      );
    }
    if (object.expectedFamilyRevision != null) {
      yield r'expectedFamilyRevision';
      yield serializers.serialize(
        object.expectedFamilyRevision,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateFontSubmissionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateFontSubmissionDtoBuilder result,
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
            specifiedType: const FullType(CreateFontSubmissionDtoLanguageEnum),
          ) as CreateFontSubmissionDtoLanguageEnum;
          result.language = valueDes;
          break;
        case r'familyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.familyId = valueDes;
          break;
        case r'expectedFamilyRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedFamilyRevision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateFontSubmissionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateFontSubmissionDtoBuilder();
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

class CreateFontSubmissionDtoLanguageEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'zh')
  static const CreateFontSubmissionDtoLanguageEnum zh = _$createFontSubmissionDtoLanguageEnum_zh;
  @BuiltValueEnumConst(wireName: r'ja')
  static const CreateFontSubmissionDtoLanguageEnum ja = _$createFontSubmissionDtoLanguageEnum_ja;
  @BuiltValueEnumConst(wireName: r'en')
  static const CreateFontSubmissionDtoLanguageEnum en = _$createFontSubmissionDtoLanguageEnum_en;
  @BuiltValueEnumConst(wireName: r'other')
  static const CreateFontSubmissionDtoLanguageEnum other = _$createFontSubmissionDtoLanguageEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateFontSubmissionDtoLanguageEnum unknownDefaultOpenApi = _$createFontSubmissionDtoLanguageEnum_unknownDefaultOpenApi;

  static Serializer<CreateFontSubmissionDtoLanguageEnum> get serializer => _$createFontSubmissionDtoLanguageEnumSerializer;

  const CreateFontSubmissionDtoLanguageEnum._(String name): super(name);

  static BuiltSet<CreateFontSubmissionDtoLanguageEnum> get values => _$createFontSubmissionDtoLanguageEnumValues;
  static CreateFontSubmissionDtoLanguageEnum valueOf(String name) => _$createFontSubmissionDtoLanguageEnumValueOf(name);
}
