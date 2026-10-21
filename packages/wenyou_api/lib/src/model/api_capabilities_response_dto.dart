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
/// * [textFontV2Supported] - 支持正文 v2（同时包含 v1）和动态目录；缺失按 false。
/// * [textFontV2WriteEnabled] - 允许动态版本的新范围/扩写；仍须该版本 pasteAllowed。缺失按 false。
/// * [textFontV1Supported] - 支持字体 v1 保源和旧端降级；缺失按 false
/// * [textFontV1WriteEnabled] - 允许新增/修改字体；关闭仍可保留或移除已有字体，缺失按 false
/// * [textColorV1Supported] - 支持独立文本颜色 v1 保源/旧端降级；缺失按 false
/// * [textColorV1WriteEnabled] - 允许新增/修改颜色范围；关闭仍允许保留或移除已有颜色，缺失按 false
/// * [rpIdentityProfileSupported] - 支持 RP 身份绑定本主题资料楼层及按查看者授权读取；缺失按 false，客户端不得发送 profilePostId/clearProfilePost
/// * [roleMentionsV6Supported] - 支持 header/DTO Markdown 6 能力协商、保源和旧读安全降级；缺失按 false
/// * [roleMentionsV6WriteEnabled] - 允许创建新的显式 ACCOUNT / RP 提及节点；与全局 Markdown 激活版本独立，缺失按 false
/// * [stickers]
/// * [directMessages]
/// * [pushNotifications]
@BuiltValue()
abstract class ApiCapabilitiesResponseDto implements Built<ApiCapabilitiesResponseDto, ApiCapabilitiesResponseDtoBuilder> {
  /// 支持正文 v2（同时包含 v1）和动态目录；缺失按 false。
  @BuiltValueField(wireName: r'textFontV2Supported')
  bool? get textFontV2Supported;

  /// 允许动态版本的新范围/扩写；仍须该版本 pasteAllowed。缺失按 false。
  @BuiltValueField(wireName: r'textFontV2WriteEnabled')
  bool? get textFontV2WriteEnabled;

  /// 支持字体 v1 保源和旧端降级；缺失按 false
  @BuiltValueField(wireName: r'textFontV1Supported')
  bool? get textFontV1Supported;

  /// 允许新增/修改字体；关闭仍可保留或移除已有字体，缺失按 false
  @BuiltValueField(wireName: r'textFontV1WriteEnabled')
  bool? get textFontV1WriteEnabled;

  /// 支持独立文本颜色 v1 保源/旧端降级；缺失按 false
  @BuiltValueField(wireName: r'textColorV1Supported')
  bool? get textColorV1Supported;

  /// 允许新增/修改颜色范围；关闭仍允许保留或移除已有颜色，缺失按 false
  @BuiltValueField(wireName: r'textColorV1WriteEnabled')
  bool? get textColorV1WriteEnabled;

  /// 支持 RP 身份绑定本主题资料楼层及按查看者授权读取；缺失按 false，客户端不得发送 profilePostId/clearProfilePost
  @BuiltValueField(wireName: r'rpIdentityProfileSupported')
  bool? get rpIdentityProfileSupported;

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
    if (object.textFontV2Supported != null) {
      yield r'textFontV2Supported';
      yield serializers.serialize(
        object.textFontV2Supported,
        specifiedType: const FullType(bool),
      );
    }
    if (object.textFontV2WriteEnabled != null) {
      yield r'textFontV2WriteEnabled';
      yield serializers.serialize(
        object.textFontV2WriteEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.textFontV1Supported != null) {
      yield r'textFontV1Supported';
      yield serializers.serialize(
        object.textFontV1Supported,
        specifiedType: const FullType(bool),
      );
    }
    if (object.textFontV1WriteEnabled != null) {
      yield r'textFontV1WriteEnabled';
      yield serializers.serialize(
        object.textFontV1WriteEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.textColorV1Supported != null) {
      yield r'textColorV1Supported';
      yield serializers.serialize(
        object.textColorV1Supported,
        specifiedType: const FullType(bool),
      );
    }
    if (object.textColorV1WriteEnabled != null) {
      yield r'textColorV1WriteEnabled';
      yield serializers.serialize(
        object.textColorV1WriteEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.rpIdentityProfileSupported != null) {
      yield r'rpIdentityProfileSupported';
      yield serializers.serialize(
        object.rpIdentityProfileSupported,
        specifiedType: const FullType(bool),
      );
    }
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
        case r'textFontV2Supported':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.textFontV2Supported = valueDes;
          break;
        case r'textFontV2WriteEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.textFontV2WriteEnabled = valueDes;
          break;
        case r'textFontV1Supported':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.textFontV1Supported = valueDes;
          break;
        case r'textFontV1WriteEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.textFontV1WriteEnabled = valueDes;
          break;
        case r'textColorV1Supported':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.textColorV1Supported = valueDes;
          break;
        case r'textColorV1WriteEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.textColorV1WriteEnabled = valueDes;
          break;
        case r'rpIdentityProfileSupported':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.rpIdentityProfileSupported = valueDes;
          break;
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
