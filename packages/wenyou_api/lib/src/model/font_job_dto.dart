//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_job_dto.g.dart';

/// FontJobDto
///
/// Properties:
/// * [jobId]
/// * [familyId]
/// * [status]
/// * [sourceSha256]
/// * [sourceBytes]
/// * [versionId]
/// * [failureCode]
@BuiltValue()
abstract class FontJobDto implements Built<FontJobDto, FontJobDtoBuilder> {
  @BuiltValueField(wireName: r'jobId')
  String get jobId;

  @BuiltValueField(wireName: r'familyId')
  String get familyId;

  @BuiltValueField(wireName: r'status')
  FontJobDtoStatusEnum get status;
  // enum statusEnum {  draft,  queued,  processing,  ready,  failed,  };

  @BuiltValueField(wireName: r'sourceSha256')
  String get sourceSha256;

  @BuiltValueField(wireName: r'sourceBytes')
  int get sourceBytes;

  @BuiltValueField(wireName: r'versionId')
  String? get versionId;

  @BuiltValueField(wireName: r'failureCode')
  FontJobDtoFailureCodeEnum? get failureCode;
  // enum failureCodeEnum {  invalid-font,  unsupported-font,  rights-required,  resource-limit,  sandbox-unavailable,  processing-failed,  };

  FontJobDto._();

  factory FontJobDto([void updates(FontJobDtoBuilder b)]) = _$FontJobDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontJobDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontJobDto> get serializer => _$FontJobDtoSerializer();
}

class _$FontJobDtoSerializer implements PrimitiveSerializer<FontJobDto> {
  @override
  final Iterable<Type> types = const [FontJobDto, _$FontJobDto];

  @override
  final String wireName = r'FontJobDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontJobDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'jobId';
    yield serializers.serialize(
      object.jobId,
      specifiedType: const FullType(String),
    );
    yield r'familyId';
    yield serializers.serialize(
      object.familyId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(FontJobDtoStatusEnum),
    );
    yield r'sourceSha256';
    yield serializers.serialize(
      object.sourceSha256,
      specifiedType: const FullType(String),
    );
    yield r'sourceBytes';
    yield serializers.serialize(
      object.sourceBytes,
      specifiedType: const FullType(int),
    );
    yield r'versionId';
    yield object.versionId == null ? null : serializers.serialize(
      object.versionId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'failureCode';
    yield object.failureCode == null ? null : serializers.serialize(
      object.failureCode,
      specifiedType: const FullType.nullable(FontJobDtoFailureCodeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontJobDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontJobDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'jobId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.jobId = valueDes;
          break;
        case r'familyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.familyId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontJobDtoStatusEnum),
          ) as FontJobDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'sourceSha256':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceSha256 = valueDes;
          break;
        case r'sourceBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sourceBytes = valueDes;
          break;
        case r'versionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.versionId = valueDes;
          break;
        case r'failureCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(FontJobDtoFailureCodeEnum),
          ) as FontJobDtoFailureCodeEnum?;
          if (valueDes == null) continue;
          result.failureCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontJobDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontJobDtoBuilder();
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

class FontJobDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'draft')
  static const FontJobDtoStatusEnum draft = _$fontJobDtoStatusEnum_draft;
  @BuiltValueEnumConst(wireName: r'queued')
  static const FontJobDtoStatusEnum queued = _$fontJobDtoStatusEnum_queued;
  @BuiltValueEnumConst(wireName: r'processing')
  static const FontJobDtoStatusEnum processing = _$fontJobDtoStatusEnum_processing;
  @BuiltValueEnumConst(wireName: r'ready')
  static const FontJobDtoStatusEnum ready = _$fontJobDtoStatusEnum_ready;
  @BuiltValueEnumConst(wireName: r'failed')
  static const FontJobDtoStatusEnum failed = _$fontJobDtoStatusEnum_failed;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontJobDtoStatusEnum unknownDefaultOpenApi = _$fontJobDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<FontJobDtoStatusEnum> get serializer => _$fontJobDtoStatusEnumSerializer;

  const FontJobDtoStatusEnum._(String name): super(name);

  static BuiltSet<FontJobDtoStatusEnum> get values => _$fontJobDtoStatusEnumValues;
  static FontJobDtoStatusEnum valueOf(String name) => _$fontJobDtoStatusEnumValueOf(name);
}

class FontJobDtoFailureCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'invalid-font')
  static const FontJobDtoFailureCodeEnum invalidFont = _$fontJobDtoFailureCodeEnum_invalidFont;
  @BuiltValueEnumConst(wireName: r'unsupported-font')
  static const FontJobDtoFailureCodeEnum unsupportedFont = _$fontJobDtoFailureCodeEnum_unsupportedFont;
  @BuiltValueEnumConst(wireName: r'rights-required')
  static const FontJobDtoFailureCodeEnum rightsRequired = _$fontJobDtoFailureCodeEnum_rightsRequired;
  @BuiltValueEnumConst(wireName: r'resource-limit')
  static const FontJobDtoFailureCodeEnum resourceLimit = _$fontJobDtoFailureCodeEnum_resourceLimit;
  @BuiltValueEnumConst(wireName: r'sandbox-unavailable')
  static const FontJobDtoFailureCodeEnum sandboxUnavailable = _$fontJobDtoFailureCodeEnum_sandboxUnavailable;
  @BuiltValueEnumConst(wireName: r'processing-failed')
  static const FontJobDtoFailureCodeEnum processingFailed = _$fontJobDtoFailureCodeEnum_processingFailed;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontJobDtoFailureCodeEnum unknownDefaultOpenApi = _$fontJobDtoFailureCodeEnum_unknownDefaultOpenApi;

  static Serializer<FontJobDtoFailureCodeEnum> get serializer => _$fontJobDtoFailureCodeEnumSerializer;

  const FontJobDtoFailureCodeEnum._(String name): super(name);

  static BuiltSet<FontJobDtoFailureCodeEnum> get values => _$fontJobDtoFailureCodeEnumValues;
  static FontJobDtoFailureCodeEnum valueOf(String name) => _$fontJobDtoFailureCodeEnumValueOf(name);
}
