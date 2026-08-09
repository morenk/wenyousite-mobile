//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/mobile_platform_compatibility_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mobile_compatibility_dto.g.dart';

/// MobileCompatibilityDto
///
/// Properties:
/// * [android]
/// * [ios]
@BuiltValue()
abstract class MobileCompatibilityDto implements Built<MobileCompatibilityDto, MobileCompatibilityDtoBuilder> {
  @BuiltValueField(wireName: r'android')
  MobilePlatformCompatibilityDto get android;

  @BuiltValueField(wireName: r'ios')
  MobilePlatformCompatibilityDto get ios;

  MobileCompatibilityDto._();

  factory MobileCompatibilityDto([void updates(MobileCompatibilityDtoBuilder b)]) = _$MobileCompatibilityDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MobileCompatibilityDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MobileCompatibilityDto> get serializer => _$MobileCompatibilityDtoSerializer();
}

class _$MobileCompatibilityDtoSerializer implements PrimitiveSerializer<MobileCompatibilityDto> {
  @override
  final Iterable<Type> types = const [MobileCompatibilityDto, _$MobileCompatibilityDto];

  @override
  final String wireName = r'MobileCompatibilityDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MobileCompatibilityDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'android';
    yield serializers.serialize(
      object.android,
      specifiedType: const FullType(MobilePlatformCompatibilityDto),
    );
    yield r'ios';
    yield serializers.serialize(
      object.ios,
      specifiedType: const FullType(MobilePlatformCompatibilityDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MobileCompatibilityDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MobileCompatibilityDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'android':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MobilePlatformCompatibilityDto),
          ) as MobilePlatformCompatibilityDto;
          result.android.replace(valueDes);
          break;
        case r'ios':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MobilePlatformCompatibilityDto),
          ) as MobilePlatformCompatibilityDto;
          result.ios.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MobileCompatibilityDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MobileCompatibilityDtoBuilder();
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
