//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/dynamic_font_registration_dto.dart';
import 'package:wenyou_api/src/model/dynamic_font_network_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dynamic_font_mobile_runtime_dto.g.dart';

/// DynamicFontMobileRuntimeDto
///
/// Properties:
/// * [network]
/// * [registration]
@BuiltValue()
abstract class DynamicFontMobileRuntimeDto implements Built<DynamicFontMobileRuntimeDto, DynamicFontMobileRuntimeDtoBuilder> {
  @BuiltValueField(wireName: r'network')
  DynamicFontNetworkDto get network;

  @BuiltValueField(wireName: r'registration')
  DynamicFontRegistrationDto get registration;

  DynamicFontMobileRuntimeDto._();

  factory DynamicFontMobileRuntimeDto([void updates(DynamicFontMobileRuntimeDtoBuilder b)]) = _$DynamicFontMobileRuntimeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DynamicFontMobileRuntimeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DynamicFontMobileRuntimeDto> get serializer => _$DynamicFontMobileRuntimeDtoSerializer();
}

class _$DynamicFontMobileRuntimeDtoSerializer implements PrimitiveSerializer<DynamicFontMobileRuntimeDto> {
  @override
  final Iterable<Type> types = const [DynamicFontMobileRuntimeDto, _$DynamicFontMobileRuntimeDto];

  @override
  final String wireName = r'DynamicFontMobileRuntimeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DynamicFontMobileRuntimeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'network';
    yield serializers.serialize(
      object.network,
      specifiedType: const FullType(DynamicFontNetworkDto),
    );
    yield r'registration';
    yield serializers.serialize(
      object.registration,
      specifiedType: const FullType(DynamicFontRegistrationDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DynamicFontMobileRuntimeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DynamicFontMobileRuntimeDtoBuilder result,
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
        case r'registration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontRegistrationDto),
          ) as DynamicFontRegistrationDto;
          result.registration.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DynamicFontMobileRuntimeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DynamicFontMobileRuntimeDtoBuilder();
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
