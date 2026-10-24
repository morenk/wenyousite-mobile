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
/// * [maxRequests] - 包含元数据、通知文件、失败和重试的请求预留次数
/// * [maxBytes] - 窗口预留字节；所有当前分片与通知均使用此额度
/// * [maxConcurrent]
/// * [timeoutMode] - 仅非空正文数据块重置 idle；响应头及空块不算进度，排队不计时
/// * [timeoutMs] - 实际请求开始后等待首个有效字节、以及连续无有效字节进度的时限；不是总传输时限
/// * [maxTransferMs] - 从实际请求开始到响应体结束的独立总时限，持续有进度也不得续期；元数据与字体均适用
@BuiltValue()
abstract class FontNetworkWindowDto implements Built<FontNetworkWindowDto, FontNetworkWindowDtoBuilder> {
  /// 滚动时间窗口；续额不重置驻留或原生注册账本
  @BuiltValueField(wireName: r'windowMs')
  FontNetworkWindowDtoWindowMsEnum get windowMs;
  // enum windowMsEnum {  60000,  };

  /// 包含元数据、通知文件、失败和重试的请求预留次数
  @BuiltValueField(wireName: r'maxRequests')
  FontNetworkWindowDtoMaxRequestsEnum get maxRequests;
  // enum maxRequestsEnum {  64,  };

  /// 窗口预留字节；所有当前分片与通知均使用此额度
  @BuiltValueField(wireName: r'maxBytes')
  int get maxBytes;

  @BuiltValueField(wireName: r'maxConcurrent')
  FontNetworkWindowDtoMaxConcurrentEnum get maxConcurrent;
  // enum maxConcurrentEnum {  1,  2,  };

  /// 仅非空正文数据块重置 idle；响应头及空块不算进度，排队不计时
  @BuiltValueField(wireName: r'timeoutMode')
  FontNetworkWindowDtoTimeoutModeEnum get timeoutMode;
  // enum timeoutModeEnum {  idle-with-total-cap,  };

  /// 实际请求开始后等待首个有效字节、以及连续无有效字节进度的时限；不是总传输时限
  @BuiltValueField(wireName: r'timeoutMs')
  FontNetworkWindowDtoTimeoutMsEnum get timeoutMs;
  // enum timeoutMsEnum {  15000,  };

  /// 从实际请求开始到响应体结束的独立总时限，持续有进度也不得续期；元数据与字体均适用
  @BuiltValueField(wireName: r'maxTransferMs')
  FontNetworkWindowDtoMaxTransferMsEnum get maxTransferMs;
  // enum maxTransferMsEnum {  600000,  };

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
    yield r'maxConcurrent';
    yield serializers.serialize(
      object.maxConcurrent,
      specifiedType: const FullType(FontNetworkWindowDtoMaxConcurrentEnum),
    );
    yield r'timeoutMode';
    yield serializers.serialize(
      object.timeoutMode,
      specifiedType: const FullType(FontNetworkWindowDtoTimeoutModeEnum),
    );
    yield r'timeoutMs';
    yield serializers.serialize(
      object.timeoutMs,
      specifiedType: const FullType(FontNetworkWindowDtoTimeoutMsEnum),
    );
    yield r'maxTransferMs';
    yield serializers.serialize(
      object.maxTransferMs,
      specifiedType: const FullType(FontNetworkWindowDtoMaxTransferMsEnum),
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
        case r'maxConcurrent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontNetworkWindowDtoMaxConcurrentEnum),
          ) as FontNetworkWindowDtoMaxConcurrentEnum;
          result.maxConcurrent = valueDes;
          break;
        case r'timeoutMode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontNetworkWindowDtoTimeoutModeEnum),
          ) as FontNetworkWindowDtoTimeoutModeEnum;
          result.timeoutMode = valueDes;
          break;
        case r'timeoutMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontNetworkWindowDtoTimeoutMsEnum),
          ) as FontNetworkWindowDtoTimeoutMsEnum;
          result.timeoutMs = valueDes;
          break;
        case r'maxTransferMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontNetworkWindowDtoMaxTransferMsEnum),
          ) as FontNetworkWindowDtoMaxTransferMsEnum;
          result.maxTransferMs = valueDes;
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

  /// 包含元数据、通知文件、失败和重试的请求预留次数
  @BuiltValueEnumConst(wireName: r'64')
  static const FontNetworkWindowDtoMaxRequestsEnum n64 = _$fontNetworkWindowDtoMaxRequestsEnum_n64;
  /// 包含元数据、通知文件、失败和重试的请求预留次数
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontNetworkWindowDtoMaxRequestsEnum unknownDefaultOpenApi = _$fontNetworkWindowDtoMaxRequestsEnum_unknownDefaultOpenApi;

  static Serializer<FontNetworkWindowDtoMaxRequestsEnum> get serializer => _$fontNetworkWindowDtoMaxRequestsEnumSerializer;

  const FontNetworkWindowDtoMaxRequestsEnum._(String name): super(name);

  static BuiltSet<FontNetworkWindowDtoMaxRequestsEnum> get values => _$fontNetworkWindowDtoMaxRequestsEnumValues;
  static FontNetworkWindowDtoMaxRequestsEnum valueOf(String name) => _$fontNetworkWindowDtoMaxRequestsEnumValueOf(name);
}

class FontNetworkWindowDtoMaxConcurrentEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 1)
  static const FontNetworkWindowDtoMaxConcurrentEnum n1 = _$fontNetworkWindowDtoMaxConcurrentEnum_n1;
  @BuiltValueEnumConst(wireNumber: 2)
  static const FontNetworkWindowDtoMaxConcurrentEnum n2 = _$fontNetworkWindowDtoMaxConcurrentEnum_n2;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontNetworkWindowDtoMaxConcurrentEnum unknownDefaultOpenApi = _$fontNetworkWindowDtoMaxConcurrentEnum_unknownDefaultOpenApi;

  static Serializer<FontNetworkWindowDtoMaxConcurrentEnum> get serializer => _$fontNetworkWindowDtoMaxConcurrentEnumSerializer;

  const FontNetworkWindowDtoMaxConcurrentEnum._(String name): super(name);

  static BuiltSet<FontNetworkWindowDtoMaxConcurrentEnum> get values => _$fontNetworkWindowDtoMaxConcurrentEnumValues;
  static FontNetworkWindowDtoMaxConcurrentEnum valueOf(String name) => _$fontNetworkWindowDtoMaxConcurrentEnumValueOf(name);
}

class FontNetworkWindowDtoTimeoutModeEnum extends EnumClass {

  /// 仅非空正文数据块重置 idle；响应头及空块不算进度，排队不计时
  @BuiltValueEnumConst(wireName: r'idle-with-total-cap')
  static const FontNetworkWindowDtoTimeoutModeEnum idleWithTotalCap = _$fontNetworkWindowDtoTimeoutModeEnum_idleWithTotalCap;
  /// 仅非空正文数据块重置 idle；响应头及空块不算进度，排队不计时
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontNetworkWindowDtoTimeoutModeEnum unknownDefaultOpenApi = _$fontNetworkWindowDtoTimeoutModeEnum_unknownDefaultOpenApi;

  static Serializer<FontNetworkWindowDtoTimeoutModeEnum> get serializer => _$fontNetworkWindowDtoTimeoutModeEnumSerializer;

  const FontNetworkWindowDtoTimeoutModeEnum._(String name): super(name);

  static BuiltSet<FontNetworkWindowDtoTimeoutModeEnum> get values => _$fontNetworkWindowDtoTimeoutModeEnumValues;
  static FontNetworkWindowDtoTimeoutModeEnum valueOf(String name) => _$fontNetworkWindowDtoTimeoutModeEnumValueOf(name);
}

class FontNetworkWindowDtoTimeoutMsEnum extends EnumClass {

  /// 实际请求开始后等待首个有效字节、以及连续无有效字节进度的时限；不是总传输时限
  @BuiltValueEnumConst(wireName: r'15000')
  static const FontNetworkWindowDtoTimeoutMsEnum n15000 = _$fontNetworkWindowDtoTimeoutMsEnum_n15000;
  /// 实际请求开始后等待首个有效字节、以及连续无有效字节进度的时限；不是总传输时限
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontNetworkWindowDtoTimeoutMsEnum unknownDefaultOpenApi = _$fontNetworkWindowDtoTimeoutMsEnum_unknownDefaultOpenApi;

  static Serializer<FontNetworkWindowDtoTimeoutMsEnum> get serializer => _$fontNetworkWindowDtoTimeoutMsEnumSerializer;

  const FontNetworkWindowDtoTimeoutMsEnum._(String name): super(name);

  static BuiltSet<FontNetworkWindowDtoTimeoutMsEnum> get values => _$fontNetworkWindowDtoTimeoutMsEnumValues;
  static FontNetworkWindowDtoTimeoutMsEnum valueOf(String name) => _$fontNetworkWindowDtoTimeoutMsEnumValueOf(name);
}

class FontNetworkWindowDtoMaxTransferMsEnum extends EnumClass {

  /// 从实际请求开始到响应体结束的独立总时限，持续有进度也不得续期；元数据与字体均适用
  @BuiltValueEnumConst(wireName: r'600000')
  static const FontNetworkWindowDtoMaxTransferMsEnum n600000 = _$fontNetworkWindowDtoMaxTransferMsEnum_n600000;
  /// 从实际请求开始到响应体结束的独立总时限，持续有进度也不得续期；元数据与字体均适用
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontNetworkWindowDtoMaxTransferMsEnum unknownDefaultOpenApi = _$fontNetworkWindowDtoMaxTransferMsEnum_unknownDefaultOpenApi;

  static Serializer<FontNetworkWindowDtoMaxTransferMsEnum> get serializer => _$fontNetworkWindowDtoMaxTransferMsEnumSerializer;

  const FontNetworkWindowDtoMaxTransferMsEnum._(String name): super(name);

  static BuiltSet<FontNetworkWindowDtoMaxTransferMsEnum> get values => _$fontNetworkWindowDtoMaxTransferMsEnumValues;
  static FontNetworkWindowDtoMaxTransferMsEnum valueOf(String name) => _$fontNetworkWindowDtoMaxTransferMsEnumValueOf(name);
}
