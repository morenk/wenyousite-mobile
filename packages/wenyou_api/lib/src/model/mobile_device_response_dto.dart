//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mobile_device_response_dto.g.dart';

/// MobileDeviceResponseDto
///
/// Properties:
/// * [id]
/// * [platform]
/// * [appVersion]
/// * [locale]
/// * [enabled]
/// * [lastSeenAt]
@BuiltValue()
abstract class MobileDeviceResponseDto implements Built<MobileDeviceResponseDto, MobileDeviceResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'platform')
  MobileDeviceResponseDtoPlatformEnum get platform;
  // enum platformEnum {  android,  ios,  };

  @BuiltValueField(wireName: r'appVersion')
  String? get appVersion;

  @BuiltValueField(wireName: r'locale')
  String? get locale;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'lastSeenAt')
  DateTime get lastSeenAt;

  MobileDeviceResponseDto._();

  factory MobileDeviceResponseDto([void updates(MobileDeviceResponseDtoBuilder b)]) = _$MobileDeviceResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MobileDeviceResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MobileDeviceResponseDto> get serializer => _$MobileDeviceResponseDtoSerializer();
}

class _$MobileDeviceResponseDtoSerializer implements PrimitiveSerializer<MobileDeviceResponseDto> {
  @override
  final Iterable<Type> types = const [MobileDeviceResponseDto, _$MobileDeviceResponseDto];

  @override
  final String wireName = r'MobileDeviceResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MobileDeviceResponseDto object, {
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
      specifiedType: const FullType(MobileDeviceResponseDtoPlatformEnum),
    );
    yield r'appVersion';
    yield object.appVersion == null ? null : serializers.serialize(
      object.appVersion,
      specifiedType: const FullType.nullable(String),
    );
    yield r'locale';
    yield object.locale == null ? null : serializers.serialize(
      object.locale,
      specifiedType: const FullType.nullable(String),
    );
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'lastSeenAt';
    yield serializers.serialize(
      object.lastSeenAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MobileDeviceResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MobileDeviceResponseDtoBuilder result,
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
            specifiedType: const FullType(MobileDeviceResponseDtoPlatformEnum),
          ) as MobileDeviceResponseDtoPlatformEnum;
          result.platform = valueDes;
          break;
        case r'appVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appVersion = valueDes;
          break;
        case r'locale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.locale = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'lastSeenAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastSeenAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MobileDeviceResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MobileDeviceResponseDtoBuilder();
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

class MobileDeviceResponseDtoPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'android')
  static const MobileDeviceResponseDtoPlatformEnum android = _$mobileDeviceResponseDtoPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'ios')
  static const MobileDeviceResponseDtoPlatformEnum ios = _$mobileDeviceResponseDtoPlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const MobileDeviceResponseDtoPlatformEnum unknownDefaultOpenApi = _$mobileDeviceResponseDtoPlatformEnum_unknownDefaultOpenApi;

  static Serializer<MobileDeviceResponseDtoPlatformEnum> get serializer => _$mobileDeviceResponseDtoPlatformEnumSerializer;

  const MobileDeviceResponseDtoPlatformEnum._(String name): super(name);

  static BuiltSet<MobileDeviceResponseDtoPlatformEnum> get values => _$mobileDeviceResponseDtoPlatformEnumValues;
  static MobileDeviceResponseDtoPlatformEnum valueOf(String name) => _$mobileDeviceResponseDtoPlatformEnumValueOf(name);
}
