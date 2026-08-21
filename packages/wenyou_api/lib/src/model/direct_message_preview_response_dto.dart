//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_message_preview_response_dto.g.dart';

/// DirectMessagePreviewResponseDto
///
/// Properties:
/// * [id]
/// * [senderId]
/// * [contentPreview] - 去除传送门语法并隐藏邀请 token 后的纯文本预览，最多 120 字符
/// * [hasImage]
/// * [hasSticker]
/// * [isRecalled]
/// * [createdAt]
@BuiltValue()
abstract class DirectMessagePreviewResponseDto implements Built<DirectMessagePreviewResponseDto, DirectMessagePreviewResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'senderId')
  String get senderId;

  /// 去除传送门语法并隐藏邀请 token 后的纯文本预览，最多 120 字符
  @BuiltValueField(wireName: r'contentPreview')
  String? get contentPreview;

  @BuiltValueField(wireName: r'hasImage')
  bool get hasImage;

  @BuiltValueField(wireName: r'hasSticker')
  bool get hasSticker;

  @BuiltValueField(wireName: r'isRecalled')
  bool get isRecalled;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  DirectMessagePreviewResponseDto._();

  factory DirectMessagePreviewResponseDto([void updates(DirectMessagePreviewResponseDtoBuilder b)]) = _$DirectMessagePreviewResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectMessagePreviewResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectMessagePreviewResponseDto> get serializer => _$DirectMessagePreviewResponseDtoSerializer();
}

class _$DirectMessagePreviewResponseDtoSerializer implements PrimitiveSerializer<DirectMessagePreviewResponseDto> {
  @override
  final Iterable<Type> types = const [DirectMessagePreviewResponseDto, _$DirectMessagePreviewResponseDto];

  @override
  final String wireName = r'DirectMessagePreviewResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectMessagePreviewResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'senderId';
    yield serializers.serialize(
      object.senderId,
      specifiedType: const FullType(String),
    );
    yield r'contentPreview';
    yield object.contentPreview == null ? null : serializers.serialize(
      object.contentPreview,
      specifiedType: const FullType.nullable(String),
    );
    yield r'hasImage';
    yield serializers.serialize(
      object.hasImage,
      specifiedType: const FullType(bool),
    );
    yield r'hasSticker';
    yield serializers.serialize(
      object.hasSticker,
      specifiedType: const FullType(bool),
    );
    yield r'isRecalled';
    yield serializers.serialize(
      object.isRecalled,
      specifiedType: const FullType(bool),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DirectMessagePreviewResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectMessagePreviewResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'senderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.senderId = valueDes;
          break;
        case r'contentPreview':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.contentPreview = valueDes;
          break;
        case r'hasImage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasImage = valueDes;
          break;
        case r'hasSticker':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasSticker = valueDes;
          break;
        case r'isRecalled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isRecalled = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DirectMessagePreviewResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectMessagePreviewResponseDtoBuilder();
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
