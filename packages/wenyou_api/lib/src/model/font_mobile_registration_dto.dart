//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_snapshot_safety_ceiling_dto.dart';
import 'package:wenyou_api/src/model/font_registration_snapshot_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_mobile_registration_dto.g.dart';

/// FontMobileRegistrationDto
///
/// Properties:
/// * [mode]
/// * [scope]
/// * [key]
/// * [maxAttemptsPerKey] - 原生调用前登记；同键最多调用一次，下载失败不算原生尝试
/// * [failedAttempt] - 原生失败保留占用和隔离记录，不随重试或目录版本清零
/// * [snapshot]
/// * [safetyCeiling]
@BuiltValue()
abstract class FontMobileRegistrationDto implements Built<FontMobileRegistrationDto, FontMobileRegistrationDtoBuilder> {
  @BuiltValueField(wireName: r'mode')
  FontMobileRegistrationDtoModeEnum get mode;
  // enum modeEnum {  fixed-manifest,  };

  @BuiltValueField(wireName: r'scope')
  FontMobileRegistrationDtoScopeEnum get scope;
  // enum scopeEnum {  engine,  };

  @BuiltValueField(wireName: r'key')
  FontMobileRegistrationDtoKeyEnum get key;
  // enum keyEnum {  asset-sha256-and-family,  };

  /// 原生调用前登记；同键最多调用一次，下载失败不算原生尝试
  @BuiltValueField(wireName: r'maxAttemptsPerKey')
  FontMobileRegistrationDtoMaxAttemptsPerKeyEnum get maxAttemptsPerKey;
  // enum maxAttemptsPerKeyEnum {  1,  };

  /// 原生失败保留占用和隔离记录，不随重试或目录版本清零
  @BuiltValueField(wireName: r'failedAttempt')
  FontMobileRegistrationDtoFailedAttemptEnum get failedAttempt;
  // enum failedAttemptEnum {  quarantine-and-retain-charge,  };

  @BuiltValueField(wireName: r'snapshot')
  FontRegistrationSnapshotDto get snapshot;

  @BuiltValueField(wireName: r'safetyCeiling')
  FontSnapshotSafetyCeilingDto get safetyCeiling;

  FontMobileRegistrationDto._();

  factory FontMobileRegistrationDto([void updates(FontMobileRegistrationDtoBuilder b)]) = _$FontMobileRegistrationDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontMobileRegistrationDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontMobileRegistrationDto> get serializer => _$FontMobileRegistrationDtoSerializer();
}

class _$FontMobileRegistrationDtoSerializer implements PrimitiveSerializer<FontMobileRegistrationDto> {
  @override
  final Iterable<Type> types = const [FontMobileRegistrationDto, _$FontMobileRegistrationDto];

  @override
  final String wireName = r'FontMobileRegistrationDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontMobileRegistrationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mode';
    yield serializers.serialize(
      object.mode,
      specifiedType: const FullType(FontMobileRegistrationDtoModeEnum),
    );
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType: const FullType(FontMobileRegistrationDtoScopeEnum),
    );
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(FontMobileRegistrationDtoKeyEnum),
    );
    yield r'maxAttemptsPerKey';
    yield serializers.serialize(
      object.maxAttemptsPerKey,
      specifiedType: const FullType(FontMobileRegistrationDtoMaxAttemptsPerKeyEnum),
    );
    yield r'failedAttempt';
    yield serializers.serialize(
      object.failedAttempt,
      specifiedType: const FullType(FontMobileRegistrationDtoFailedAttemptEnum),
    );
    yield r'snapshot';
    yield serializers.serialize(
      object.snapshot,
      specifiedType: const FullType(FontRegistrationSnapshotDto),
    );
    yield r'safetyCeiling';
    yield serializers.serialize(
      object.safetyCeiling,
      specifiedType: const FullType(FontSnapshotSafetyCeilingDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontMobileRegistrationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontMobileRegistrationDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontMobileRegistrationDtoModeEnum),
          ) as FontMobileRegistrationDtoModeEnum;
          result.mode = valueDes;
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontMobileRegistrationDtoScopeEnum),
          ) as FontMobileRegistrationDtoScopeEnum;
          result.scope = valueDes;
          break;
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontMobileRegistrationDtoKeyEnum),
          ) as FontMobileRegistrationDtoKeyEnum;
          result.key = valueDes;
          break;
        case r'maxAttemptsPerKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontMobileRegistrationDtoMaxAttemptsPerKeyEnum),
          ) as FontMobileRegistrationDtoMaxAttemptsPerKeyEnum;
          result.maxAttemptsPerKey = valueDes;
          break;
        case r'failedAttempt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontMobileRegistrationDtoFailedAttemptEnum),
          ) as FontMobileRegistrationDtoFailedAttemptEnum;
          result.failedAttempt = valueDes;
          break;
        case r'snapshot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontRegistrationSnapshotDto),
          ) as FontRegistrationSnapshotDto;
          result.snapshot.replace(valueDes);
          break;
        case r'safetyCeiling':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontSnapshotSafetyCeilingDto),
          ) as FontSnapshotSafetyCeilingDto;
          result.safetyCeiling.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontMobileRegistrationDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontMobileRegistrationDtoBuilder();
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

class FontMobileRegistrationDtoModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'fixed-manifest')
  static const FontMobileRegistrationDtoModeEnum fixedManifest = _$fontMobileRegistrationDtoModeEnum_fixedManifest;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontMobileRegistrationDtoModeEnum unknownDefaultOpenApi = _$fontMobileRegistrationDtoModeEnum_unknownDefaultOpenApi;

  static Serializer<FontMobileRegistrationDtoModeEnum> get serializer => _$fontMobileRegistrationDtoModeEnumSerializer;

  const FontMobileRegistrationDtoModeEnum._(String name): super(name);

  static BuiltSet<FontMobileRegistrationDtoModeEnum> get values => _$fontMobileRegistrationDtoModeEnumValues;
  static FontMobileRegistrationDtoModeEnum valueOf(String name) => _$fontMobileRegistrationDtoModeEnumValueOf(name);
}

class FontMobileRegistrationDtoScopeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'engine')
  static const FontMobileRegistrationDtoScopeEnum engine = _$fontMobileRegistrationDtoScopeEnum_engine;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontMobileRegistrationDtoScopeEnum unknownDefaultOpenApi = _$fontMobileRegistrationDtoScopeEnum_unknownDefaultOpenApi;

  static Serializer<FontMobileRegistrationDtoScopeEnum> get serializer => _$fontMobileRegistrationDtoScopeEnumSerializer;

  const FontMobileRegistrationDtoScopeEnum._(String name): super(name);

  static BuiltSet<FontMobileRegistrationDtoScopeEnum> get values => _$fontMobileRegistrationDtoScopeEnumValues;
  static FontMobileRegistrationDtoScopeEnum valueOf(String name) => _$fontMobileRegistrationDtoScopeEnumValueOf(name);
}

class FontMobileRegistrationDtoKeyEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'asset-sha256-and-family')
  static const FontMobileRegistrationDtoKeyEnum assetSha256AndFamily = _$fontMobileRegistrationDtoKeyEnum_assetSha256AndFamily;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontMobileRegistrationDtoKeyEnum unknownDefaultOpenApi = _$fontMobileRegistrationDtoKeyEnum_unknownDefaultOpenApi;

  static Serializer<FontMobileRegistrationDtoKeyEnum> get serializer => _$fontMobileRegistrationDtoKeyEnumSerializer;

  const FontMobileRegistrationDtoKeyEnum._(String name): super(name);

  static BuiltSet<FontMobileRegistrationDtoKeyEnum> get values => _$fontMobileRegistrationDtoKeyEnumValues;
  static FontMobileRegistrationDtoKeyEnum valueOf(String name) => _$fontMobileRegistrationDtoKeyEnumValueOf(name);
}

class FontMobileRegistrationDtoMaxAttemptsPerKeyEnum extends EnumClass {

  /// 原生调用前登记；同键最多调用一次，下载失败不算原生尝试
  @BuiltValueEnumConst(wireName: r'1')
  static const FontMobileRegistrationDtoMaxAttemptsPerKeyEnum n1 = _$fontMobileRegistrationDtoMaxAttemptsPerKeyEnum_n1;
  /// 原生调用前登记；同键最多调用一次，下载失败不算原生尝试
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontMobileRegistrationDtoMaxAttemptsPerKeyEnum unknownDefaultOpenApi = _$fontMobileRegistrationDtoMaxAttemptsPerKeyEnum_unknownDefaultOpenApi;

  static Serializer<FontMobileRegistrationDtoMaxAttemptsPerKeyEnum> get serializer => _$fontMobileRegistrationDtoMaxAttemptsPerKeyEnumSerializer;

  const FontMobileRegistrationDtoMaxAttemptsPerKeyEnum._(String name): super(name);

  static BuiltSet<FontMobileRegistrationDtoMaxAttemptsPerKeyEnum> get values => _$fontMobileRegistrationDtoMaxAttemptsPerKeyEnumValues;
  static FontMobileRegistrationDtoMaxAttemptsPerKeyEnum valueOf(String name) => _$fontMobileRegistrationDtoMaxAttemptsPerKeyEnumValueOf(name);
}

class FontMobileRegistrationDtoFailedAttemptEnum extends EnumClass {

  /// 原生失败保留占用和隔离记录，不随重试或目录版本清零
  @BuiltValueEnumConst(wireName: r'quarantine-and-retain-charge')
  static const FontMobileRegistrationDtoFailedAttemptEnum quarantineAndRetainCharge = _$fontMobileRegistrationDtoFailedAttemptEnum_quarantineAndRetainCharge;
  /// 原生失败保留占用和隔离记录，不随重试或目录版本清零
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontMobileRegistrationDtoFailedAttemptEnum unknownDefaultOpenApi = _$fontMobileRegistrationDtoFailedAttemptEnum_unknownDefaultOpenApi;

  static Serializer<FontMobileRegistrationDtoFailedAttemptEnum> get serializer => _$fontMobileRegistrationDtoFailedAttemptEnumSerializer;

  const FontMobileRegistrationDtoFailedAttemptEnum._(String name): super(name);

  static BuiltSet<FontMobileRegistrationDtoFailedAttemptEnum> get values => _$fontMobileRegistrationDtoFailedAttemptEnumValues;
  static FontMobileRegistrationDtoFailedAttemptEnum valueOf(String name) => _$fontMobileRegistrationDtoFailedAttemptEnumValueOf(name);
}
