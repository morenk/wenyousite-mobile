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
/// * [roleMentionsV6Supported] - 支持 header/DTO Markdown 6 能力协商、保源和旧读安全降级；缺失按 false
/// * [roleMentionsV6WriteEnabled] - 允许创建新的显式 ACCOUNT / RP 提及节点；与全局 Markdown 激活版本独立，缺失按 false
/// * [stickers]
/// * [directMessages]
/// * [pushNotifications]
@BuiltValue()
abstract class ApiCapabilitiesResponseDto implements Built<ApiCapabilitiesResponseDto, ApiCapabilitiesResponseDtoBuilder> {
  /// 支持 header/DTO Markdown 6 能力协商、保源和旧读安全降级；缺失按 false
  @BuiltValueField(wireName: r'roleMentionsV6Supported')
  bool? get roleMentionsV6Supported;

  /// 允许创建新的显式 ACCOUNT / RP 提及节点；与全局 Markdown 激活版本独立，缺失按 false
  @BuiltValueField(wireName: r'roleMentionsV6WriteEnabled')
  bool? get roleMentionsV6WriteEnabled;

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
    if (object.roleMentionsV6Supported != null) {
      yield r'roleMentionsV6Supported';
      yield serializers.serialize(
        object.roleMentionsV6Supported,
        specifiedType: const FullType(bool),
      );
    }
    if (object.roleMentionsV6WriteEnabled != null) {
      yield r'roleMentionsV6WriteEnabled';
      yield serializers.serialize(
        object.roleMentionsV6WriteEnabled,
        specifiedType: const FullType(bool),
      );
    }
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
        case r'roleMentionsV6Supported':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.roleMentionsV6Supported = valueDes;
          break;
        case r'roleMentionsV6WriteEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.roleMentionsV6WriteEnabled = valueDes;
          break;
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
