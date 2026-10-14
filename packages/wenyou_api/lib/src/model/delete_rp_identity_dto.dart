//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_rp_identity_dto.g.dart';

/// DeleteRpIdentityDto
///
/// Properties:
/// * [version]
@BuiltValue()
abstract class DeleteRpIdentityDto implements Built<DeleteRpIdentityDto, DeleteRpIdentityDtoBuilder> {
  @BuiltValueField(wireName: r'version')
  num get version;

  DeleteRpIdentityDto._();

  factory DeleteRpIdentityDto([void updates(DeleteRpIdentityDtoBuilder b)]) = _$DeleteRpIdentityDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteRpIdentityDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteRpIdentityDto> get serializer => _$DeleteRpIdentityDtoSerializer();
}

class _$DeleteRpIdentityDtoSerializer implements PrimitiveSerializer<DeleteRpIdentityDto> {
  @override
  final Iterable<Type> types = const [DeleteRpIdentityDto, _$DeleteRpIdentityDto];

  @override
  final String wireName = r'DeleteRpIdentityDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteRpIdentityDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteRpIdentityDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeleteRpIdentityDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteRpIdentityDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteRpIdentityDtoBuilder();
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
