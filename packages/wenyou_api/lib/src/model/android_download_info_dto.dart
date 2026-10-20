//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/android_download_release_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'android_download_info_dto.g.dart';

/// AndroidDownloadInfoDto
///
/// Properties:
/// * [status]
/// * [release] - 仅 available 含已校验制品，其余状态为 null
/// * [retryAfterSeconds] - 建议等待秒数，无确定重试时间为 null
@BuiltValue()
abstract class AndroidDownloadInfoDto implements Built<AndroidDownloadInfoDto, AndroidDownloadInfoDtoBuilder> {
  @BuiltValueField(wireName: r'status')
  AndroidDownloadInfoDtoStatusEnum get status;
  // enum statusEnum {  available,  no_release,  withdrawn,  paused,  unavailable,  };

  /// 仅 available 含已校验制品，其余状态为 null
  @BuiltValueField(wireName: r'release')
  AndroidDownloadReleaseDto? get release;

  /// 建议等待秒数，无确定重试时间为 null
  @BuiltValueField(wireName: r'retryAfterSeconds')
  int? get retryAfterSeconds;

  AndroidDownloadInfoDto._();

  factory AndroidDownloadInfoDto([void updates(AndroidDownloadInfoDtoBuilder b)]) = _$AndroidDownloadInfoDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AndroidDownloadInfoDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AndroidDownloadInfoDto> get serializer => _$AndroidDownloadInfoDtoSerializer();
}

class _$AndroidDownloadInfoDtoSerializer implements PrimitiveSerializer<AndroidDownloadInfoDto> {
  @override
  final Iterable<Type> types = const [AndroidDownloadInfoDto, _$AndroidDownloadInfoDto];

  @override
  final String wireName = r'AndroidDownloadInfoDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AndroidDownloadInfoDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AndroidDownloadInfoDtoStatusEnum),
    );
    yield r'release';
    yield object.release == null ? null : serializers.serialize(
      object.release,
      specifiedType: const FullType.nullable(AndroidDownloadReleaseDto),
    );
    yield r'retryAfterSeconds';
    yield object.retryAfterSeconds == null ? null : serializers.serialize(
      object.retryAfterSeconds,
      specifiedType: const FullType.nullable(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AndroidDownloadInfoDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AndroidDownloadInfoDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AndroidDownloadInfoDtoStatusEnum),
          ) as AndroidDownloadInfoDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'release':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AndroidDownloadReleaseDto),
          ) as AndroidDownloadReleaseDto?;
          if (valueDes == null) continue;
          result.release.replace(valueDes);
          break;
        case r'retryAfterSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.retryAfterSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AndroidDownloadInfoDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AndroidDownloadInfoDtoBuilder();
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

class AndroidDownloadInfoDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'available')
  static const AndroidDownloadInfoDtoStatusEnum available = _$androidDownloadInfoDtoStatusEnum_available;
  @BuiltValueEnumConst(wireName: r'no_release')
  static const AndroidDownloadInfoDtoStatusEnum noRelease = _$androidDownloadInfoDtoStatusEnum_noRelease;
  @BuiltValueEnumConst(wireName: r'withdrawn')
  static const AndroidDownloadInfoDtoStatusEnum withdrawn = _$androidDownloadInfoDtoStatusEnum_withdrawn;
  @BuiltValueEnumConst(wireName: r'paused')
  static const AndroidDownloadInfoDtoStatusEnum paused = _$androidDownloadInfoDtoStatusEnum_paused;
  @BuiltValueEnumConst(wireName: r'unavailable')
  static const AndroidDownloadInfoDtoStatusEnum unavailable = _$androidDownloadInfoDtoStatusEnum_unavailable;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AndroidDownloadInfoDtoStatusEnum unknownDefaultOpenApi = _$androidDownloadInfoDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<AndroidDownloadInfoDtoStatusEnum> get serializer => _$androidDownloadInfoDtoStatusEnumSerializer;

  const AndroidDownloadInfoDtoStatusEnum._(String name): super(name);

  static BuiltSet<AndroidDownloadInfoDtoStatusEnum> get values => _$androidDownloadInfoDtoStatusEnumValues;
  static AndroidDownloadInfoDtoStatusEnum valueOf(String name) => _$androidDownloadInfoDtoStatusEnumValueOf(name);
}
