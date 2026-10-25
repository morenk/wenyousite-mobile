//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dynamic_font_web_residency_dto.g.dart';

/// DynamicFontWebResidencyDto
///
/// Properties:
/// * [mode]
/// * [scope]
/// * [maxFaces]
/// * [maxSfntBytes]
@BuiltValue()
abstract class DynamicFontWebResidencyDto implements Built<DynamicFontWebResidencyDto, DynamicFontWebResidencyDtoBuilder> {
  @BuiltValueField(wireName: r'mode')
  DynamicFontWebResidencyDtoModeEnum get mode;
  // enum modeEnum {  lease-lru,  };

  @BuiltValueField(wireName: r'scope')
  DynamicFontWebResidencyDtoScopeEnum get scope;
  // enum scopeEnum {  document,  };

  @BuiltValueField(wireName: r'maxFaces')
  int get maxFaces;

  @BuiltValueField(wireName: r'maxSfntBytes')
  int get maxSfntBytes;

  DynamicFontWebResidencyDto._();

  factory DynamicFontWebResidencyDto([void updates(DynamicFontWebResidencyDtoBuilder b)]) = _$DynamicFontWebResidencyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DynamicFontWebResidencyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DynamicFontWebResidencyDto> get serializer => _$DynamicFontWebResidencyDtoSerializer();
}

class _$DynamicFontWebResidencyDtoSerializer implements PrimitiveSerializer<DynamicFontWebResidencyDto> {
  @override
  final Iterable<Type> types = const [DynamicFontWebResidencyDto, _$DynamicFontWebResidencyDto];

  @override
  final String wireName = r'DynamicFontWebResidencyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DynamicFontWebResidencyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mode';
    yield serializers.serialize(
      object.mode,
      specifiedType: const FullType(DynamicFontWebResidencyDtoModeEnum),
    );
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType: const FullType(DynamicFontWebResidencyDtoScopeEnum),
    );
    yield r'maxFaces';
    yield serializers.serialize(
      object.maxFaces,
      specifiedType: const FullType(int),
    );
    yield r'maxSfntBytes';
    yield serializers.serialize(
      object.maxSfntBytes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DynamicFontWebResidencyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DynamicFontWebResidencyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontWebResidencyDtoModeEnum),
          ) as DynamicFontWebResidencyDtoModeEnum;
          result.mode = valueDes;
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontWebResidencyDtoScopeEnum),
          ) as DynamicFontWebResidencyDtoScopeEnum;
          result.scope = valueDes;
          break;
        case r'maxFaces':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maxFaces = valueDes;
          break;
        case r'maxSfntBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maxSfntBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DynamicFontWebResidencyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DynamicFontWebResidencyDtoBuilder();
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

class DynamicFontWebResidencyDtoModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'lease-lru')
  static const DynamicFontWebResidencyDtoModeEnum leaseLru = _$dynamicFontWebResidencyDtoModeEnum_leaseLru;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DynamicFontWebResidencyDtoModeEnum unknownDefaultOpenApi = _$dynamicFontWebResidencyDtoModeEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontWebResidencyDtoModeEnum> get serializer => _$dynamicFontWebResidencyDtoModeEnumSerializer;

  const DynamicFontWebResidencyDtoModeEnum._(String name): super(name);

  static BuiltSet<DynamicFontWebResidencyDtoModeEnum> get values => _$dynamicFontWebResidencyDtoModeEnumValues;
  static DynamicFontWebResidencyDtoModeEnum valueOf(String name) => _$dynamicFontWebResidencyDtoModeEnumValueOf(name);
}

class DynamicFontWebResidencyDtoScopeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'document')
  static const DynamicFontWebResidencyDtoScopeEnum document = _$dynamicFontWebResidencyDtoScopeEnum_document;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DynamicFontWebResidencyDtoScopeEnum unknownDefaultOpenApi = _$dynamicFontWebResidencyDtoScopeEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontWebResidencyDtoScopeEnum> get serializer => _$dynamicFontWebResidencyDtoScopeEnumSerializer;

  const DynamicFontWebResidencyDtoScopeEnum._(String name): super(name);

  static BuiltSet<DynamicFontWebResidencyDtoScopeEnum> get values => _$dynamicFontWebResidencyDtoScopeEnumValues;
  static DynamicFontWebResidencyDtoScopeEnum valueOf(String name) => _$dynamicFontWebResidencyDtoScopeEnumValueOf(name);
}
