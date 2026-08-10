//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_step_up_response_dto.g.dart';

/// AdminStepUpResponseDto
///
/// Properties:
/// * [elevatedUntil]
@BuiltValue()
abstract class AdminStepUpResponseDto implements Built<AdminStepUpResponseDto, AdminStepUpResponseDtoBuilder> {
  @BuiltValueField(wireName: r'elevatedUntil')
  DateTime get elevatedUntil;

  AdminStepUpResponseDto._();

  factory AdminStepUpResponseDto([void updates(AdminStepUpResponseDtoBuilder b)]) = _$AdminStepUpResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminStepUpResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminStepUpResponseDto> get serializer => _$AdminStepUpResponseDtoSerializer();
}

class _$AdminStepUpResponseDtoSerializer implements PrimitiveSerializer<AdminStepUpResponseDto> {
  @override
  final Iterable<Type> types = const [AdminStepUpResponseDto, _$AdminStepUpResponseDto];

  @override
  final String wireName = r'AdminStepUpResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminStepUpResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'elevatedUntil';
    yield serializers.serialize(
      object.elevatedUntil,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminStepUpResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminStepUpResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'elevatedUntil':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.elevatedUntil = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminStepUpResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminStepUpResponseDtoBuilder();
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
