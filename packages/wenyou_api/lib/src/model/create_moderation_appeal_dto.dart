//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_moderation_appeal_dto.g.dart';

/// CreateModerationAppealDto
///
/// Properties:
/// * [decisionId]
/// * [statement]
@BuiltValue()
abstract class CreateModerationAppealDto implements Built<CreateModerationAppealDto, CreateModerationAppealDtoBuilder> {
  @BuiltValueField(wireName: r'decisionId')
  String get decisionId;

  @BuiltValueField(wireName: r'statement')
  String get statement;

  CreateModerationAppealDto._();

  factory CreateModerationAppealDto([void updates(CreateModerationAppealDtoBuilder b)]) = _$CreateModerationAppealDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateModerationAppealDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateModerationAppealDto> get serializer => _$CreateModerationAppealDtoSerializer();
}

class _$CreateModerationAppealDtoSerializer implements PrimitiveSerializer<CreateModerationAppealDto> {
  @override
  final Iterable<Type> types = const [CreateModerationAppealDto, _$CreateModerationAppealDto];

  @override
  final String wireName = r'CreateModerationAppealDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateModerationAppealDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'decisionId';
    yield serializers.serialize(
      object.decisionId,
      specifiedType: const FullType(String),
    );
    yield r'statement';
    yield serializers.serialize(
      object.statement,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateModerationAppealDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateModerationAppealDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'decisionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.decisionId = valueDes;
          break;
        case r'statement':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.statement = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateModerationAppealDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateModerationAppealDtoBuilder();
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
