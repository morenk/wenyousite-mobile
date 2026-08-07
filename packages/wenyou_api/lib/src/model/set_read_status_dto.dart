//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'set_read_status_dto.g.dart';

/// SetReadStatusDto
///
/// Properties:
/// * [isRead] - 阅读状态（true=已读，false=未读）
@BuiltValue()
abstract class SetReadStatusDto implements Built<SetReadStatusDto, SetReadStatusDtoBuilder> {
  /// 阅读状态（true=已读，false=未读）
  @BuiltValueField(wireName: r'isRead')
  bool get isRead;

  SetReadStatusDto._();

  factory SetReadStatusDto([void updates(SetReadStatusDtoBuilder b)]) = _$SetReadStatusDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SetReadStatusDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SetReadStatusDto> get serializer => _$SetReadStatusDtoSerializer();
}

class _$SetReadStatusDtoSerializer implements PrimitiveSerializer<SetReadStatusDto> {
  @override
  final Iterable<Type> types = const [SetReadStatusDto, _$SetReadStatusDto];

  @override
  final String wireName = r'SetReadStatusDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SetReadStatusDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'isRead';
    yield serializers.serialize(
      object.isRead,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SetReadStatusDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SetReadStatusDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'isRead':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isRead = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SetReadStatusDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SetReadStatusDtoBuilder();
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
