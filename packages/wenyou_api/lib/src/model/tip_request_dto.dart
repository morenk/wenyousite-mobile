//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tip_request_dto.g.dart';

/// TipRequestDto
///
/// Properties:
/// * [amount] - 打赏升数；只接受不小于 2 的十进制正整数字符串
/// * [clientRequestId] - 客户端生成的幂等请求 ID
@BuiltValue()
abstract class TipRequestDto implements Built<TipRequestDto, TipRequestDtoBuilder> {
  /// 打赏升数；只接受不小于 2 的十进制正整数字符串
  @BuiltValueField(wireName: r'amount')
  String get amount;

  /// 客户端生成的幂等请求 ID
  @BuiltValueField(wireName: r'clientRequestId')
  String get clientRequestId;

  TipRequestDto._();

  factory TipRequestDto([void updates(TipRequestDtoBuilder b)]) = _$TipRequestDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TipRequestDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TipRequestDto> get serializer => _$TipRequestDtoSerializer();
}

class _$TipRequestDtoSerializer implements PrimitiveSerializer<TipRequestDto> {
  @override
  final Iterable<Type> types = const [TipRequestDto, _$TipRequestDto];

  @override
  final String wireName = r'TipRequestDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TipRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'clientRequestId';
    yield serializers.serialize(
      object.clientRequestId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TipRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TipRequestDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'clientRequestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientRequestId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TipRequestDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TipRequestDtoBuilder();
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
