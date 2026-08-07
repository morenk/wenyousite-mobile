//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reply_target_response_dto.g.dart';

/// ReplyTargetResponseDto
///
/// Properties:
/// * [id]
/// * [authorId]
/// * [author]
@BuiltValue()
abstract class ReplyTargetResponseDto implements Built<ReplyTargetResponseDto, ReplyTargetResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'authorId')
  String get authorId;

  @BuiltValueField(wireName: r'author')
  PostAuthorResponseDto get author;

  ReplyTargetResponseDto._();

  factory ReplyTargetResponseDto([void updates(ReplyTargetResponseDtoBuilder b)]) = _$ReplyTargetResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReplyTargetResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReplyTargetResponseDto> get serializer => _$ReplyTargetResponseDtoSerializer();
}

class _$ReplyTargetResponseDtoSerializer implements PrimitiveSerializer<ReplyTargetResponseDto> {
  @override
  final Iterable<Type> types = const [ReplyTargetResponseDto, _$ReplyTargetResponseDto];

  @override
  final String wireName = r'ReplyTargetResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReplyTargetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'authorId';
    yield serializers.serialize(
      object.authorId,
      specifiedType: const FullType(String),
    );
    yield r'author';
    yield serializers.serialize(
      object.author,
      specifiedType: const FullType(PostAuthorResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReplyTargetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReplyTargetResponseDtoBuilder result,
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
        case r'authorId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authorId = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAuthorResponseDto),
          ) as PostAuthorResponseDto;
          result.author.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReplyTargetResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReplyTargetResponseDtoBuilder();
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
