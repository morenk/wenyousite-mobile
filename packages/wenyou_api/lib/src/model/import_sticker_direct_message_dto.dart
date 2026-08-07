//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'import_sticker_direct_message_dto.g.dart';

/// ImportStickerDirectMessageDto
///
/// Properties:
/// * [directMessageId] - 当前用户参与的、尚未撤回的私聊消息 ID
/// * [clientRequestId] - 导入幂等键
@BuiltValue()
abstract class ImportStickerDirectMessageDto implements Built<ImportStickerDirectMessageDto, ImportStickerDirectMessageDtoBuilder> {
  /// 当前用户参与的、尚未撤回的私聊消息 ID
  @BuiltValueField(wireName: r'directMessageId')
  String get directMessageId;

  /// 导入幂等键
  @BuiltValueField(wireName: r'clientRequestId')
  String get clientRequestId;

  ImportStickerDirectMessageDto._();

  factory ImportStickerDirectMessageDto([void updates(ImportStickerDirectMessageDtoBuilder b)]) = _$ImportStickerDirectMessageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImportStickerDirectMessageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImportStickerDirectMessageDto> get serializer => _$ImportStickerDirectMessageDtoSerializer();
}

class _$ImportStickerDirectMessageDtoSerializer implements PrimitiveSerializer<ImportStickerDirectMessageDto> {
  @override
  final Iterable<Type> types = const [ImportStickerDirectMessageDto, _$ImportStickerDirectMessageDto];

  @override
  final String wireName = r'ImportStickerDirectMessageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImportStickerDirectMessageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'directMessageId';
    yield serializers.serialize(
      object.directMessageId,
      specifiedType: const FullType(String),
    );
    yield r'clientRequestId';
    yield serializers.serialize(
      object.clientRequestId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ImportStickerDirectMessageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ImportStickerDirectMessageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'directMessageId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.directMessageId = valueDes;
          break;
        case r'clientRequestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientRequestId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ImportStickerDirectMessageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImportStickerDirectMessageDtoBuilder();
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
