//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_bookmark_dto.g.dart';

/// CreateBookmarkDto
///
/// Properties:
/// * [threadId] - 要收藏的主题帖 ID
/// * [folderId] - 目标收藏夹 ID；不传时归入默认收藏夹
@BuiltValue()
abstract class CreateBookmarkDto implements Built<CreateBookmarkDto, CreateBookmarkDtoBuilder> {
  /// 要收藏的主题帖 ID
  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  /// 目标收藏夹 ID；不传时归入默认收藏夹
  @BuiltValueField(wireName: r'folderId')
  String? get folderId;

  CreateBookmarkDto._();

  factory CreateBookmarkDto([void updates(CreateBookmarkDtoBuilder b)]) = _$CreateBookmarkDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateBookmarkDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateBookmarkDto> get serializer => _$CreateBookmarkDtoSerializer();
}

class _$CreateBookmarkDtoSerializer implements PrimitiveSerializer<CreateBookmarkDto> {
  @override
  final Iterable<Type> types = const [CreateBookmarkDto, _$CreateBookmarkDto];

  @override
  final String wireName = r'CreateBookmarkDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateBookmarkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'threadId';
    yield serializers.serialize(
      object.threadId,
      specifiedType: const FullType(String),
    );
    if (object.folderId != null) {
      yield r'folderId';
      yield serializers.serialize(
        object.folderId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateBookmarkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateBookmarkDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threadId = valueDes;
          break;
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
  CreateBookmarkDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateBookmarkDtoBuilder();
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
