//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dynamic_font_registration_dto.g.dart';

/// DynamicFontRegistrationDto
///
/// Properties:
/// * [mode]
/// * [scope]
/// * [key]
/// * [maxAttemptsPerKey]
/// * [failedAttempt]
/// * [maxKeys]
/// * [maxInputBytes] - 含失败尝试的累计输入 SFNT 字节；不是 RSS。客户端只接受收紧，不能扩大或随目录更新清账。
@BuiltValue()
abstract class DynamicFontRegistrationDto implements Built<DynamicFontRegistrationDto, DynamicFontRegistrationDtoBuilder> {
  @BuiltValueField(wireName: r'mode')
  DynamicFontRegistrationDtoModeEnum get mode;
  // enum modeEnum {  append-only,  };

  @BuiltValueField(wireName: r'scope')
  DynamicFontRegistrationDtoScopeEnum get scope;
  // enum scopeEnum {  engine,  };

  @BuiltValueField(wireName: r'key')
  DynamicFontRegistrationDtoKeyEnum get key;
  // enum keyEnum {  asset-sha256-and-family,  };

  @BuiltValueField(wireName: r'maxAttemptsPerKey')
  DynamicFontRegistrationDtoMaxAttemptsPerKeyEnum get maxAttemptsPerKey;
  // enum maxAttemptsPerKeyEnum {  1,  };

  @BuiltValueField(wireName: r'failedAttempt')
  DynamicFontRegistrationDtoFailedAttemptEnum get failedAttempt;
  // enum failedAttemptEnum {  quarantine-and-retain-charge,  };

  @BuiltValueField(wireName: r'maxKeys')
  int get maxKeys;

  /// 含失败尝试的累计输入 SFNT 字节；不是 RSS。客户端只接受收紧，不能扩大或随目录更新清账。
  @BuiltValueField(wireName: r'maxInputBytes')
  int get maxInputBytes;

  DynamicFontRegistrationDto._();

  factory DynamicFontRegistrationDto([void updates(DynamicFontRegistrationDtoBuilder b)]) = _$DynamicFontRegistrationDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DynamicFontRegistrationDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DynamicFontRegistrationDto> get serializer => _$DynamicFontRegistrationDtoSerializer();
}

class _$DynamicFontRegistrationDtoSerializer implements PrimitiveSerializer<DynamicFontRegistrationDto> {
  @override
  final Iterable<Type> types = const [DynamicFontRegistrationDto, _$DynamicFontRegistrationDto];

  @override
  final String wireName = r'DynamicFontRegistrationDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DynamicFontRegistrationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mode';
    yield serializers.serialize(
      object.mode,
      specifiedType: const FullType(DynamicFontRegistrationDtoModeEnum),
    );
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType: const FullType(DynamicFontRegistrationDtoScopeEnum),
    );
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(DynamicFontRegistrationDtoKeyEnum),
    );
    yield r'maxAttemptsPerKey';
    yield serializers.serialize(
      object.maxAttemptsPerKey,
      specifiedType: const FullType(DynamicFontRegistrationDtoMaxAttemptsPerKeyEnum),
    );
    yield r'failedAttempt';
    yield serializers.serialize(
      object.failedAttempt,
      specifiedType: const FullType(DynamicFontRegistrationDtoFailedAttemptEnum),
    );
    yield r'maxKeys';
    yield serializers.serialize(
      object.maxKeys,
      specifiedType: const FullType(int),
    );
    yield r'maxInputBytes';
    yield serializers.serialize(
      object.maxInputBytes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DynamicFontRegistrationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DynamicFontRegistrationDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontRegistrationDtoModeEnum),
          ) as DynamicFontRegistrationDtoModeEnum;
          result.mode = valueDes;
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontRegistrationDtoScopeEnum),
          ) as DynamicFontRegistrationDtoScopeEnum;
          result.scope = valueDes;
          break;
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontRegistrationDtoKeyEnum),
          ) as DynamicFontRegistrationDtoKeyEnum;
          result.key = valueDes;
          break;
        case r'maxAttemptsPerKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontRegistrationDtoMaxAttemptsPerKeyEnum),
          ) as DynamicFontRegistrationDtoMaxAttemptsPerKeyEnum;
          result.maxAttemptsPerKey = valueDes;
          break;
        case r'failedAttempt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontRegistrationDtoFailedAttemptEnum),
          ) as DynamicFontRegistrationDtoFailedAttemptEnum;
          result.failedAttempt = valueDes;
          break;
        case r'maxKeys':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maxKeys = valueDes;
          break;
        case r'maxInputBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maxInputBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DynamicFontRegistrationDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DynamicFontRegistrationDtoBuilder();
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

class DynamicFontRegistrationDtoModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'append-only')
  static const DynamicFontRegistrationDtoModeEnum appendOnly = _$dynamicFontRegistrationDtoModeEnum_appendOnly;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DynamicFontRegistrationDtoModeEnum unknownDefaultOpenApi = _$dynamicFontRegistrationDtoModeEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontRegistrationDtoModeEnum> get serializer => _$dynamicFontRegistrationDtoModeEnumSerializer;

  const DynamicFontRegistrationDtoModeEnum._(String name): super(name);

  static BuiltSet<DynamicFontRegistrationDtoModeEnum> get values => _$dynamicFontRegistrationDtoModeEnumValues;
  static DynamicFontRegistrationDtoModeEnum valueOf(String name) => _$dynamicFontRegistrationDtoModeEnumValueOf(name);
}

class DynamicFontRegistrationDtoScopeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'engine')
  static const DynamicFontRegistrationDtoScopeEnum engine = _$dynamicFontRegistrationDtoScopeEnum_engine;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DynamicFontRegistrationDtoScopeEnum unknownDefaultOpenApi = _$dynamicFontRegistrationDtoScopeEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontRegistrationDtoScopeEnum> get serializer => _$dynamicFontRegistrationDtoScopeEnumSerializer;

  const DynamicFontRegistrationDtoScopeEnum._(String name): super(name);

  static BuiltSet<DynamicFontRegistrationDtoScopeEnum> get values => _$dynamicFontRegistrationDtoScopeEnumValues;
  static DynamicFontRegistrationDtoScopeEnum valueOf(String name) => _$dynamicFontRegistrationDtoScopeEnumValueOf(name);
}

class DynamicFontRegistrationDtoKeyEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'asset-sha256-and-family')
  static const DynamicFontRegistrationDtoKeyEnum assetSha256AndFamily = _$dynamicFontRegistrationDtoKeyEnum_assetSha256AndFamily;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DynamicFontRegistrationDtoKeyEnum unknownDefaultOpenApi = _$dynamicFontRegistrationDtoKeyEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontRegistrationDtoKeyEnum> get serializer => _$dynamicFontRegistrationDtoKeyEnumSerializer;

  const DynamicFontRegistrationDtoKeyEnum._(String name): super(name);

  static BuiltSet<DynamicFontRegistrationDtoKeyEnum> get values => _$dynamicFontRegistrationDtoKeyEnumValues;
  static DynamicFontRegistrationDtoKeyEnum valueOf(String name) => _$dynamicFontRegistrationDtoKeyEnumValueOf(name);
}

class DynamicFontRegistrationDtoMaxAttemptsPerKeyEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'1')
  static const DynamicFontRegistrationDtoMaxAttemptsPerKeyEnum n1 = _$dynamicFontRegistrationDtoMaxAttemptsPerKeyEnum_n1;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const DynamicFontRegistrationDtoMaxAttemptsPerKeyEnum unknownDefaultOpenApi = _$dynamicFontRegistrationDtoMaxAttemptsPerKeyEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontRegistrationDtoMaxAttemptsPerKeyEnum> get serializer => _$dynamicFontRegistrationDtoMaxAttemptsPerKeyEnumSerializer;

  const DynamicFontRegistrationDtoMaxAttemptsPerKeyEnum._(String name): super(name);

  static BuiltSet<DynamicFontRegistrationDtoMaxAttemptsPerKeyEnum> get values => _$dynamicFontRegistrationDtoMaxAttemptsPerKeyEnumValues;
  static DynamicFontRegistrationDtoMaxAttemptsPerKeyEnum valueOf(String name) => _$dynamicFontRegistrationDtoMaxAttemptsPerKeyEnumValueOf(name);
}

class DynamicFontRegistrationDtoFailedAttemptEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'quarantine-and-retain-charge')
  static const DynamicFontRegistrationDtoFailedAttemptEnum quarantineAndRetainCharge = _$dynamicFontRegistrationDtoFailedAttemptEnum_quarantineAndRetainCharge;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DynamicFontRegistrationDtoFailedAttemptEnum unknownDefaultOpenApi = _$dynamicFontRegistrationDtoFailedAttemptEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontRegistrationDtoFailedAttemptEnum> get serializer => _$dynamicFontRegistrationDtoFailedAttemptEnumSerializer;

  const DynamicFontRegistrationDtoFailedAttemptEnum._(String name): super(name);

  static BuiltSet<DynamicFontRegistrationDtoFailedAttemptEnum> get values => _$dynamicFontRegistrationDtoFailedAttemptEnumValues;
  static DynamicFontRegistrationDtoFailedAttemptEnum valueOf(String name) => _$dynamicFontRegistrationDtoFailedAttemptEnumValueOf(name);
}
