//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'android_download_release_dto.g.dart';

/// AndroidDownloadReleaseDto
///
/// Properties:
/// * [platform]
/// * [applicationId]
/// * [versionName]
/// * [buildNumber]
/// * [sizeBytes]
/// * [sha256]
/// * [fileName]
/// * [publishedAt]
/// * [downloadUrl]
/// * [releaseNotesUrl]
@BuiltValue()
abstract class AndroidDownloadReleaseDto implements Built<AndroidDownloadReleaseDto, AndroidDownloadReleaseDtoBuilder> {
  @BuiltValueField(wireName: r'platform')
  AndroidDownloadReleaseDtoPlatformEnum get platform;
  // enum platformEnum {  android,  };

  @BuiltValueField(wireName: r'applicationId')
  String get applicationId;

  @BuiltValueField(wireName: r'versionName')
  String get versionName;

  @BuiltValueField(wireName: r'buildNumber')
  num get buildNumber;

  @BuiltValueField(wireName: r'sizeBytes')
  int get sizeBytes;

  @BuiltValueField(wireName: r'sha256')
  String get sha256;

  @BuiltValueField(wireName: r'fileName')
  String get fileName;

  @BuiltValueField(wireName: r'publishedAt')
  DateTime get publishedAt;

  @BuiltValueField(wireName: r'downloadUrl')
  String get downloadUrl;

  @BuiltValueField(wireName: r'releaseNotesUrl')
  String get releaseNotesUrl;

  AndroidDownloadReleaseDto._();

  factory AndroidDownloadReleaseDto([void updates(AndroidDownloadReleaseDtoBuilder b)]) = _$AndroidDownloadReleaseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AndroidDownloadReleaseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AndroidDownloadReleaseDto> get serializer => _$AndroidDownloadReleaseDtoSerializer();
}

class _$AndroidDownloadReleaseDtoSerializer implements PrimitiveSerializer<AndroidDownloadReleaseDto> {
  @override
  final Iterable<Type> types = const [AndroidDownloadReleaseDto, _$AndroidDownloadReleaseDto];

  @override
  final String wireName = r'AndroidDownloadReleaseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AndroidDownloadReleaseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(AndroidDownloadReleaseDtoPlatformEnum),
    );
    yield r'applicationId';
    yield serializers.serialize(
      object.applicationId,
      specifiedType: const FullType(String),
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
    yield r'sizeBytes';
    yield serializers.serialize(
      object.sizeBytes,
      specifiedType: const FullType(int),
    );
    yield r'sha256';
    yield serializers.serialize(
      object.sha256,
      specifiedType: const FullType(String),
    );
    yield r'fileName';
    yield serializers.serialize(
      object.fileName,
      specifiedType: const FullType(String),
    );
    yield r'publishedAt';
    yield serializers.serialize(
      object.publishedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'downloadUrl';
    yield serializers.serialize(
      object.downloadUrl,
      specifiedType: const FullType(String),
    );
    yield r'releaseNotesUrl';
    yield serializers.serialize(
      object.releaseNotesUrl,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AndroidDownloadReleaseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AndroidDownloadReleaseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AndroidDownloadReleaseDtoPlatformEnum),
          ) as AndroidDownloadReleaseDtoPlatformEnum;
          result.platform = valueDes;
          break;
        case r'applicationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.applicationId = valueDes;
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
        case r'sizeBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sizeBytes = valueDes;
          break;
        case r'sha256':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sha256 = valueDes;
          break;
        case r'fileName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fileName = valueDes;
          break;
        case r'publishedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.publishedAt = valueDes;
          break;
        case r'downloadUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.downloadUrl = valueDes;
          break;
        case r'releaseNotesUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.releaseNotesUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AndroidDownloadReleaseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AndroidDownloadReleaseDtoBuilder();
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

class AndroidDownloadReleaseDtoPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'android')
  static const AndroidDownloadReleaseDtoPlatformEnum android = _$androidDownloadReleaseDtoPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AndroidDownloadReleaseDtoPlatformEnum unknownDefaultOpenApi = _$androidDownloadReleaseDtoPlatformEnum_unknownDefaultOpenApi;

  static Serializer<AndroidDownloadReleaseDtoPlatformEnum> get serializer => _$androidDownloadReleaseDtoPlatformEnumSerializer;

  const AndroidDownloadReleaseDtoPlatformEnum._(String name): super(name);

  static BuiltSet<AndroidDownloadReleaseDtoPlatformEnum> get values => _$androidDownloadReleaseDtoPlatformEnumValues;
  static AndroidDownloadReleaseDtoPlatformEnum valueOf(String name) => _$androidDownloadReleaseDtoPlatformEnumValueOf(name);
}
