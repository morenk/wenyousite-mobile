//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'api_capabilities_response_dto.g.dart';

/// ApiCapabilitiesResponseDto
///
/// Properties:
/// * [stickers]
/// * [directMessages]
/// * [pushNotifications]
@BuiltValue()
abstract class ApiCapabilitiesResponseDto implements Built<ApiCapabilitiesResponseDto, ApiCapabilitiesResponseDtoBuilder> {
  @BuiltValueField(wireName: r'stickers')
  bool get stickers;

  @BuiltValueField(wireName: r'directMessages')
  bool get directMessages;

  @BuiltValueField(wireName: r'pushNotifications')
  bool get pushNotifications;

  ApiCapabilitiesResponseDto._();

  factory ApiCapabilitiesResponseDto([void updates(ApiCapabilitiesResponseDtoBuilder b)]) = _$ApiCapabilitiesResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApiCapabilitiesResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApiCapabilitiesResponseDto> get serializer => _$ApiCapabilitiesResponseDtoSerializer();
}

class _$ApiCapabilitiesResponseDtoSerializer implements PrimitiveSerializer<ApiCapabilitiesResponseDto> {
  @override
  final Iterable<Type> types = const [ApiCapabilitiesResponseDto, _$ApiCapabilitiesResponseDto];

  @override
  final String wireName = r'ApiCapabilitiesResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApiCapabilitiesResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stickers';
    yield serializers.serialize(
      object.stickers,
      specifiedType: const FullType(bool),
    );
    yield r'directMessages';
    yield serializers.serialize(
      object.directMessages,
      specifiedType: const FullType(bool),
    );
    yield r'pushNotifications';
    yield serializers.serialize(
      object.pushNotifications,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ApiCapabilitiesResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ApiCapabilitiesResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stickers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.stickers = valueDes;
          break;
        case r'directMessages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.directMessages = valueDes;
          break;
        case r'pushNotifications':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pushNotifications = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ApiCapabilitiesResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApiCapabilitiesResponseDtoBuilder();
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
