//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_retry_policy_dto.dart';
import 'package:wenyou_api/src/model/font_mobile_runtime_dto.dart';
import 'package:wenyou_api/src/model/font_web_runtime_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'text_font_runtime_policy_dto.g.dart';

/// TextFontRuntimePolicyDto
///
/// Properties:
/// * [policyVersion] - 独立运行策略；未识别版本时继续 legacy limits
/// * [manifestSha256] - 必须等于已校验目录描述符和 manifest 实际 SHA；不匹配不启用策略
/// * [web]
/// * [mobile]
/// * [retry]
@BuiltValue()
abstract class TextFontRuntimePolicyDto implements Built<TextFontRuntimePolicyDto, TextFontRuntimePolicyDtoBuilder> {
  /// 独立运行策略；未识别版本时继续 legacy limits
  @BuiltValueField(wireName: r'policyVersion')
  TextFontRuntimePolicyDtoPolicyVersionEnum get policyVersion;
  // enum policyVersionEnum {  2,  };

  /// 必须等于已校验目录描述符和 manifest 实际 SHA；不匹配不启用策略
  @BuiltValueField(wireName: r'manifestSha256')
  String get manifestSha256;

  @BuiltValueField(wireName: r'web')
  FontWebRuntimeDto get web;

  @BuiltValueField(wireName: r'mobile')
  FontMobileRuntimeDto get mobile;

  @BuiltValueField(wireName: r'retry')
  FontRetryPolicyDto get retry;

  TextFontRuntimePolicyDto._();

  factory TextFontRuntimePolicyDto([void updates(TextFontRuntimePolicyDtoBuilder b)]) = _$TextFontRuntimePolicyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TextFontRuntimePolicyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TextFontRuntimePolicyDto> get serializer => _$TextFontRuntimePolicyDtoSerializer();
}

class _$TextFontRuntimePolicyDtoSerializer implements PrimitiveSerializer<TextFontRuntimePolicyDto> {
  @override
  final Iterable<Type> types = const [TextFontRuntimePolicyDto, _$TextFontRuntimePolicyDto];

  @override
  final String wireName = r'TextFontRuntimePolicyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TextFontRuntimePolicyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'policyVersion';
    yield serializers.serialize(
      object.policyVersion,
      specifiedType: const FullType(TextFontRuntimePolicyDtoPolicyVersionEnum),
    );
    yield r'manifestSha256';
    yield serializers.serialize(
      object.manifestSha256,
      specifiedType: const FullType(String),
    );
    yield r'web';
    yield serializers.serialize(
      object.web,
      specifiedType: const FullType(FontWebRuntimeDto),
    );
    yield r'mobile';
    yield serializers.serialize(
      object.mobile,
      specifiedType: const FullType(FontMobileRuntimeDto),
    );
    yield r'retry';
    yield serializers.serialize(
      object.retry,
      specifiedType: const FullType(FontRetryPolicyDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TextFontRuntimePolicyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TextFontRuntimePolicyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'policyVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TextFontRuntimePolicyDtoPolicyVersionEnum),
          ) as TextFontRuntimePolicyDtoPolicyVersionEnum;
          result.policyVersion = valueDes;
          break;
        case r'manifestSha256':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.manifestSha256 = valueDes;
          break;
        case r'web':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontWebRuntimeDto),
          ) as FontWebRuntimeDto;
          result.web.replace(valueDes);
          break;
        case r'mobile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontMobileRuntimeDto),
          ) as FontMobileRuntimeDto;
          result.mobile.replace(valueDes);
          break;
        case r'retry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontRetryPolicyDto),
          ) as FontRetryPolicyDto;
          result.retry.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TextFontRuntimePolicyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TextFontRuntimePolicyDtoBuilder();
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

class TextFontRuntimePolicyDtoPolicyVersionEnum extends EnumClass {

  /// 独立运行策略；未识别版本时继续 legacy limits
  @BuiltValueEnumConst(wireName: r'2')
  static const TextFontRuntimePolicyDtoPolicyVersionEnum n2 = _$textFontRuntimePolicyDtoPolicyVersionEnum_n2;
  /// 独立运行策略；未识别版本时继续 legacy limits
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const TextFontRuntimePolicyDtoPolicyVersionEnum unknownDefaultOpenApi = _$textFontRuntimePolicyDtoPolicyVersionEnum_unknownDefaultOpenApi;

  static Serializer<TextFontRuntimePolicyDtoPolicyVersionEnum> get serializer => _$textFontRuntimePolicyDtoPolicyVersionEnumSerializer;

  const TextFontRuntimePolicyDtoPolicyVersionEnum._(String name): super(name);

  static BuiltSet<TextFontRuntimePolicyDtoPolicyVersionEnum> get values => _$textFontRuntimePolicyDtoPolicyVersionEnumValues;
  static TextFontRuntimePolicyDtoPolicyVersionEnum valueOf(String name) => _$textFontRuntimePolicyDtoPolicyVersionEnumValueOf(name);
}
