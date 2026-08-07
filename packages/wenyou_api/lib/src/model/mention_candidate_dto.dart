//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mention_candidate_dto.g.dart';

/// MentionCandidateDto
///
/// Properties:
/// * [id]
/// * [username]
/// * [avatar]
/// * [relation]
@BuiltValue()
abstract class MentionCandidateDto implements Built<MentionCandidateDto, MentionCandidateDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  @BuiltValueField(wireName: r'relation')
  MentionCandidateDtoRelationEnum get relation;
  // enum relationEnum {  FOLLOWING,  PLAYER,  };

  MentionCandidateDto._();

  factory MentionCandidateDto([void updates(MentionCandidateDtoBuilder b)]) = _$MentionCandidateDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MentionCandidateDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MentionCandidateDto> get serializer => _$MentionCandidateDtoSerializer();
}

class _$MentionCandidateDtoSerializer implements PrimitiveSerializer<MentionCandidateDto> {
  @override
  final Iterable<Type> types = const [MentionCandidateDto, _$MentionCandidateDto];

  @override
  final String wireName = r'MentionCandidateDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MentionCandidateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'avatar';
    yield object.avatar == null ? null : serializers.serialize(
      object.avatar,
      specifiedType: const FullType.nullable(String),
    );
    yield r'relation';
    yield serializers.serialize(
      object.relation,
      specifiedType: const FullType(MentionCandidateDtoRelationEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MentionCandidateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MentionCandidateDtoBuilder result,
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
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatar = valueDes;
          break;
        case r'relation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MentionCandidateDtoRelationEnum),
          ) as MentionCandidateDtoRelationEnum;
          result.relation = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MentionCandidateDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MentionCandidateDtoBuilder();
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

class MentionCandidateDtoRelationEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'FOLLOWING')
  static const MentionCandidateDtoRelationEnum FOLLOWING = _$mentionCandidateDtoRelationEnum_FOLLOWING;
  @BuiltValueEnumConst(wireName: r'PLAYER')
  static const MentionCandidateDtoRelationEnum PLAYER = _$mentionCandidateDtoRelationEnum_PLAYER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const MentionCandidateDtoRelationEnum unknownDefaultOpenApi = _$mentionCandidateDtoRelationEnum_unknownDefaultOpenApi;

  static Serializer<MentionCandidateDtoRelationEnum> get serializer => _$mentionCandidateDtoRelationEnumSerializer;

  const MentionCandidateDtoRelationEnum._(String name): super(name);

  static BuiltSet<MentionCandidateDtoRelationEnum> get values => _$mentionCandidateDtoRelationEnumValues;
  static MentionCandidateDtoRelationEnum valueOf(String name) => _$mentionCandidateDtoRelationEnumValueOf(name);
}
