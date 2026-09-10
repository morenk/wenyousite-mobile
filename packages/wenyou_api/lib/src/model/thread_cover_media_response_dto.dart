//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_cover_preview_variant_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_cover_media_response_dto.g.dart';

/// ThreadCoverMediaResponseDto
///
/// Properties:
/// * [url] - 第一张普通正文图片的原始播放地址，与 coverImages[0] 一致；未知媒体不得自动请求
/// * [animated] - 可信的动画属性；无法确认、未完成或历史 GIF 返回 null
/// * [posterUrl] - 可用于列表静止状态的第一帧静态地址；未知时返回 null，客户端显示占位，禁止回退加载原图
/// * [previewVariants] - 可选列表动画变体，按单帧像素面积升序；缺失或 null 时，只有已确认 animated=true 且有独立静态 poster 的媒体可受控回退原 url
@BuiltValue()
abstract class ThreadCoverMediaResponseDto implements Built<ThreadCoverMediaResponseDto, ThreadCoverMediaResponseDtoBuilder> {
  /// 第一张普通正文图片的原始播放地址，与 coverImages[0] 一致；未知媒体不得自动请求
  @BuiltValueField(wireName: r'url')
  String get url;

  /// 可信的动画属性；无法确认、未完成或历史 GIF 返回 null
  @BuiltValueField(wireName: r'animated')
  bool? get animated;

  /// 可用于列表静止状态的第一帧静态地址；未知时返回 null，客户端显示占位，禁止回退加载原图
  @BuiltValueField(wireName: r'posterUrl')
  String? get posterUrl;

  /// 可选列表动画变体，按单帧像素面积升序；缺失或 null 时，只有已确认 animated=true 且有独立静态 poster 的媒体可受控回退原 url
  @BuiltValueField(wireName: r'previewVariants')
  BuiltList<ThreadCoverPreviewVariantResponseDto>? get previewVariants;

  ThreadCoverMediaResponseDto._();

  factory ThreadCoverMediaResponseDto([void updates(ThreadCoverMediaResponseDtoBuilder b)]) = _$ThreadCoverMediaResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadCoverMediaResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadCoverMediaResponseDto> get serializer => _$ThreadCoverMediaResponseDtoSerializer();
}

class _$ThreadCoverMediaResponseDtoSerializer implements PrimitiveSerializer<ThreadCoverMediaResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadCoverMediaResponseDto, _$ThreadCoverMediaResponseDto];

  @override
  final String wireName = r'ThreadCoverMediaResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadCoverMediaResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'animated';
    yield object.animated == null ? null : serializers.serialize(
      object.animated,
      specifiedType: const FullType.nullable(bool),
    );
    yield r'posterUrl';
    yield object.posterUrl == null ? null : serializers.serialize(
      object.posterUrl,
      specifiedType: const FullType.nullable(String),
    );
    if (object.previewVariants != null) {
      yield r'previewVariants';
      yield serializers.serialize(
        object.previewVariants,
        specifiedType: const FullType.nullable(BuiltList, [FullType(ThreadCoverPreviewVariantResponseDto)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadCoverMediaResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadCoverMediaResponseDtoBuilder result,
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
        case r'animated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.animated = valueDes;
          break;
        case r'posterUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.posterUrl = valueDes;
          break;
        case r'previewVariants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(ThreadCoverPreviewVariantResponseDto)]),
          ) as BuiltList<ThreadCoverPreviewVariantResponseDto>?;
          if (valueDes == null) continue;
          result.previewVariants.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadCoverMediaResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadCoverMediaResponseDtoBuilder();
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
