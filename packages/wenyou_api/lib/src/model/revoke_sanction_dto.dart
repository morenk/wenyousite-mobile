//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'revoke_sanction_dto.g.dart';

/// RevokeSanctionDto
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class RevokeSanctionDto implements Built<RevokeSanctionDto, RevokeSanctionDtoBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  RevokeSanctionDto._();

  factory RevokeSanctionDto([void updates(RevokeSanctionDtoBuilder b)]) = _$RevokeSanctionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RevokeSanctionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RevokeSanctionDto> get serializer => _$RevokeSanctionDtoSerializer();
}

class _$RevokeSanctionDtoSerializer implements PrimitiveSerializer<RevokeSanctionDto> {
  @override
  final Iterable<Type> types = const [RevokeSanctionDto, _$RevokeSanctionDto];

  @override
  final String wireName = r'RevokeSanctionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RevokeSanctionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RevokeSanctionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RevokeSanctionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RevokeSanctionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RevokeSanctionDtoBuilder();
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
