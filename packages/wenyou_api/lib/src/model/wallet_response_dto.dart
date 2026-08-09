//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'wallet_response_dto.g.dart';

/// WalletResponseDto
///
/// Properties:
/// * [balance]
/// * [receivedTipTotal]
/// * [receivedTipCount]
@BuiltValue()
abstract class WalletResponseDto implements Built<WalletResponseDto, WalletResponseDtoBuilder> {
  @BuiltValueField(wireName: r'balance')
  String get balance;

  @BuiltValueField(wireName: r'receivedTipTotal')
  String get receivedTipTotal;

  @BuiltValueField(wireName: r'receivedTipCount')
  num get receivedTipCount;

  WalletResponseDto._();

  factory WalletResponseDto([void updates(WalletResponseDtoBuilder b)]) = _$WalletResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WalletResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WalletResponseDto> get serializer => _$WalletResponseDtoSerializer();
}

class _$WalletResponseDtoSerializer implements PrimitiveSerializer<WalletResponseDto> {
  @override
  final Iterable<Type> types = const [WalletResponseDto, _$WalletResponseDto];

  @override
  final String wireName = r'WalletResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WalletResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
    yield r'receivedTipTotal';
    yield serializers.serialize(
      object.receivedTipTotal,
      specifiedType: const FullType(String),
    );
    yield r'receivedTipCount';
    yield serializers.serialize(
      object.receivedTipCount,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WalletResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WalletResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'balance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.balance = valueDes;
          break;
        case r'receivedTipTotal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.receivedTipTotal = valueDes;
          break;
        case r'receivedTipCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.receivedTipCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WalletResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WalletResponseDtoBuilder();
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
