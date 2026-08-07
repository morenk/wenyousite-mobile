//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'blocked_user_record_response_dto.g.dart';

/// BlockedUserRecordResponseDto
///
/// Properties:
/// * [id]
/// * [blockerId]
/// * [blockedId]
/// * [createdAt]
/// * [blocked]
@BuiltValue()
abstract class BlockedUserRecordResponseDto implements Built<BlockedUserRecordResponseDto, BlockedUserRecordResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'blockerId')
  String get blockerId;

  @BuiltValueField(wireName: r'blockedId')
  String get blockedId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'blocked')
  PostAuthorResponseDto get blocked;

  BlockedUserRecordResponseDto._();

  factory BlockedUserRecordResponseDto([void updates(BlockedUserRecordResponseDtoBuilder b)]) = _$BlockedUserRecordResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BlockedUserRecordResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BlockedUserRecordResponseDto> get serializer => _$BlockedUserRecordResponseDtoSerializer();
}

class _$BlockedUserRecordResponseDtoSerializer implements PrimitiveSerializer<BlockedUserRecordResponseDto> {
  @override
  final Iterable<Type> types = const [BlockedUserRecordResponseDto, _$BlockedUserRecordResponseDto];

  @override
  final String wireName = r'BlockedUserRecordResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BlockedUserRecordResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'blockerId';
    yield serializers.serialize(
      object.blockerId,
      specifiedType: const FullType(String),
    );
    yield r'blockedId';
    yield serializers.serialize(
      object.blockedId,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'blocked';
    yield serializers.serialize(
      object.blocked,
      specifiedType: const FullType(PostAuthorResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BlockedUserRecordResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BlockedUserRecordResponseDtoBuilder result,
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
        case r'blockerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.blockerId = valueDes;
          break;
        case r'blockedId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.blockedId = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'blocked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAuthorResponseDto),
          ) as PostAuthorResponseDto;
          result.blocked.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BlockedUserRecordResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BlockedUserRecordResponseDtoBuilder();
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
