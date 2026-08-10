//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_bookmark_folder_dto.g.dart';

/// CreateBookmarkFolderDto
///
/// Properties:
/// * [name]
@BuiltValue()
abstract class CreateBookmarkFolderDto implements Built<CreateBookmarkFolderDto, CreateBookmarkFolderDtoBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  CreateBookmarkFolderDto._();

  factory CreateBookmarkFolderDto([void updates(CreateBookmarkFolderDtoBuilder b)]) = _$CreateBookmarkFolderDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateBookmarkFolderDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateBookmarkFolderDto> get serializer => _$CreateBookmarkFolderDtoSerializer();
}

class _$CreateBookmarkFolderDtoSerializer implements PrimitiveSerializer<CreateBookmarkFolderDto> {
  @override
  final Iterable<Type> types = const [CreateBookmarkFolderDto, _$CreateBookmarkFolderDto];

  @override
  final String wireName = r'CreateBookmarkFolderDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateBookmarkFolderDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateBookmarkFolderDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateBookmarkFolderDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateBookmarkFolderDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateBookmarkFolderDtoBuilder();
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
