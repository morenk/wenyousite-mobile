//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_export_dto.g.dart';

/// ThreadExportDto
///
/// Properties:
/// * [format] - 导出格式：TXT、Markdown 或两者
/// * [includeAuthors] - 是否保留作者名
/// * [includeTimestamps] - 是否保留时间戳
/// * [includeFloorNumbers] - 是否保留楼层号
/// * [includeReplyTargets] - 是否保留回复目标
/// * [includeSourceLinks] - 是否保留站内来源链接；邀请链接始终脱敏
/// * [includeMedia] - 是否将站内媒体打包到 ZIP
@BuiltValue()
abstract class ThreadExportDto implements Built<ThreadExportDto, ThreadExportDtoBuilder> {
  /// 导出格式：TXT、Markdown 或两者
  @BuiltValueField(wireName: r'format')
  ThreadExportDtoFormatEnum? get format;
  // enum formatEnum {  TXT,  MARKDOWN,  BOTH,  };

  /// 是否保留作者名
  @BuiltValueField(wireName: r'includeAuthors')
  bool? get includeAuthors;

  /// 是否保留时间戳
  @BuiltValueField(wireName: r'includeTimestamps')
  bool? get includeTimestamps;

  /// 是否保留楼层号
  @BuiltValueField(wireName: r'includeFloorNumbers')
  bool? get includeFloorNumbers;

  /// 是否保留回复目标
  @BuiltValueField(wireName: r'includeReplyTargets')
  bool? get includeReplyTargets;

  /// 是否保留站内来源链接；邀请链接始终脱敏
  @BuiltValueField(wireName: r'includeSourceLinks')
  bool? get includeSourceLinks;

  /// 是否将站内媒体打包到 ZIP
  @BuiltValueField(wireName: r'includeMedia')
  bool? get includeMedia;

  ThreadExportDto._();

  factory ThreadExportDto([void updates(ThreadExportDtoBuilder b)]) = _$ThreadExportDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadExportDtoBuilder b) => b
      ..format = ThreadExportDtoFormatEnum.valueOf('BOTH')
      ..includeAuthors = true
      ..includeTimestamps = true
      ..includeFloorNumbers = true
      ..includeReplyTargets = true
      ..includeSourceLinks = false
      ..includeMedia = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadExportDto> get serializer => _$ThreadExportDtoSerializer();
}

class _$ThreadExportDtoSerializer implements PrimitiveSerializer<ThreadExportDto> {
  @override
  final Iterable<Type> types = const [ThreadExportDto, _$ThreadExportDto];

  @override
  final String wireName = r'ThreadExportDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadExportDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.format != null) {
      yield r'format';
      yield serializers.serialize(
        object.format,
        specifiedType: const FullType(ThreadExportDtoFormatEnum),
      );
    }
    if (object.includeAuthors != null) {
      yield r'includeAuthors';
      yield serializers.serialize(
        object.includeAuthors,
        specifiedType: const FullType(bool),
      );
    }
    if (object.includeTimestamps != null) {
      yield r'includeTimestamps';
      yield serializers.serialize(
        object.includeTimestamps,
        specifiedType: const FullType(bool),
      );
    }
    if (object.includeFloorNumbers != null) {
      yield r'includeFloorNumbers';
      yield serializers.serialize(
        object.includeFloorNumbers,
        specifiedType: const FullType(bool),
      );
    }
    if (object.includeReplyTargets != null) {
      yield r'includeReplyTargets';
      yield serializers.serialize(
        object.includeReplyTargets,
        specifiedType: const FullType(bool),
      );
    }
    if (object.includeSourceLinks != null) {
      yield r'includeSourceLinks';
      yield serializers.serialize(
        object.includeSourceLinks,
        specifiedType: const FullType(bool),
      );
    }
    if (object.includeMedia != null) {
      yield r'includeMedia';
      yield serializers.serialize(
        object.includeMedia,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadExportDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadExportDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadExportDtoFormatEnum),
          ) as ThreadExportDtoFormatEnum;
          result.format = valueDes;
          break;
        case r'includeAuthors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.includeAuthors = valueDes;
          break;
        case r'includeTimestamps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.includeTimestamps = valueDes;
          break;
        case r'includeFloorNumbers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.includeFloorNumbers = valueDes;
          break;
        case r'includeReplyTargets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.includeReplyTargets = valueDes;
          break;
        case r'includeSourceLinks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.includeSourceLinks = valueDes;
          break;
        case r'includeMedia':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.includeMedia = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadExportDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadExportDtoBuilder();
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

class ThreadExportDtoFormatEnum extends EnumClass {

  /// 导出格式：TXT、Markdown 或两者
  @BuiltValueEnumConst(wireName: r'TXT')
  static const ThreadExportDtoFormatEnum TXT = _$threadExportDtoFormatEnum_TXT;
  /// 导出格式：TXT、Markdown 或两者
  @BuiltValueEnumConst(wireName: r'MARKDOWN')
  static const ThreadExportDtoFormatEnum MARKDOWN = _$threadExportDtoFormatEnum_MARKDOWN;
  /// 导出格式：TXT、Markdown 或两者
  @BuiltValueEnumConst(wireName: r'BOTH')
  static const ThreadExportDtoFormatEnum BOTH = _$threadExportDtoFormatEnum_BOTH;
  /// 导出格式：TXT、Markdown 或两者
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ThreadExportDtoFormatEnum unknownDefaultOpenApi = _$threadExportDtoFormatEnum_unknownDefaultOpenApi;

  static Serializer<ThreadExportDtoFormatEnum> get serializer => _$threadExportDtoFormatEnumSerializer;

  const ThreadExportDtoFormatEnum._(String name): super(name);

  static BuiltSet<ThreadExportDtoFormatEnum> get values => _$threadExportDtoFormatEnumValues;
  static ThreadExportDtoFormatEnum valueOf(String name) => _$threadExportDtoFormatEnumValueOf(name);
}
