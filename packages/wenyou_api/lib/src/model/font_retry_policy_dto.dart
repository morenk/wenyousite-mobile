//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_retry_policy_dto.g.dart';

/// FontRetryPolicyDto
///
/// Properties:
/// * [delayCeilingsMs] - 第 n 次连续暂时失败的抖动上限；末项持续复用，成功后清零
/// * [jitter] - floor(U×(ceiling+1))，U∈[0,1)；Retry-After 与窗口等待取更晚时间
/// * [retryableHttpStatuses] - 仅 408、429、500、502、503、504 视为暂时 HTTP 错误
/// * [retryNetworkErrors]
/// * [retryTimeouts]
/// * [respectRetryAfter]
@BuiltValue()
abstract class FontRetryPolicyDto implements Built<FontRetryPolicyDto, FontRetryPolicyDtoBuilder> {
  /// 第 n 次连续暂时失败的抖动上限；末项持续复用，成功后清零
  @BuiltValueField(wireName: r'delayCeilingsMs')
  BuiltList<num> get delayCeilingsMs;

  /// floor(U×(ceiling+1))，U∈[0,1)；Retry-After 与窗口等待取更晚时间
  @BuiltValueField(wireName: r'jitter')
  FontRetryPolicyDtoJitterEnum get jitter;
  // enum jitterEnum {  full,  };

  /// 仅 408、429、500、502、503、504 视为暂时 HTTP 错误
  @BuiltValueField(wireName: r'retryableHttpStatuses')
  BuiltList<num> get retryableHttpStatuses;

  @BuiltValueField(wireName: r'retryNetworkErrors')
  bool get retryNetworkErrors;

  @BuiltValueField(wireName: r'retryTimeouts')
  bool get retryTimeouts;

  @BuiltValueField(wireName: r'respectRetryAfter')
  bool get respectRetryAfter;

  FontRetryPolicyDto._();

  factory FontRetryPolicyDto([void updates(FontRetryPolicyDtoBuilder b)]) = _$FontRetryPolicyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontRetryPolicyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontRetryPolicyDto> get serializer => _$FontRetryPolicyDtoSerializer();
}

class _$FontRetryPolicyDtoSerializer implements PrimitiveSerializer<FontRetryPolicyDto> {
  @override
  final Iterable<Type> types = const [FontRetryPolicyDto, _$FontRetryPolicyDto];

  @override
  final String wireName = r'FontRetryPolicyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontRetryPolicyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'delayCeilingsMs';
    yield serializers.serialize(
      object.delayCeilingsMs,
      specifiedType: const FullType(BuiltList, [FullType(num)]),
    );
    yield r'jitter';
    yield serializers.serialize(
      object.jitter,
      specifiedType: const FullType(FontRetryPolicyDtoJitterEnum),
    );
    yield r'retryableHttpStatuses';
    yield serializers.serialize(
      object.retryableHttpStatuses,
      specifiedType: const FullType(BuiltList, [FullType(num)]),
    );
    yield r'retryNetworkErrors';
    yield serializers.serialize(
      object.retryNetworkErrors,
      specifiedType: const FullType(bool),
    );
    yield r'retryTimeouts';
    yield serializers.serialize(
      object.retryTimeouts,
      specifiedType: const FullType(bool),
    );
    yield r'respectRetryAfter';
    yield serializers.serialize(
      object.respectRetryAfter,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontRetryPolicyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontRetryPolicyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'delayCeilingsMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(num)]),
          ) as BuiltList<num>;
          result.delayCeilingsMs.replace(valueDes);
          break;
        case r'jitter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontRetryPolicyDtoJitterEnum),
          ) as FontRetryPolicyDtoJitterEnum;
          result.jitter = valueDes;
          break;
        case r'retryableHttpStatuses':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(num)]),
          ) as BuiltList<num>;
          result.retryableHttpStatuses.replace(valueDes);
          break;
        case r'retryNetworkErrors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.retryNetworkErrors = valueDes;
          break;
        case r'retryTimeouts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.retryTimeouts = valueDes;
          break;
        case r'respectRetryAfter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.respectRetryAfter = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontRetryPolicyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontRetryPolicyDtoBuilder();
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

class FontRetryPolicyDtoJitterEnum extends EnumClass {

  /// floor(U×(ceiling+1))，U∈[0,1)；Retry-After 与窗口等待取更晚时间
  @BuiltValueEnumConst(wireName: r'full')
  static const FontRetryPolicyDtoJitterEnum full = _$fontRetryPolicyDtoJitterEnum_full;
  /// floor(U×(ceiling+1))，U∈[0,1)；Retry-After 与窗口等待取更晚时间
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontRetryPolicyDtoJitterEnum unknownDefaultOpenApi = _$fontRetryPolicyDtoJitterEnum_unknownDefaultOpenApi;

  static Serializer<FontRetryPolicyDtoJitterEnum> get serializer => _$fontRetryPolicyDtoJitterEnumSerializer;

  const FontRetryPolicyDtoJitterEnum._(String name): super(name);

  static BuiltSet<FontRetryPolicyDtoJitterEnum> get values => _$fontRetryPolicyDtoJitterEnumValues;
  static FontRetryPolicyDtoJitterEnum valueOf(String name) => _$fontRetryPolicyDtoJitterEnumValueOf(name);
}
