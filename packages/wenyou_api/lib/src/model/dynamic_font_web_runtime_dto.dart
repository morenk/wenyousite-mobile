//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/dynamic_font_network_dto.dart';
import 'package:wenyou_api/src/model/dynamic_font_web_residency_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dynamic_font_web_runtime_dto.g.dart';

/// DynamicFontWebRuntimeDto
///
/// Properties:
/// * [network]
/// * [residency] - 没有固定家族数量限制；未释放的 face 继续计费。
@BuiltValue()
abstract class DynamicFontWebRuntimeDto implements Built<DynamicFontWebRuntimeDto, DynamicFontWebRuntimeDtoBuilder> {
  @BuiltValueField(wireName: r'network')
  DynamicFontNetworkDto get network;

  /// 没有固定家族数量限制；未释放的 face 继续计费。
  @BuiltValueField(wireName: r'residency')
  DynamicFontWebResidencyDto get residency;

  DynamicFontWebRuntimeDto._();

  factory DynamicFontWebRuntimeDto([void updates(DynamicFontWebRuntimeDtoBuilder b)]) = _$DynamicFontWebRuntimeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DynamicFontWebRuntimeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DynamicFontWebRuntimeDto> get serializer => _$DynamicFontWebRuntimeDtoSerializer();
}

class _$DynamicFontWebRuntimeDtoSerializer implements PrimitiveSerializer<DynamicFontWebRuntimeDto> {
  @override
  final Iterable<Type> types = const [DynamicFontWebRuntimeDto, _$DynamicFontWebRuntimeDto];

  @override
  final String wireName = r'DynamicFontWebRuntimeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DynamicFontWebRuntimeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'network';
    yield serializers.serialize(
      object.network,
      specifiedType: const FullType(DynamicFontNetworkDto),
    );
    yield r'residency';
    yield serializers.serialize(
      object.residency,
      specifiedType: const FullType(DynamicFontWebResidencyDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DynamicFontWebRuntimeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DynamicFontWebRuntimeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'network':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontNetworkDto),
          ) as DynamicFontNetworkDto;
          result.network.replace(valueDes);
          break;
        case r'residency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontWebResidencyDto),
          ) as DynamicFontWebResidencyDto;
          result.residency.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DynamicFontWebRuntimeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DynamicFontWebRuntimeDtoBuilder();
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
