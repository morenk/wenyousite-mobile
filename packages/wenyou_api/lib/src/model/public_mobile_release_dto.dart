//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'public_mobile_release_dto.g.dart';

/// PublicMobileReleaseDto
///
/// Properties:
/// * [platform]
/// * [versionName]
/// * [buildNumber]
/// * [summary]
/// * [items]
/// * [revision]
/// * [publishedAt]
@BuiltValue()
abstract class PublicMobileReleaseDto implements Built<PublicMobileReleaseDto, PublicMobileReleaseDtoBuilder> {
  @BuiltValueField(wireName: r'platform')
  PublicMobileReleaseDtoPlatformEnum get platform;
  // enum platformEnum {  android,  };

  @BuiltValueField(wireName: r'versionName')
  String get versionName;

  @BuiltValueField(wireName: r'buildNumber')
  num get buildNumber;

  @BuiltValueField(wireName: r'summary')
  String get summary;

  @BuiltValueField(wireName: r'items')
  BuiltList<String> get items;

  @BuiltValueField(wireName: r'revision')
  num get revision;

  @BuiltValueField(wireName: r'publishedAt')
  DateTime get publishedAt;

  PublicMobileReleaseDto._();

  factory PublicMobileReleaseDto([void updates(PublicMobileReleaseDtoBuilder b)]) = _$PublicMobileReleaseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PublicMobileReleaseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PublicMobileReleaseDto> get serializer => _$PublicMobileReleaseDtoSerializer();
}

class _$PublicMobileReleaseDtoSerializer implements PrimitiveSerializer<PublicMobileReleaseDto> {
  @override
  final Iterable<Type> types = const [PublicMobileReleaseDto, _$PublicMobileReleaseDto];

  @override
  final String wireName = r'PublicMobileReleaseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PublicMobileReleaseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(PublicMobileReleaseDtoPlatformEnum),
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
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(num),
    );
    yield r'publishedAt';
    yield serializers.serialize(
      object.publishedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PublicMobileReleaseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PublicMobileReleaseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PublicMobileReleaseDtoPlatformEnum),
          ) as PublicMobileReleaseDtoPlatformEnum;
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
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.revision = valueDes;
          break;
        case r'publishedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.publishedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PublicMobileReleaseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PublicMobileReleaseDtoBuilder();
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

class PublicMobileReleaseDtoPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'android')
  static const PublicMobileReleaseDtoPlatformEnum android = _$publicMobileReleaseDtoPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const PublicMobileReleaseDtoPlatformEnum unknownDefaultOpenApi = _$publicMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi;

  static Serializer<PublicMobileReleaseDtoPlatformEnum> get serializer => _$publicMobileReleaseDtoPlatformEnumSerializer;

  const PublicMobileReleaseDtoPlatformEnum._(String name): super(name);

  static BuiltSet<PublicMobileReleaseDtoPlatformEnum> get values => _$publicMobileReleaseDtoPlatformEnumValues;
  static PublicMobileReleaseDtoPlatformEnum valueOf(String name) => _$publicMobileReleaseDtoPlatformEnumValueOf(name);
}
