//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moderate_content_dto.g.dart';

/// ModerateContentDto
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class ModerateContentDto implements Built<ModerateContentDto, ModerateContentDtoBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  ModerateContentDto._();

  factory ModerateContentDto([void updates(ModerateContentDtoBuilder b)]) = _$ModerateContentDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModerateContentDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModerateContentDto> get serializer => _$ModerateContentDtoSerializer();
}

class _$ModerateContentDtoSerializer implements PrimitiveSerializer<ModerateContentDto> {
  @override
  final Iterable<Type> types = const [ModerateContentDto, _$ModerateContentDto];

  @override
  final String wireName = r'ModerateContentDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModerateContentDto object, {
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
    ModerateContentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModerateContentDtoBuilder result,
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
  ModerateContentDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModerateContentDtoBuilder();
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
