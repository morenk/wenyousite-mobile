//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/mention_candidate_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mention_candidates_response_dto.g.dart';

/// MentionCandidatesResponseDto
///
/// Properties:
/// * [users]
/// * [canMentionAllPlayers] - 当前用户是否允许使用 @全体玩家
@BuiltValue()
abstract class MentionCandidatesResponseDto implements Built<MentionCandidatesResponseDto, MentionCandidatesResponseDtoBuilder> {
  @BuiltValueField(wireName: r'users')
  BuiltList<MentionCandidateDto> get users;

  /// 当前用户是否允许使用 @全体玩家
  @BuiltValueField(wireName: r'canMentionAllPlayers')
  bool get canMentionAllPlayers;

  MentionCandidatesResponseDto._();

  factory MentionCandidatesResponseDto([void updates(MentionCandidatesResponseDtoBuilder b)]) = _$MentionCandidatesResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MentionCandidatesResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MentionCandidatesResponseDto> get serializer => _$MentionCandidatesResponseDtoSerializer();
}

class _$MentionCandidatesResponseDtoSerializer implements PrimitiveSerializer<MentionCandidatesResponseDto> {
  @override
  final Iterable<Type> types = const [MentionCandidatesResponseDto, _$MentionCandidatesResponseDto];

  @override
  final String wireName = r'MentionCandidatesResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MentionCandidatesResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'users';
    yield serializers.serialize(
      object.users,
      specifiedType: const FullType(BuiltList, [FullType(MentionCandidateDto)]),
    );
    yield r'canMentionAllPlayers';
    yield serializers.serialize(
      object.canMentionAllPlayers,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MentionCandidatesResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MentionCandidatesResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MentionCandidateDto)]),
          ) as BuiltList<MentionCandidateDto>;
          result.users.replace(valueDes);
          break;
        case r'canMentionAllPlayers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canMentionAllPlayers = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MentionCandidatesResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MentionCandidatesResponseDtoBuilder();
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
