//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_retry_policy_dto.dart';
import 'package:wenyou_api/src/model/dynamic_font_mobile_runtime_dto.dart';
import 'package:wenyou_api/src/model/dynamic_font_web_runtime_dto.dart';
import 'package:wenyou_api/src/model/font_metadata_policy_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dynamic_font_runtime_policy_dto.g.dart';

/// DynamicFontRuntimePolicyDto
///
/// Properties:
/// * [policyVersion] - 动态策略独立于旧固定 manifest 策略 v2。拒绝未知/缺字段策略，保留最后可信策略且不得放大本地硬上限。
/// * [fontVersion]
/// * [web]
/// * [mobile]
/// * [retry]
/// * [metadata]
/// * [diskCacheBytes]
@BuiltValue()
abstract class DynamicFontRuntimePolicyDto implements Built<DynamicFontRuntimePolicyDto, DynamicFontRuntimePolicyDtoBuilder> {
  /// 动态策略独立于旧固定 manifest 策略 v2。拒绝未知/缺字段策略，保留最后可信策略且不得放大本地硬上限。
  @BuiltValueField(wireName: r'policyVersion')
  DynamicFontRuntimePolicyDtoPolicyVersionEnum get policyVersion;
  // enum policyVersionEnum {  3,  };

  @BuiltValueField(wireName: r'fontVersion')
  DynamicFontRuntimePolicyDtoFontVersionEnum get fontVersion;
  // enum fontVersionEnum {  2,  };

  @BuiltValueField(wireName: r'web')
  DynamicFontWebRuntimeDto get web;

  @BuiltValueField(wireName: r'mobile')
  DynamicFontMobileRuntimeDto get mobile;

  @BuiltValueField(wireName: r'retry')
  FontRetryPolicyDto get retry;

  @BuiltValueField(wireName: r'metadata')
  FontMetadataPolicyDto get metadata;

  @BuiltValueField(wireName: r'diskCacheBytes')
  int get diskCacheBytes;

  DynamicFontRuntimePolicyDto._();

  factory DynamicFontRuntimePolicyDto([void updates(DynamicFontRuntimePolicyDtoBuilder b)]) = _$DynamicFontRuntimePolicyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DynamicFontRuntimePolicyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DynamicFontRuntimePolicyDto> get serializer => _$DynamicFontRuntimePolicyDtoSerializer();
}

class _$DynamicFontRuntimePolicyDtoSerializer implements PrimitiveSerializer<DynamicFontRuntimePolicyDto> {
  @override
  final Iterable<Type> types = const [DynamicFontRuntimePolicyDto, _$DynamicFontRuntimePolicyDto];

  @override
  final String wireName = r'DynamicFontRuntimePolicyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DynamicFontRuntimePolicyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'policyVersion';
    yield serializers.serialize(
      object.policyVersion,
      specifiedType: const FullType(DynamicFontRuntimePolicyDtoPolicyVersionEnum),
    );
    yield r'fontVersion';
    yield serializers.serialize(
      object.fontVersion,
      specifiedType: const FullType(DynamicFontRuntimePolicyDtoFontVersionEnum),
    );
    yield r'web';
    yield serializers.serialize(
      object.web,
      specifiedType: const FullType(DynamicFontWebRuntimeDto),
    );
    yield r'mobile';
    yield serializers.serialize(
      object.mobile,
      specifiedType: const FullType(DynamicFontMobileRuntimeDto),
    );
    yield r'retry';
    yield serializers.serialize(
      object.retry,
      specifiedType: const FullType(FontRetryPolicyDto),
    );
    yield r'metadata';
    yield serializers.serialize(
      object.metadata,
      specifiedType: const FullType(FontMetadataPolicyDto),
    );
    yield r'diskCacheBytes';
    yield serializers.serialize(
      object.diskCacheBytes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DynamicFontRuntimePolicyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DynamicFontRuntimePolicyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'policyVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontRuntimePolicyDtoPolicyVersionEnum),
          ) as DynamicFontRuntimePolicyDtoPolicyVersionEnum;
          result.policyVersion = valueDes;
          break;
        case r'fontVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontRuntimePolicyDtoFontVersionEnum),
          ) as DynamicFontRuntimePolicyDtoFontVersionEnum;
          result.fontVersion = valueDes;
          break;
        case r'web':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontWebRuntimeDto),
          ) as DynamicFontWebRuntimeDto;
          result.web.replace(valueDes);
          break;
        case r'mobile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontMobileRuntimeDto),
          ) as DynamicFontMobileRuntimeDto;
          result.mobile.replace(valueDes);
          break;
        case r'retry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontRetryPolicyDto),
          ) as FontRetryPolicyDto;
          result.retry.replace(valueDes);
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontMetadataPolicyDto),
          ) as FontMetadataPolicyDto;
          result.metadata.replace(valueDes);
          break;
        case r'diskCacheBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.diskCacheBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DynamicFontRuntimePolicyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DynamicFontRuntimePolicyDtoBuilder();
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

class DynamicFontRuntimePolicyDtoPolicyVersionEnum extends EnumClass {

  /// 动态策略独立于旧固定 manifest 策略 v2。拒绝未知/缺字段策略，保留最后可信策略且不得放大本地硬上限。
  @BuiltValueEnumConst(wireName: r'3')
  static const DynamicFontRuntimePolicyDtoPolicyVersionEnum n3 = _$dynamicFontRuntimePolicyDtoPolicyVersionEnum_n3;
  /// 动态策略独立于旧固定 manifest 策略 v2。拒绝未知/缺字段策略，保留最后可信策略且不得放大本地硬上限。
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const DynamicFontRuntimePolicyDtoPolicyVersionEnum unknownDefaultOpenApi = _$dynamicFontRuntimePolicyDtoPolicyVersionEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontRuntimePolicyDtoPolicyVersionEnum> get serializer => _$dynamicFontRuntimePolicyDtoPolicyVersionEnumSerializer;

  const DynamicFontRuntimePolicyDtoPolicyVersionEnum._(String name): super(name);

  static BuiltSet<DynamicFontRuntimePolicyDtoPolicyVersionEnum> get values => _$dynamicFontRuntimePolicyDtoPolicyVersionEnumValues;
  static DynamicFontRuntimePolicyDtoPolicyVersionEnum valueOf(String name) => _$dynamicFontRuntimePolicyDtoPolicyVersionEnumValueOf(name);
}

class DynamicFontRuntimePolicyDtoFontVersionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'2')
  static const DynamicFontRuntimePolicyDtoFontVersionEnum n2 = _$dynamicFontRuntimePolicyDtoFontVersionEnum_n2;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const DynamicFontRuntimePolicyDtoFontVersionEnum unknownDefaultOpenApi = _$dynamicFontRuntimePolicyDtoFontVersionEnum_unknownDefaultOpenApi;

  static Serializer<DynamicFontRuntimePolicyDtoFontVersionEnum> get serializer => _$dynamicFontRuntimePolicyDtoFontVersionEnumSerializer;

  const DynamicFontRuntimePolicyDtoFontVersionEnum._(String name): super(name);

  static BuiltSet<DynamicFontRuntimePolicyDtoFontVersionEnum> get values => _$dynamicFontRuntimePolicyDtoFontVersionEnumValues;
  static DynamicFontRuntimePolicyDtoFontVersionEnum valueOf(String name) => _$dynamicFontRuntimePolicyDtoFontVersionEnumValueOf(name);
}
