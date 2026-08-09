//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_reply_target_response_dto.g.dart';

/// MomentReplyTargetResponseDto
///
/// Properties:
/// * [id]
/// * [author]
@BuiltValue()
abstract class MomentReplyTargetResponseDto implements Built<MomentReplyTargetResponseDto, MomentReplyTargetResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'author')
  PostAuthorResponseDto get author;

  MomentReplyTargetResponseDto._();

  factory MomentReplyTargetResponseDto([void updates(MomentReplyTargetResponseDtoBuilder b)]) = _$MomentReplyTargetResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentReplyTargetResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentReplyTargetResponseDto> get serializer => _$MomentReplyTargetResponseDtoSerializer();
}

class _$MomentReplyTargetResponseDtoSerializer implements PrimitiveSerializer<MomentReplyTargetResponseDto> {
  @override
  final Iterable<Type> types = const [MomentReplyTargetResponseDto, _$MomentReplyTargetResponseDto];

  @override
  final String wireName = r'MomentReplyTargetResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentReplyTargetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
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
    MomentReplyTargetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentReplyTargetResponseDtoBuilder result,
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
  MomentReplyTargetResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentReplyTargetResponseDtoBuilder();
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
