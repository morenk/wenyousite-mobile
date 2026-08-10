//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resolve_moderation_appeal_dto.g.dart';

/// ResolveModerationAppealDto
///
/// Properties:
/// * [outcome]
/// * [note]
@BuiltValue()
abstract class ResolveModerationAppealDto implements Built<ResolveModerationAppealDto, ResolveModerationAppealDtoBuilder> {
  @BuiltValueField(wireName: r'outcome')
  ResolveModerationAppealDtoOutcomeEnum get outcome;
  // enum outcomeEnum {  UPHELD,  OVERTURNED,  };

  @BuiltValueField(wireName: r'note')
  String get note;

  ResolveModerationAppealDto._();

  factory ResolveModerationAppealDto([void updates(ResolveModerationAppealDtoBuilder b)]) = _$ResolveModerationAppealDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResolveModerationAppealDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResolveModerationAppealDto> get serializer => _$ResolveModerationAppealDtoSerializer();
}

class _$ResolveModerationAppealDtoSerializer implements PrimitiveSerializer<ResolveModerationAppealDto> {
  @override
  final Iterable<Type> types = const [ResolveModerationAppealDto, _$ResolveModerationAppealDto];

  @override
  final String wireName = r'ResolveModerationAppealDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResolveModerationAppealDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'outcome';
    yield serializers.serialize(
      object.outcome,
      specifiedType: const FullType(ResolveModerationAppealDtoOutcomeEnum),
    );
    yield r'note';
    yield serializers.serialize(
      object.note,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResolveModerationAppealDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ResolveModerationAppealDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'outcome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResolveModerationAppealDtoOutcomeEnum),
          ) as ResolveModerationAppealDtoOutcomeEnum;
          result.outcome = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResolveModerationAppealDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResolveModerationAppealDtoBuilder();
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

class ResolveModerationAppealDtoOutcomeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'UPHELD')
  static const ResolveModerationAppealDtoOutcomeEnum UPHELD = _$resolveModerationAppealDtoOutcomeEnum_UPHELD;
  @BuiltValueEnumConst(wireName: r'OVERTURNED')
  static const ResolveModerationAppealDtoOutcomeEnum OVERTURNED = _$resolveModerationAppealDtoOutcomeEnum_OVERTURNED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ResolveModerationAppealDtoOutcomeEnum unknownDefaultOpenApi = _$resolveModerationAppealDtoOutcomeEnum_unknownDefaultOpenApi;

  static Serializer<ResolveModerationAppealDtoOutcomeEnum> get serializer => _$resolveModerationAppealDtoOutcomeEnumSerializer;

  const ResolveModerationAppealDtoOutcomeEnum._(String name): super(name);

  static BuiltSet<ResolveModerationAppealDtoOutcomeEnum> get values => _$resolveModerationAppealDtoOutcomeEnumValues;
  static ResolveModerationAppealDtoOutcomeEnum valueOf(String name) => _$resolveModerationAppealDtoOutcomeEnumValueOf(name);
}
