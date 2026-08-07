//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'confirm_upload_dto.g.dart';

/// ConfirmUploadDto
///
/// Properties:
/// * [mediaId] - getUploadUrl 返回的 mediaId
@BuiltValue()
abstract class ConfirmUploadDto implements Built<ConfirmUploadDto, ConfirmUploadDtoBuilder> {
  /// getUploadUrl 返回的 mediaId
  @BuiltValueField(wireName: r'mediaId')
  String get mediaId;

  ConfirmUploadDto._();

  factory ConfirmUploadDto([void updates(ConfirmUploadDtoBuilder b)]) = _$ConfirmUploadDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfirmUploadDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfirmUploadDto> get serializer => _$ConfirmUploadDtoSerializer();
}

class _$ConfirmUploadDtoSerializer implements PrimitiveSerializer<ConfirmUploadDto> {
  @override
  final Iterable<Type> types = const [ConfirmUploadDto, _$ConfirmUploadDto];

  @override
  final String wireName = r'ConfirmUploadDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfirmUploadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mediaId';
    yield serializers.serialize(
      object.mediaId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfirmUploadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConfirmUploadDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConfirmUploadDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfirmUploadDtoBuilder();
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
