//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_network_window_dto.g.dart';

/// FontNetworkWindowDto
///
/// Properties:
/// * [windowMs] - 滚动时间窗口；续额不重置驻留或原生注册账本
/// * [maxRequests] - 包含元数据、通知文件、原件、失败和重试的请求预留次数
/// * [maxBytes] - 普通窗口预留字节；Mobile 原件计入此额度，Web 原件使用独立额度
/// * [originalWindowBytes] - Web 原件独立额度；Mobile 固定 0，原件计入普通 24 MiB。失败不即时退款，窗口到期可再尝试
/// * [maxConcurrent]
/// * [timeoutMs]
@BuiltValue()
abstract class FontNetworkWindowDto implements Built<FontNetworkWindowDto, FontNetworkWindowDtoBuilder> {
  /// 滚动时间窗口；续额不重置驻留或原生注册账本
  @BuiltValueField(wireName: r'windowMs')
  FontNetworkWindowDtoWindowMsEnum get windowMs;
  // enum windowMsEnum {  60000,  };

  /// 包含元数据、通知文件、原件、失败和重试的请求预留次数
  @BuiltValueField(wireName: r'maxRequests')
  FontNetworkWindowDtoMaxRequestsEnum get maxRequests;
  // enum maxRequestsEnum {  64,  };

  /// 普通窗口预留字节；Mobile 原件计入此额度，Web 原件使用独立额度
  @BuiltValueField(wireName: r'maxBytes')
  int get maxBytes;

  /// Web 原件独立额度；Mobile 固定 0，原件计入普通 24 MiB。失败不即时退款，窗口到期可再尝试
  @BuiltValueField(wireName: r'originalWindowBytes')
  FontNetworkWindowDtoOriginalWindowBytesEnum get originalWindowBytes;
  // enum originalWindowBytesEnum {  0,  18410600,  };

  @BuiltValueField(wireName: r'maxConcurrent')
  FontNetworkWindowDtoMaxConcurrentEnum get maxConcurrent;
  // enum maxConcurrentEnum {  1,  2,  };

  @BuiltValueField(wireName: r'timeoutMs')
  FontNetworkWindowDtoTimeoutMsEnum get timeoutMs;
  // enum timeoutMsEnum {  15000,  };

  FontNetworkWindowDto._();

  factory FontNetworkWindowDto([void updates(FontNetworkWindowDtoBuilder b)]) = _$FontNetworkWindowDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontNetworkWindowDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontNetworkWindowDto> get serializer => _$FontNetworkWindowDtoSerializer();
}

class _$FontNetworkWindowDtoSerializer implements PrimitiveSerializer<FontNetworkWindowDto> {
  @override
  final Iterable<Type> types = const [FontNetworkWindowDto, _$FontNetworkWindowDto];

  @override
  final String wireName = r'FontNetworkWindowDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontNetworkWindowDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'windowMs';
    yield serializers.serialize(
      object.windowMs,
      specifiedType: const FullType(FontNetworkWindowDtoWindowMsEnum),
    );
    yield r'maxRequests';
    yield serializers.serialize(
      object.maxRequests,
      specifiedType: const FullType(FontNetworkWindowDtoMaxRequestsEnum),
    );
    yield r'maxBytes';
    yield serializers.serialize(
      object.maxBytes,
      specifiedType: const FullType(int),
    );
    yield r'originalWindowBytes';
    yield serializers.serialize(
      object.originalWindowBytes,
      specifiedType: const FullType(FontNetworkWindowDtoOriginalWindowBytesEnum),
    );
    yield r'maxConcurrent';
    yield serializers.serialize(
      object.maxConcurrent,
      specifiedType: const FullType(FontNetworkWindowDtoMaxConcurrentEnum),
    );
    yield r'timeoutMs';
    yield serializers.serialize(
      object.timeoutMs,
      specifiedType: const FullType(FontNetworkWindowDtoTimeoutMsEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontNetworkWindowDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontNetworkWindowDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'windowMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontNetworkWindowDtoWindowMsEnum),
          ) as FontNetworkWindowDtoWindowMsEnum;
          result.windowMs = valueDes;
          break;
        case r'maxRequests':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontNetworkWindowDtoMaxRequestsEnum),
          ) as FontNetworkWindowDtoMaxRequestsEnum;
          result.maxRequests = valueDes;
          break;
        case r'maxBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maxBytes = valueDes;
          break;
        case r'originalWindowBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontNetworkWindowDtoOriginalWindowBytesEnum),
          ) as FontNetworkWindowDtoOriginalWindowBytesEnum;
          result.originalWindowBytes = valueDes;
          break;
        case r'maxConcurrent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontNetworkWindowDtoMaxConcurrentEnum),
          ) as FontNetworkWindowDtoMaxConcurrentEnum;
          result.maxConcurrent = valueDes;
          break;
        case r'timeoutMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontNetworkWindowDtoTimeoutMsEnum),
          ) as FontNetworkWindowDtoTimeoutMsEnum;
          result.timeoutMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontNetworkWindowDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontNetworkWindowDtoBuilder();
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

class FontNetworkWindowDtoWindowMsEnum extends EnumClass {

  /// 滚动时间窗口；续额不重置驻留或原生注册账本
  @BuiltValueEnumConst(wireName: r'60000')
  static const FontNetworkWindowDtoWindowMsEnum n60000 = _$fontNetworkWindowDtoWindowMsEnum_n60000;
  /// 滚动时间窗口；续额不重置驻留或原生注册账本
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontNetworkWindowDtoWindowMsEnum unknownDefaultOpenApi = _$fontNetworkWindowDtoWindowMsEnum_unknownDefaultOpenApi;

  static Serializer<FontNetworkWindowDtoWindowMsEnum> get serializer => _$fontNetworkWindowDtoWindowMsEnumSerializer;

  const FontNetworkWindowDtoWindowMsEnum._(String name): super(name);

  static BuiltSet<FontNetworkWindowDtoWindowMsEnum> get values => _$fontNetworkWindowDtoWindowMsEnumValues;
  static FontNetworkWindowDtoWindowMsEnum valueOf(String name) => _$fontNetworkWindowDtoWindowMsEnumValueOf(name);
}

class FontNetworkWindowDtoMaxRequestsEnum extends EnumClass {

  /// 包含元数据、通知文件、原件、失败和重试的请求预留次数
  @BuiltValueEnumConst(wireName: r'64')
  static const FontNetworkWindowDtoMaxRequestsEnum n64 = _$fontNetworkWindowDtoMaxRequestsEnum_n64;
  /// 包含元数据、通知文件、原件、失败和重试的请求预留次数
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontNetworkWindowDtoMaxRequestsEnum unknownDefaultOpenApi = _$fontNetworkWindowDtoMaxRequestsEnum_unknownDefaultOpenApi;

  static Serializer<FontNetworkWindowDtoMaxRequestsEnum> get serializer => _$fontNetworkWindowDtoMaxRequestsEnumSerializer;

  const FontNetworkWindowDtoMaxRequestsEnum._(String name): super(name);

  static BuiltSet<FontNetworkWindowDtoMaxRequestsEnum> get values => _$fontNetworkWindowDtoMaxRequestsEnumValues;
  static FontNetworkWindowDtoMaxRequestsEnum valueOf(String name) => _$fontNetworkWindowDtoMaxRequestsEnumValueOf(name);
}

class FontNetworkWindowDtoOriginalWindowBytesEnum extends EnumClass {

  /// Web 原件独立额度；Mobile 固定 0，原件计入普通 24 MiB。失败不即时退款，窗口到期可再尝试
  @BuiltValueEnumConst(wireName: r'0')
  static const FontNetworkWindowDtoOriginalWindowBytesEnum n0 = _$fontNetworkWindowDtoOriginalWindowBytesEnum_n0;
  /// Web 原件独立额度；Mobile 固定 0，原件计入普通 24 MiB。失败不即时退款，窗口到期可再尝试
  @BuiltValueEnumConst(wireName: r'18410600')
  static const FontNetworkWindowDtoOriginalWindowBytesEnum n18410600 = _$fontNetworkWindowDtoOriginalWindowBytesEnum_n18410600;
  /// Web 原件独立额度；Mobile 固定 0，原件计入普通 24 MiB。失败不即时退款，窗口到期可再尝试
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontNetworkWindowDtoOriginalWindowBytesEnum unknownDefaultOpenApi = _$fontNetworkWindowDtoOriginalWindowBytesEnum_unknownDefaultOpenApi;

  static Serializer<FontNetworkWindowDtoOriginalWindowBytesEnum> get serializer => _$fontNetworkWindowDtoOriginalWindowBytesEnumSerializer;

  const FontNetworkWindowDtoOriginalWindowBytesEnum._(String name): super(name);

  static BuiltSet<FontNetworkWindowDtoOriginalWindowBytesEnum> get values => _$fontNetworkWindowDtoOriginalWindowBytesEnumValues;
  static FontNetworkWindowDtoOriginalWindowBytesEnum valueOf(String name) => _$fontNetworkWindowDtoOriginalWindowBytesEnumValueOf(name);
}

class FontNetworkWindowDtoMaxConcurrentEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'1')
  static const FontNetworkWindowDtoMaxConcurrentEnum n1 = _$fontNetworkWindowDtoMaxConcurrentEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const FontNetworkWindowDtoMaxConcurrentEnum n2 = _$fontNetworkWindowDtoMaxConcurrentEnum_n2;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontNetworkWindowDtoMaxConcurrentEnum unknownDefaultOpenApi = _$fontNetworkWindowDtoMaxConcurrentEnum_unknownDefaultOpenApi;

  static Serializer<FontNetworkWindowDtoMaxConcurrentEnum> get serializer => _$fontNetworkWindowDtoMaxConcurrentEnumSerializer;

  const FontNetworkWindowDtoMaxConcurrentEnum._(String name): super(name);

  static BuiltSet<FontNetworkWindowDtoMaxConcurrentEnum> get values => _$fontNetworkWindowDtoMaxConcurrentEnumValues;
  static FontNetworkWindowDtoMaxConcurrentEnum valueOf(String name) => _$fontNetworkWindowDtoMaxConcurrentEnumValueOf(name);
}

class FontNetworkWindowDtoTimeoutMsEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'15000')
  static const FontNetworkWindowDtoTimeoutMsEnum n15000 = _$fontNetworkWindowDtoTimeoutMsEnum_n15000;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontNetworkWindowDtoTimeoutMsEnum unknownDefaultOpenApi = _$fontNetworkWindowDtoTimeoutMsEnum_unknownDefaultOpenApi;

  static Serializer<FontNetworkWindowDtoTimeoutMsEnum> get serializer => _$fontNetworkWindowDtoTimeoutMsEnumSerializer;

  const FontNetworkWindowDtoTimeoutMsEnum._(String name): super(name);

  static BuiltSet<FontNetworkWindowDtoTimeoutMsEnum> get values => _$fontNetworkWindowDtoTimeoutMsEnumValues;
  static FontNetworkWindowDtoTimeoutMsEnum valueOf(String name) => _$fontNetworkWindowDtoTimeoutMsEnumValueOf(name);
}
