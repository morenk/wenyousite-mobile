//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/font_web_residency_dto.dart';
import 'package:wenyou_api/src/model/font_network_window_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_web_runtime_dto.g.dart';

/// FontWebRuntimeDto
///
/// Properties:
/// * [network]
/// * [residency]
@BuiltValue()
abstract class FontWebRuntimeDto implements Built<FontWebRuntimeDto, FontWebRuntimeDtoBuilder> {
  @BuiltValueField(wireName: r'network')
  FontNetworkWindowDto get network;

  @BuiltValueField(wireName: r'residency')
  FontWebResidencyDto get residency;

  FontWebRuntimeDto._();

  factory FontWebRuntimeDto([void updates(FontWebRuntimeDtoBuilder b)]) = _$FontWebRuntimeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontWebRuntimeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontWebRuntimeDto> get serializer => _$FontWebRuntimeDtoSerializer();
}

class _$FontWebRuntimeDtoSerializer implements PrimitiveSerializer<FontWebRuntimeDto> {
  @override
  final Iterable<Type> types = const [FontWebRuntimeDto, _$FontWebRuntimeDto];

  @override
  final String wireName = r'FontWebRuntimeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontWebRuntimeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'network';
    yield serializers.serialize(
      object.network,
      specifiedType: const FullType(FontNetworkWindowDto),
    );
    yield r'residency';
    yield serializers.serialize(
      object.residency,
      specifiedType: const FullType(FontWebResidencyDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontWebRuntimeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontWebRuntimeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'network':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontNetworkWindowDto),
          ) as FontNetworkWindowDto;
          result.network.replace(valueDes);
          break;
        case r'residency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontWebResidencyDto),
          ) as FontWebResidencyDto;
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
  FontWebRuntimeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontWebRuntimeDtoBuilder();
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
