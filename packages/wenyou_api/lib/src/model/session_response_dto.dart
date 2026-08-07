//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'session_response_dto.g.dart';

/// SessionResponseDto
///
/// Properties:
/// * [id] - 稳定的登录终端标识；refresh token 轮转时保持不变
/// * [platform] - 终端平台：web=浏览器，mobile=原生移动客户端
/// * [deviceInfo] - 原始客户端标识，仅为旧客户端兼容保留；界面不得直接展示
/// * [isCurrent] - 是否为发起当前请求的登录终端
/// * [signedInAt] - 本次终端登录的开始时间，refresh token 轮转时保持不变
/// * [lastActiveAt] - 最近一次登录或令牌续期时间
/// * [expiresAt] - 当前 refresh token 的过期时间
/// * [createdAt] - 兼容旧客户端的登录时间别名；新客户端请使用 signedInAt
@BuiltValue()
abstract class SessionResponseDto implements Built<SessionResponseDto, SessionResponseDtoBuilder> {
  /// 稳定的登录终端标识；refresh token 轮转时保持不变
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 终端平台：web=浏览器，mobile=原生移动客户端
  @BuiltValueField(wireName: r'platform')
  SessionResponseDtoPlatformEnum get platform;
  // enum platformEnum {  web,  mobile,  };

  /// 原始客户端标识，仅为旧客户端兼容保留；界面不得直接展示
  @Deprecated('deviceInfo has been deprecated')
  @BuiltValueField(wireName: r'deviceInfo')
  String? get deviceInfo;

  /// 是否为发起当前请求的登录终端
  @BuiltValueField(wireName: r'isCurrent')
  bool get isCurrent;

  /// 本次终端登录的开始时间，refresh token 轮转时保持不变
  @BuiltValueField(wireName: r'signedInAt')
  DateTime get signedInAt;

  /// 最近一次登录或令牌续期时间
  @BuiltValueField(wireName: r'lastActiveAt')
  DateTime get lastActiveAt;

  /// 当前 refresh token 的过期时间
  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  /// 兼容旧客户端的登录时间别名；新客户端请使用 signedInAt
  @Deprecated('createdAt has been deprecated')
  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  SessionResponseDto._();

  factory SessionResponseDto([void updates(SessionResponseDtoBuilder b)]) = _$SessionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SessionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SessionResponseDto> get serializer => _$SessionResponseDtoSerializer();
}

class _$SessionResponseDtoSerializer implements PrimitiveSerializer<SessionResponseDto> {
  @override
  final Iterable<Type> types = const [SessionResponseDto, _$SessionResponseDto];

  @override
  final String wireName = r'SessionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SessionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(SessionResponseDtoPlatformEnum),
    );
    yield r'deviceInfo';
    yield object.deviceInfo == null ? null : serializers.serialize(
      object.deviceInfo,
      specifiedType: const FullType.nullable(String),
    );
    yield r'isCurrent';
    yield serializers.serialize(
      object.isCurrent,
      specifiedType: const FullType(bool),
    );
    yield r'signedInAt';
    yield serializers.serialize(
      object.signedInAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'lastActiveAt';
    yield serializers.serialize(
      object.lastActiveAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SessionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SessionResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SessionResponseDtoPlatformEnum),
          ) as SessionResponseDtoPlatformEnum;
          result.platform = valueDes;
          break;
        case r'deviceInfo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceInfo = valueDes;
          break;
        case r'isCurrent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isCurrent = valueDes;
          break;
        case r'signedInAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.signedInAt = valueDes;
          break;
        case r'lastActiveAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastActiveAt = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SessionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SessionResponseDtoBuilder();
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

class SessionResponseDtoPlatformEnum extends EnumClass {

  /// 终端平台：web=浏览器，mobile=原生移动客户端
  @BuiltValueEnumConst(wireName: r'web')
  static const SessionResponseDtoPlatformEnum web = _$sessionResponseDtoPlatformEnum_web;
  /// 终端平台：web=浏览器，mobile=原生移动客户端
  @BuiltValueEnumConst(wireName: r'mobile')
  static const SessionResponseDtoPlatformEnum mobile = _$sessionResponseDtoPlatformEnum_mobile;
  /// 终端平台：web=浏览器，mobile=原生移动客户端
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SessionResponseDtoPlatformEnum unknownDefaultOpenApi = _$sessionResponseDtoPlatformEnum_unknownDefaultOpenApi;

  static Serializer<SessionResponseDtoPlatformEnum> get serializer => _$sessionResponseDtoPlatformEnumSerializer;

  const SessionResponseDtoPlatformEnum._(String name): super(name);

  static BuiltSet<SessionResponseDtoPlatformEnum> get values => _$sessionResponseDtoPlatformEnumValues;
  static SessionResponseDtoPlatformEnum valueOf(String name) => _$sessionResponseDtoPlatformEnumValueOf(name);
}
