//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_moment_bookmark_dto.g.dart';

/// CreateMomentBookmarkDto
///
/// Properties:
/// * [folderId] - 目标收藏夹 ID；不传时首次收藏归入默认收藏夹
@BuiltValue()
abstract class CreateMomentBookmarkDto implements Built<CreateMomentBookmarkDto, CreateMomentBookmarkDtoBuilder> {
  /// 目标收藏夹 ID；不传时首次收藏归入默认收藏夹
  @BuiltValueField(wireName: r'folderId')
  String? get folderId;

  CreateMomentBookmarkDto._();

  factory CreateMomentBookmarkDto([void updates(CreateMomentBookmarkDtoBuilder b)]) = _$CreateMomentBookmarkDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateMomentBookmarkDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateMomentBookmarkDto> get serializer => _$CreateMomentBookmarkDtoSerializer();
}

class _$CreateMomentBookmarkDtoSerializer implements PrimitiveSerializer<CreateMomentBookmarkDto> {
  @override
  final Iterable<Type> types = const [CreateMomentBookmarkDto, _$CreateMomentBookmarkDto];

  @override
  final String wireName = r'CreateMomentBookmarkDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateMomentBookmarkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    CreateMomentBookmarkDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateMomentBookmarkDtoBuilder result,
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
  CreateMomentBookmarkDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateMomentBookmarkDtoBuilder();
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
