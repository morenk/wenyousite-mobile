//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_cover_preview_variant_response_dto.g.dart';

/// ThreadCoverPreviewVariantResponseDto
///
/// Properties:
/// * [url] - 已发布的不可变列表动画 WebP 地址；不用于替换正文原图 URL
/// * [width] - 单帧实际像素宽度
/// * [height] - 单帧实际像素高度
/// * [bytes] - 完整动画预览文件字节数
@BuiltValue()
abstract class ThreadCoverPreviewVariantResponseDto implements Built<ThreadCoverPreviewVariantResponseDto, ThreadCoverPreviewVariantResponseDtoBuilder> {
  /// 已发布的不可变列表动画 WebP 地址；不用于替换正文原图 URL
  @BuiltValueField(wireName: r'url')
  String get url;

  /// 单帧实际像素宽度
  @BuiltValueField(wireName: r'width')
  int get width;

  /// 单帧实际像素高度
  @BuiltValueField(wireName: r'height')
  int get height;

  /// 完整动画预览文件字节数
  @BuiltValueField(wireName: r'bytes')
  int get bytes;

  ThreadCoverPreviewVariantResponseDto._();

  factory ThreadCoverPreviewVariantResponseDto([void updates(ThreadCoverPreviewVariantResponseDtoBuilder b)]) = _$ThreadCoverPreviewVariantResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadCoverPreviewVariantResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadCoverPreviewVariantResponseDto> get serializer => _$ThreadCoverPreviewVariantResponseDtoSerializer();
}

class _$ThreadCoverPreviewVariantResponseDtoSerializer implements PrimitiveSerializer<ThreadCoverPreviewVariantResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadCoverPreviewVariantResponseDto, _$ThreadCoverPreviewVariantResponseDto];

  @override
  final String wireName = r'ThreadCoverPreviewVariantResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadCoverPreviewVariantResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'width';
    yield serializers.serialize(
      object.width,
      specifiedType: const FullType(int),
    );
    yield r'height';
    yield serializers.serialize(
      object.height,
      specifiedType: const FullType(int),
    );
    yield r'bytes';
    yield serializers.serialize(
      object.bytes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadCoverPreviewVariantResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadCoverPreviewVariantResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'width':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.width = valueDes;
          break;
        case r'height':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.height = valueDes;
          break;
        case r'bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadCoverPreviewVariantResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadCoverPreviewVariantResponseDtoBuilder();
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
