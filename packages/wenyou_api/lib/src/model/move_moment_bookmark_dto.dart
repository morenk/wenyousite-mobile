//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'move_moment_bookmark_dto.g.dart';

/// MoveMomentBookmarkDto
///
/// Properties:
/// * [folderId] - 要移入的收藏夹 ID
@BuiltValue()
abstract class MoveMomentBookmarkDto implements Built<MoveMomentBookmarkDto, MoveMomentBookmarkDtoBuilder> {
  /// 要移入的收藏夹 ID
  @BuiltValueField(wireName: r'folderId')
  String get folderId;

  MoveMomentBookmarkDto._();

  factory MoveMomentBookmarkDto([void updates(MoveMomentBookmarkDtoBuilder b)]) = _$MoveMomentBookmarkDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MoveMomentBookmarkDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MoveMomentBookmarkDto> get serializer => _$MoveMomentBookmarkDtoSerializer();
}

class _$MoveMomentBookmarkDtoSerializer implements PrimitiveSerializer<MoveMomentBookmarkDto> {
  @override
  final Iterable<Type> types = const [MoveMomentBookmarkDto, _$MoveMomentBookmarkDto];

  @override
  final String wireName = r'MoveMomentBookmarkDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MoveMomentBookmarkDto object, {
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
    MoveMomentBookmarkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MoveMomentBookmarkDtoBuilder result,
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
  MoveMomentBookmarkDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MoveMomentBookmarkDtoBuilder();
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
