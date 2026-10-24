//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/font_mobile_registration_dto.dart';
import 'package:wenyou_api/src/model/font_network_window_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_mobile_runtime_dto.g.dart';

/// FontMobileRuntimeDto
///
/// Properties:
/// * [network]
/// * [registration]
@BuiltValue()
abstract class FontMobileRuntimeDto implements Built<FontMobileRuntimeDto, FontMobileRuntimeDtoBuilder> {
  @BuiltValueField(wireName: r'network')
  FontNetworkWindowDto get network;

  @BuiltValueField(wireName: r'registration')
  FontMobileRegistrationDto get registration;

  FontMobileRuntimeDto._();

  factory FontMobileRuntimeDto([void updates(FontMobileRuntimeDtoBuilder b)]) = _$FontMobileRuntimeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontMobileRuntimeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontMobileRuntimeDto> get serializer => _$FontMobileRuntimeDtoSerializer();
}

class _$FontMobileRuntimeDtoSerializer implements PrimitiveSerializer<FontMobileRuntimeDto> {
  @override
  final Iterable<Type> types = const [FontMobileRuntimeDto, _$FontMobileRuntimeDto];

  @override
  final String wireName = r'FontMobileRuntimeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontMobileRuntimeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'network';
    yield serializers.serialize(
      object.network,
      specifiedType: const FullType(FontNetworkWindowDto),
    );
    yield r'registration';
    yield serializers.serialize(
      object.registration,
      specifiedType: const FullType(FontMobileRegistrationDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontMobileRuntimeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontMobileRuntimeDtoBuilder result,
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
        case r'registration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontMobileRegistrationDto),
          ) as FontMobileRegistrationDto;
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
  FontMobileRuntimeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontMobileRuntimeDtoBuilder();
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
