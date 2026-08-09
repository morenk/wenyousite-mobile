//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mobile_platform_compatibility_dto.g.dart';

/// MobilePlatformCompatibilityDto
///
/// Properties:
/// * [minimumSupportedBuild]
/// * [recommendedBuild]
/// * [updateUrl]
@BuiltValue()
abstract class MobilePlatformCompatibilityDto implements Built<MobilePlatformCompatibilityDto, MobilePlatformCompatibilityDtoBuilder> {
  @BuiltValueField(wireName: r'minimumSupportedBuild')
  num? get minimumSupportedBuild;

  @BuiltValueField(wireName: r'recommendedBuild')
  num? get recommendedBuild;

  @BuiltValueField(wireName: r'updateUrl')
  String? get updateUrl;

  MobilePlatformCompatibilityDto._();

  factory MobilePlatformCompatibilityDto([void updates(MobilePlatformCompatibilityDtoBuilder b)]) = _$MobilePlatformCompatibilityDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MobilePlatformCompatibilityDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MobilePlatformCompatibilityDto> get serializer => _$MobilePlatformCompatibilityDtoSerializer();
}

class _$MobilePlatformCompatibilityDtoSerializer implements PrimitiveSerializer<MobilePlatformCompatibilityDto> {
  @override
  final Iterable<Type> types = const [MobilePlatformCompatibilityDto, _$MobilePlatformCompatibilityDto];

  @override
  final String wireName = r'MobilePlatformCompatibilityDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MobilePlatformCompatibilityDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'minimumSupportedBuild';
    yield object.minimumSupportedBuild == null ? null : serializers.serialize(
      object.minimumSupportedBuild,
      specifiedType: const FullType.nullable(num),
    );
    yield r'recommendedBuild';
    yield object.recommendedBuild == null ? null : serializers.serialize(
      object.recommendedBuild,
      specifiedType: const FullType.nullable(num),
    );
    yield r'updateUrl';
    yield object.updateUrl == null ? null : serializers.serialize(
      object.updateUrl,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MobilePlatformCompatibilityDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MobilePlatformCompatibilityDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'minimumSupportedBuild':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.minimumSupportedBuild = valueDes;
          break;
        case r'recommendedBuild':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.recommendedBuild = valueDes;
          break;
        case r'updateUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.updateUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MobilePlatformCompatibilityDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MobilePlatformCompatibilityDtoBuilder();
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
