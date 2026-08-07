//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/media_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'confirm_upload_response_dto.g.dart';

/// ConfirmUploadResponseDto
///
/// Properties:
/// * [media]
/// * [processing] - 是否处于异步图片处理阶段
@BuiltValue()
abstract class ConfirmUploadResponseDto implements Built<ConfirmUploadResponseDto, ConfirmUploadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'media')
  MediaResponseDto get media;

  /// 是否处于异步图片处理阶段
  @BuiltValueField(wireName: r'processing')
  bool get processing;

  ConfirmUploadResponseDto._();

  factory ConfirmUploadResponseDto([void updates(ConfirmUploadResponseDtoBuilder b)]) = _$ConfirmUploadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfirmUploadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfirmUploadResponseDto> get serializer => _$ConfirmUploadResponseDtoSerializer();
}

class _$ConfirmUploadResponseDtoSerializer implements PrimitiveSerializer<ConfirmUploadResponseDto> {
  @override
  final Iterable<Type> types = const [ConfirmUploadResponseDto, _$ConfirmUploadResponseDto];

  @override
  final String wireName = r'ConfirmUploadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfirmUploadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'media';
    yield serializers.serialize(
      object.media,
      specifiedType: const FullType(MediaResponseDto),
    );
    yield r'processing';
    yield serializers.serialize(
      object.processing,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfirmUploadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConfirmUploadResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'media':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MediaResponseDto),
          ) as MediaResponseDto;
          result.media.replace(valueDes);
          break;
        case r'processing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.processing = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConfirmUploadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfirmUploadResponseDtoBuilder();
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
