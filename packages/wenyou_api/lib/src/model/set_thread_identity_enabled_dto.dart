//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'set_thread_identity_enabled_dto.g.dart';

/// SetThreadIdentityEnabledDto
///
/// Properties:
/// * [enabled]
@BuiltValue()
abstract class SetThreadIdentityEnabledDto implements Built<SetThreadIdentityEnabledDto, SetThreadIdentityEnabledDtoBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  SetThreadIdentityEnabledDto._();

  factory SetThreadIdentityEnabledDto([void updates(SetThreadIdentityEnabledDtoBuilder b)]) = _$SetThreadIdentityEnabledDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SetThreadIdentityEnabledDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SetThreadIdentityEnabledDto> get serializer => _$SetThreadIdentityEnabledDtoSerializer();
}

class _$SetThreadIdentityEnabledDtoSerializer implements PrimitiveSerializer<SetThreadIdentityEnabledDto> {
  @override
  final Iterable<Type> types = const [SetThreadIdentityEnabledDto, _$SetThreadIdentityEnabledDto];

  @override
  final String wireName = r'SetThreadIdentityEnabledDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SetThreadIdentityEnabledDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SetThreadIdentityEnabledDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SetThreadIdentityEnabledDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SetThreadIdentityEnabledDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SetThreadIdentityEnabledDtoBuilder();
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
