//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transfer_super_admin_dto.g.dart';

/// TransferSuperAdminDto
///
/// Properties:
/// * [reason]
/// * [userId] - 接任超级管理员的现有管理员 ID
@BuiltValue()
abstract class TransferSuperAdminDto implements Built<TransferSuperAdminDto, TransferSuperAdminDtoBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  /// 接任超级管理员的现有管理员 ID
  @BuiltValueField(wireName: r'userId')
  String get userId;

  TransferSuperAdminDto._();

  factory TransferSuperAdminDto([void updates(TransferSuperAdminDtoBuilder b)]) = _$TransferSuperAdminDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TransferSuperAdminDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TransferSuperAdminDto> get serializer => _$TransferSuperAdminDtoSerializer();
}

class _$TransferSuperAdminDtoSerializer implements PrimitiveSerializer<TransferSuperAdminDto> {
  @override
  final Iterable<Type> types = const [TransferSuperAdminDto, _$TransferSuperAdminDto];

  @override
  final String wireName = r'TransferSuperAdminDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TransferSuperAdminDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TransferSuperAdminDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TransferSuperAdminDtoBuilder result,
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
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TransferSuperAdminDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransferSuperAdminDtoBuilder();
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
