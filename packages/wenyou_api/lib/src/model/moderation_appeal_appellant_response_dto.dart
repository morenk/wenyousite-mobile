//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moderation_appeal_appellant_response_dto.g.dart';

/// ModerationAppealAppellantResponseDto
///
/// Properties:
/// * [id]
/// * [username]
@BuiltValue()
abstract class ModerationAppealAppellantResponseDto implements Built<ModerationAppealAppellantResponseDto, ModerationAppealAppellantResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  ModerationAppealAppellantResponseDto._();

  factory ModerationAppealAppellantResponseDto([void updates(ModerationAppealAppellantResponseDtoBuilder b)]) = _$ModerationAppealAppellantResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModerationAppealAppellantResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModerationAppealAppellantResponseDto> get serializer => _$ModerationAppealAppellantResponseDtoSerializer();
}

class _$ModerationAppealAppellantResponseDtoSerializer implements PrimitiveSerializer<ModerationAppealAppellantResponseDto> {
  @override
  final Iterable<Type> types = const [ModerationAppealAppellantResponseDto, _$ModerationAppealAppellantResponseDto];

  @override
  final String wireName = r'ModerationAppealAppellantResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModerationAppealAppellantResponseDto object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ModerationAppealAppellantResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModerationAppealAppellantResponseDtoBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ModerationAppealAppellantResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModerationAppealAppellantResponseDtoBuilder();
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
