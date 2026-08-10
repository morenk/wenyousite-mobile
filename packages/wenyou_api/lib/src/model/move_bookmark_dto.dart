//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'move_bookmark_dto.g.dart';

/// MoveBookmarkDto
///
/// Properties:
/// * [folderId] - 要移入的收藏夹 ID
@BuiltValue()
abstract class MoveBookmarkDto implements Built<MoveBookmarkDto, MoveBookmarkDtoBuilder> {
  /// 要移入的收藏夹 ID
  @BuiltValueField(wireName: r'folderId')
  String get folderId;

  MoveBookmarkDto._();

  factory MoveBookmarkDto([void updates(MoveBookmarkDtoBuilder b)]) = _$MoveBookmarkDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MoveBookmarkDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MoveBookmarkDto> get serializer => _$MoveBookmarkDtoSerializer();
}

class _$MoveBookmarkDtoSerializer implements PrimitiveSerializer<MoveBookmarkDto> {
  @override
  final Iterable<Type> types = const [MoveBookmarkDto, _$MoveBookmarkDto];

  @override
  final String wireName = r'MoveBookmarkDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MoveBookmarkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'folderId';
    yield serializers.serialize(
      object.folderId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MoveBookmarkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MoveBookmarkDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'folderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.folderId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MoveBookmarkDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MoveBookmarkDtoBuilder();
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
