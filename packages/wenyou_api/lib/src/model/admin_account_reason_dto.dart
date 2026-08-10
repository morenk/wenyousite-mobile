//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_account_reason_dto.g.dart';

/// AdminAccountReasonDto
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class AdminAccountReasonDto implements Built<AdminAccountReasonDto, AdminAccountReasonDtoBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  AdminAccountReasonDto._();

  factory AdminAccountReasonDto([void updates(AdminAccountReasonDtoBuilder b)]) = _$AdminAccountReasonDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAccountReasonDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAccountReasonDto> get serializer => _$AdminAccountReasonDtoSerializer();
}

class _$AdminAccountReasonDtoSerializer implements PrimitiveSerializer<AdminAccountReasonDto> {
  @override
  final Iterable<Type> types = const [AdminAccountReasonDto, _$AdminAccountReasonDto];

  @override
  final String wireName = r'AdminAccountReasonDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAccountReasonDto object, {
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
    AdminAccountReasonDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAccountReasonDtoBuilder result,
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
  AdminAccountReasonDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAccountReasonDtoBuilder();
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
