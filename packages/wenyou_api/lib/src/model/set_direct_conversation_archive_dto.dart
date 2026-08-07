//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'set_direct_conversation_archive_dto.g.dart';

/// SetDirectConversationArchiveDto
///
/// Properties:
/// * [archived] - true 归档；false 恢复到主列表
@BuiltValue()
abstract class SetDirectConversationArchiveDto implements Built<SetDirectConversationArchiveDto, SetDirectConversationArchiveDtoBuilder> {
  /// true 归档；false 恢复到主列表
  @BuiltValueField(wireName: r'archived')
  bool get archived;

  SetDirectConversationArchiveDto._();

  factory SetDirectConversationArchiveDto([void updates(SetDirectConversationArchiveDtoBuilder b)]) = _$SetDirectConversationArchiveDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SetDirectConversationArchiveDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SetDirectConversationArchiveDto> get serializer => _$SetDirectConversationArchiveDtoSerializer();
}

class _$SetDirectConversationArchiveDtoSerializer implements PrimitiveSerializer<SetDirectConversationArchiveDto> {
  @override
  final Iterable<Type> types = const [SetDirectConversationArchiveDto, _$SetDirectConversationArchiveDto];

  @override
  final String wireName = r'SetDirectConversationArchiveDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SetDirectConversationArchiveDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'archived';
    yield serializers.serialize(
      object.archived,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SetDirectConversationArchiveDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SetDirectConversationArchiveDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'archived':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.archived = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SetDirectConversationArchiveDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SetDirectConversationArchiveDtoBuilder();
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
