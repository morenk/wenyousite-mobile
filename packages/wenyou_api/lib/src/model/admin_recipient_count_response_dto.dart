//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_recipient_count_response_dto.g.dart';

/// AdminRecipientCountResponseDto
///
/// Properties:
/// * [recipientCount]
/// * [estimatedCount]
@BuiltValue()
abstract class AdminRecipientCountResponseDto implements Built<AdminRecipientCountResponseDto, AdminRecipientCountResponseDtoBuilder> {
  @BuiltValueField(wireName: r'recipientCount')
  num get recipientCount;

  @BuiltValueField(wireName: r'estimatedCount')
  num? get estimatedCount;

  AdminRecipientCountResponseDto._();

  factory AdminRecipientCountResponseDto([void updates(AdminRecipientCountResponseDtoBuilder b)]) = _$AdminRecipientCountResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminRecipientCountResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminRecipientCountResponseDto> get serializer => _$AdminRecipientCountResponseDtoSerializer();
}

class _$AdminRecipientCountResponseDtoSerializer implements PrimitiveSerializer<AdminRecipientCountResponseDto> {
  @override
  final Iterable<Type> types = const [AdminRecipientCountResponseDto, _$AdminRecipientCountResponseDto];

  @override
  final String wireName = r'AdminRecipientCountResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminRecipientCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'recipientCount';
    yield serializers.serialize(
      object.recipientCount,
      specifiedType: const FullType(num),
    );
    if (object.estimatedCount != null) {
      yield r'estimatedCount';
      yield serializers.serialize(
        object.estimatedCount,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminRecipientCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminRecipientCountResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'recipientCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.recipientCount = valueDes;
          break;
        case r'estimatedCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.estimatedCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminRecipientCountResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminRecipientCountResponseDtoBuilder();
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
