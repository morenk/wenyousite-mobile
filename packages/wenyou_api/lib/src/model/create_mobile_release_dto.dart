//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_mobile_release_dto.g.dart';

/// CreateMobileReleaseDto
///
/// Properties:
/// * [platform]
/// * [versionName]
/// * [buildNumber]
/// * [summary]
/// * [items]
@BuiltValue()
abstract class CreateMobileReleaseDto implements Built<CreateMobileReleaseDto, CreateMobileReleaseDtoBuilder> {
  @BuiltValueField(wireName: r'platform')
  CreateMobileReleaseDtoPlatformEnum get platform;
  // enum platformEnum {  android,  };

  @BuiltValueField(wireName: r'versionName')
  String get versionName;

  @BuiltValueField(wireName: r'buildNumber')
  num get buildNumber;

  @BuiltValueField(wireName: r'summary')
  String get summary;

  @BuiltValueField(wireName: r'items')
  BuiltList<String> get items;

  CreateMobileReleaseDto._();

  factory CreateMobileReleaseDto([void updates(CreateMobileReleaseDtoBuilder b)]) = _$CreateMobileReleaseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateMobileReleaseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateMobileReleaseDto> get serializer => _$CreateMobileReleaseDtoSerializer();
}

class _$CreateMobileReleaseDtoSerializer implements PrimitiveSerializer<CreateMobileReleaseDto> {
  @override
  final Iterable<Type> types = const [CreateMobileReleaseDto, _$CreateMobileReleaseDto];

  @override
  final String wireName = r'CreateMobileReleaseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateMobileReleaseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(CreateMobileReleaseDtoPlatformEnum),
    );
    yield r'versionName';
    yield serializers.serialize(
      object.versionName,
      specifiedType: const FullType(String),
    );
    yield r'buildNumber';
    yield serializers.serialize(
      object.buildNumber,
      specifiedType: const FullType(num),
    );
    yield r'summary';
    yield serializers.serialize(
      object.summary,
      specifiedType: const FullType(String),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateMobileReleaseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateMobileReleaseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateMobileReleaseDtoPlatformEnum),
          ) as CreateMobileReleaseDtoPlatformEnum;
          result.platform = valueDes;
          break;
        case r'versionName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.versionName = valueDes;
          break;
        case r'buildNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.buildNumber = valueDes;
          break;
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.summary = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateMobileReleaseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateMobileReleaseDtoBuilder();
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

class CreateMobileReleaseDtoPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'android')
  static const CreateMobileReleaseDtoPlatformEnum android = _$createMobileReleaseDtoPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateMobileReleaseDtoPlatformEnum unknownDefaultOpenApi = _$createMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi;

  static Serializer<CreateMobileReleaseDtoPlatformEnum> get serializer => _$createMobileReleaseDtoPlatformEnumSerializer;

  const CreateMobileReleaseDtoPlatformEnum._(String name): super(name);

  static BuiltSet<CreateMobileReleaseDtoPlatformEnum> get values => _$createMobileReleaseDtoPlatformEnumValues;
  static CreateMobileReleaseDtoPlatformEnum valueOf(String name) => _$createMobileReleaseDtoPlatformEnumValueOf(name);
}
