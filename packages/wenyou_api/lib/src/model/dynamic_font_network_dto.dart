//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dynamic_font_network_dto.g.dart';

/// DynamicFontNetworkDto
///
/// Properties:
/// * [windowMs]
/// * [maxRequests]
/// * [maxBytes]
/// * [maxConcurrent]
/// * [timeoutMode]
/// * [timeoutMs]
/// * [maxTransferMs]
@BuiltValue()
abstract class DynamicFontNetworkDto implements Built<DynamicFontNetworkDto, DynamicFontNetworkDtoBuilder> {
  @BuiltValueField(wireName: r'windowMs')
  DynamicFontNetworkDtoWindowMsEnum get windowMs;
  // enum windowMsEnum {  60000,  };

  @BuiltValueField(wireName: r'maxRequests')
  int get maxRequests;

  @BuiltValueField(wireName: r'maxBytes')
  int get maxBytes;

  @BuiltValueField(wireName: r'maxConcurrent')
  int get maxConcurrent;

  @BuiltValueField(wireName: r'timeoutMode')
  DynamicFontNetworkDtoTimeoutModeEnum get timeoutMode;
  // enum timeoutModeEnum {  idle-with-total-cap,  };

  @BuiltValueField(wireName: r'timeoutMs')
  DynamicFontNetworkDtoTimeoutMsEnum get timeoutMs;
  // enum timeoutMsEnum {  15000,  };

  @BuiltValueField(wireName: r'maxTransferMs')
  DynamicFontNetworkDtoMaxTransferMsEnum get maxTransferMs;
  // enum maxTransferMsEnum {  600000,  };

  DynamicFontNetworkDto._();

  factory DynamicFontNetworkDto([void updates(DynamicFontNetworkDtoBuilder b)]) = _$DynamicFontNetworkDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DynamicFontNetworkDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DynamicFontNetworkDto> get serializer => _$DynamicFontNetworkDtoSerializer();
}

class _$DynamicFontNetworkDtoSerializer implements PrimitiveSerializer<DynamicFontNetworkDto> {
  @override
  final Iterable<Type> types = const [DynamicFontNetworkDto, _$DynamicFontNetworkDto];

  @override
  final String wireName = r'DynamicFontNetworkDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DynamicFontNetworkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'windowMs';
    yield serializers.serialize(
      object.windowMs,
      specifiedType: const FullType(DynamicFontNetworkDtoWindowMsEnum),
    );
    yield r'maxRequests';
    yield serializers.serialize(
      object.maxRequests,
      specifiedType: const FullType(int),
    );
    yield r'maxBytes';
    yield serializers.serialize(
      object.maxBytes,
      specifiedType: const FullType(int),
    );
    yield r'maxConcurrent';
    yield serializers.serialize(
      object.maxConcurrent,
      specifiedType: const FullType(int),
    );
    yield r'timeoutMode';
    yield serializers.serialize(
      object.timeoutMode,
      specifiedType: const FullType(DynamicFontNetworkDtoTimeoutModeEnum),
    );
    yield r'timeoutMs';
    yield serializers.serialize(
      object.timeoutMs,
      specifiedType: const FullType(DynamicFontNetworkDtoTimeoutMsEnum),
    );
    yield r'maxTransferMs';
    yield serializers.serialize(
      object.maxTransferMs,
      specifiedType: const FullType(DynamicFontNetworkDtoMaxTransferMsEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DynamicFontNetworkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DynamicFontNetworkDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'windowMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontNetworkDtoWindowMsEnum),
          ) as DynamicFontNetworkDtoWindowMsEnum;
          result.windowMs = valueDes;
          break;
        case r'maxRequests':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maxRequests = valueDes;
          break;
        case r'maxBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maxBytes = valueDes;
          break;
        case r'maxConcurrent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maxConcurrent = valueDes;
          break;
        case r'timeoutMode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontNetworkDtoTimeoutModeEnum),
          ) as DynamicFontNetworkDtoTimeoutModeEnum;
          result.timeoutMode = valueDes;
          break;
        case r'timeoutMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontNetworkDtoTimeoutMsEnum),
          ) as DynamicFontNetworkDtoTimeoutMsEnum;
          result.timeoutMs = valueDes;
          break;
        case r'maxTransferMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontNetworkDtoMaxTransferMsEnum),
          ) as DynamicFontNetworkDtoMaxTransferMsEnum;
          result.maxTransferMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DynamicFontNetworkDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DynamicFontNetworkDtoBuilder();
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

class DynamicFontNetworkDtoWindowMsEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'60000')
  static const DynamicFontNetworkDtoWindowMsEnum n60000 = _$dynamicFontNetworkDtoWindowMsEnum_n60000;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const DynamicFontNetworkDtoWindowMsEnum unknownDefaultOpenApi = _$dynamicFontNetworkDtoWindowMsEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontNetworkDtoWindowMsEnum> get serializer => _$dynamicFontNetworkDtoWindowMsEnumSerializer;

  const DynamicFontNetworkDtoWindowMsEnum._(String name): super(name);

  static BuiltSet<DynamicFontNetworkDtoWindowMsEnum> get values => _$dynamicFontNetworkDtoWindowMsEnumValues;
  static DynamicFontNetworkDtoWindowMsEnum valueOf(String name) => _$dynamicFontNetworkDtoWindowMsEnumValueOf(name);
}

class DynamicFontNetworkDtoTimeoutModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'idle-with-total-cap')
  static const DynamicFontNetworkDtoTimeoutModeEnum idleWithTotalCap = _$dynamicFontNetworkDtoTimeoutModeEnum_idleWithTotalCap;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DynamicFontNetworkDtoTimeoutModeEnum unknownDefaultOpenApi = _$dynamicFontNetworkDtoTimeoutModeEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontNetworkDtoTimeoutModeEnum> get serializer => _$dynamicFontNetworkDtoTimeoutModeEnumSerializer;

  const DynamicFontNetworkDtoTimeoutModeEnum._(String name): super(name);

  static BuiltSet<DynamicFontNetworkDtoTimeoutModeEnum> get values => _$dynamicFontNetworkDtoTimeoutModeEnumValues;
  static DynamicFontNetworkDtoTimeoutModeEnum valueOf(String name) => _$dynamicFontNetworkDtoTimeoutModeEnumValueOf(name);
}

class DynamicFontNetworkDtoTimeoutMsEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'15000')
  static const DynamicFontNetworkDtoTimeoutMsEnum n15000 = _$dynamicFontNetworkDtoTimeoutMsEnum_n15000;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const DynamicFontNetworkDtoTimeoutMsEnum unknownDefaultOpenApi = _$dynamicFontNetworkDtoTimeoutMsEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontNetworkDtoTimeoutMsEnum> get serializer => _$dynamicFontNetworkDtoTimeoutMsEnumSerializer;

  const DynamicFontNetworkDtoTimeoutMsEnum._(String name): super(name);

  static BuiltSet<DynamicFontNetworkDtoTimeoutMsEnum> get values => _$dynamicFontNetworkDtoTimeoutMsEnumValues;
  static DynamicFontNetworkDtoTimeoutMsEnum valueOf(String name) => _$dynamicFontNetworkDtoTimeoutMsEnumValueOf(name);
}

class DynamicFontNetworkDtoMaxTransferMsEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'600000')
  static const DynamicFontNetworkDtoMaxTransferMsEnum n600000 = _$dynamicFontNetworkDtoMaxTransferMsEnum_n600000;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const DynamicFontNetworkDtoMaxTransferMsEnum unknownDefaultOpenApi = _$dynamicFontNetworkDtoMaxTransferMsEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontNetworkDtoMaxTransferMsEnum> get serializer => _$dynamicFontNetworkDtoMaxTransferMsEnumSerializer;

  const DynamicFontNetworkDtoMaxTransferMsEnum._(String name): super(name);

  static BuiltSet<DynamicFontNetworkDtoMaxTransferMsEnum> get values => _$dynamicFontNetworkDtoMaxTransferMsEnumValues;
  static DynamicFontNetworkDtoMaxTransferMsEnum valueOf(String name) => _$dynamicFontNetworkDtoMaxTransferMsEnumValueOf(name);
}
