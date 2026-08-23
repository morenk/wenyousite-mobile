//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upload_url_response_dto.g.dart';

/// UploadUrlResponseDto
///
/// Properties:
/// * [uploadUrl] - 对象存储预签名 PUT 地址
/// * [mediaId] - 媒体记录 ID，后续确认和轮询使用
/// * [objectKey] - 本次 PUT 使用的临时对象 key；客户端不得据此拼接读取地址
/// * [publicUrl] - 处理完成后的正式媒体地址；静态图为归一化母版，GIF 为保留的动画原件
@BuiltValue()
abstract class UploadUrlResponseDto implements Built<UploadUrlResponseDto, UploadUrlResponseDtoBuilder> {
  /// 对象存储预签名 PUT 地址
  @BuiltValueField(wireName: r'uploadUrl')
  String get uploadUrl;

  /// 媒体记录 ID，后续确认和轮询使用
  @BuiltValueField(wireName: r'mediaId')
  String get mediaId;

  /// 本次 PUT 使用的临时对象 key；客户端不得据此拼接读取地址
  @BuiltValueField(wireName: r'objectKey')
  String get objectKey;

  /// 处理完成后的正式媒体地址；静态图为归一化母版，GIF 为保留的动画原件
  @BuiltValueField(wireName: r'publicUrl')
  String get publicUrl;

  UploadUrlResponseDto._();

  factory UploadUrlResponseDto([void updates(UploadUrlResponseDtoBuilder b)]) = _$UploadUrlResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UploadUrlResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UploadUrlResponseDto> get serializer => _$UploadUrlResponseDtoSerializer();
}

class _$UploadUrlResponseDtoSerializer implements PrimitiveSerializer<UploadUrlResponseDto> {
  @override
  final Iterable<Type> types = const [UploadUrlResponseDto, _$UploadUrlResponseDto];

  @override
  final String wireName = r'UploadUrlResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UploadUrlResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'uploadUrl';
    yield serializers.serialize(
      object.uploadUrl,
      specifiedType: const FullType(String),
    );
    yield r'mediaId';
    yield serializers.serialize(
      object.mediaId,
      specifiedType: const FullType(String),
    );
    yield r'objectKey';
    yield serializers.serialize(
      object.objectKey,
      specifiedType: const FullType(String),
    );
    yield r'publicUrl';
    yield serializers.serialize(
      object.publicUrl,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UploadUrlResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UploadUrlResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'uploadUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.uploadUrl = valueDes;
          break;
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaId = valueDes;
          break;
        case r'objectKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.objectKey = valueDes;
          break;
        case r'publicUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publicUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UploadUrlResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UploadUrlResponseDtoBuilder();
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
