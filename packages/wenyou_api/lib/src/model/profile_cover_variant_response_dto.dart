//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'profile_cover_variant_response_dto.g.dart';

/// ProfileCoverVariantResponseDto
///
/// Properties:
/// * [url] - 背景图原图地址
/// * [mediumUrl] - 800px WebP 中图地址
/// * [width]
/// * [height]
@BuiltValue()
abstract class ProfileCoverVariantResponseDto implements Built<ProfileCoverVariantResponseDto, ProfileCoverVariantResponseDtoBuilder> {
  /// 背景图原图地址
  @BuiltValueField(wireName: r'url')
  String get url;

  /// 800px WebP 中图地址
  @BuiltValueField(wireName: r'mediumUrl')
  String? get mediumUrl;

  @BuiltValueField(wireName: r'width')
  num? get width;

  @BuiltValueField(wireName: r'height')
  num? get height;

  ProfileCoverVariantResponseDto._();

  factory ProfileCoverVariantResponseDto([void updates(ProfileCoverVariantResponseDtoBuilder b)]) = _$ProfileCoverVariantResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProfileCoverVariantResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProfileCoverVariantResponseDto> get serializer => _$ProfileCoverVariantResponseDtoSerializer();
}

class _$ProfileCoverVariantResponseDtoSerializer implements PrimitiveSerializer<ProfileCoverVariantResponseDto> {
  @override
  final Iterable<Type> types = const [ProfileCoverVariantResponseDto, _$ProfileCoverVariantResponseDto];

  @override
  final String wireName = r'ProfileCoverVariantResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProfileCoverVariantResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'mediumUrl';
    yield object.mediumUrl == null ? null : serializers.serialize(
      object.mediumUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'width';
    yield object.width == null ? null : serializers.serialize(
      object.width,
      specifiedType: const FullType.nullable(num),
    );
    yield r'height';
    yield object.height == null ? null : serializers.serialize(
      object.height,
      specifiedType: const FullType.nullable(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProfileCoverVariantResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProfileCoverVariantResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'mediumUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mediumUrl = valueDes;
          break;
        case r'width':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.width = valueDes;
          break;
        case r'height':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.height = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProfileCoverVariantResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProfileCoverVariantResponseDtoBuilder();
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
