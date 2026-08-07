//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register_mobile_device_dto.g.dart';

/// RegisterMobileDeviceDto
///
/// Properties:
/// * [pushToken] - Firebase Cloud Messaging registration token
/// * [platform]
/// * [appVersion]
/// * [locale]
@BuiltValue()
abstract class RegisterMobileDeviceDto implements Built<RegisterMobileDeviceDto, RegisterMobileDeviceDtoBuilder> {
  /// Firebase Cloud Messaging registration token
  @BuiltValueField(wireName: r'pushToken')
  String get pushToken;

  @BuiltValueField(wireName: r'platform')
  RegisterMobileDeviceDtoPlatformEnum get platform;
  // enum platformEnum {  android,  ios,  };

  @BuiltValueField(wireName: r'appVersion')
  String? get appVersion;

  @BuiltValueField(wireName: r'locale')
  String? get locale;

  RegisterMobileDeviceDto._();

  factory RegisterMobileDeviceDto([void updates(RegisterMobileDeviceDtoBuilder b)]) = _$RegisterMobileDeviceDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterMobileDeviceDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterMobileDeviceDto> get serializer => _$RegisterMobileDeviceDtoSerializer();
}

class _$RegisterMobileDeviceDtoSerializer implements PrimitiveSerializer<RegisterMobileDeviceDto> {
  @override
  final Iterable<Type> types = const [RegisterMobileDeviceDto, _$RegisterMobileDeviceDto];

  @override
  final String wireName = r'RegisterMobileDeviceDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterMobileDeviceDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pushToken';
    yield serializers.serialize(
      object.pushToken,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(RegisterMobileDeviceDtoPlatformEnum),
    );
    if (object.appVersion != null) {
      yield r'appVersion';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.locale != null) {
      yield r'locale';
      yield serializers.serialize(
        object.locale,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RegisterMobileDeviceDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RegisterMobileDeviceDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pushToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pushToken = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RegisterMobileDeviceDtoPlatformEnum),
          ) as RegisterMobileDeviceDtoPlatformEnum;
          result.platform = valueDes;
          break;
        case r'appVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.appVersion = valueDes;
          break;
        case r'locale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.locale = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RegisterMobileDeviceDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterMobileDeviceDtoBuilder();
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

class RegisterMobileDeviceDtoPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'android')
  static const RegisterMobileDeviceDtoPlatformEnum android = _$registerMobileDeviceDtoPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'ios')
  static const RegisterMobileDeviceDtoPlatformEnum ios = _$registerMobileDeviceDtoPlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const RegisterMobileDeviceDtoPlatformEnum unknownDefaultOpenApi = _$registerMobileDeviceDtoPlatformEnum_unknownDefaultOpenApi;

  static Serializer<RegisterMobileDeviceDtoPlatformEnum> get serializer => _$registerMobileDeviceDtoPlatformEnumSerializer;

  const RegisterMobileDeviceDtoPlatformEnum._(String name): super(name);

  static BuiltSet<RegisterMobileDeviceDtoPlatformEnum> get values => _$registerMobileDeviceDtoPlatformEnumValues;
  static RegisterMobileDeviceDtoPlatformEnum valueOf(String name) => _$registerMobileDeviceDtoPlatformEnumValueOf(name);
}
