//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tip_response_dto.g.dart';

/// TipResponseDto
///
/// Properties:
/// * [transactionId]
/// * [grossAmount]
/// * [recipientAmount]
/// * [platformAmount]
/// * [balance] - 付款后余额
/// * [threadTipTotal] - 主题累计投入总额
/// * [momentTipTotal] - 动态累计加油总额
/// * [recipientTipTotal] - 收款人累计收到的用户投入总额
/// * [recipientTipCount]
@BuiltValue()
abstract class TipResponseDto implements Built<TipResponseDto, TipResponseDtoBuilder> {
  @BuiltValueField(wireName: r'transactionId')
  String get transactionId;

  @BuiltValueField(wireName: r'grossAmount')
  String get grossAmount;

  @BuiltValueField(wireName: r'recipientAmount')
  String get recipientAmount;

  @BuiltValueField(wireName: r'platformAmount')
  String get platformAmount;

  /// 付款后余额
  @BuiltValueField(wireName: r'balance')
  String get balance;

  /// 主题累计投入总额
  @BuiltValueField(wireName: r'threadTipTotal')
  String? get threadTipTotal;

  /// 动态累计加油总额
  @BuiltValueField(wireName: r'momentTipTotal')
  String? get momentTipTotal;

  /// 收款人累计收到的用户投入总额
  @BuiltValueField(wireName: r'recipientTipTotal')
  String get recipientTipTotal;

  @BuiltValueField(wireName: r'recipientTipCount')
  num get recipientTipCount;

  TipResponseDto._();

  factory TipResponseDto([void updates(TipResponseDtoBuilder b)]) = _$TipResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TipResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TipResponseDto> get serializer => _$TipResponseDtoSerializer();
}

class _$TipResponseDtoSerializer implements PrimitiveSerializer<TipResponseDto> {
  @override
  final Iterable<Type> types = const [TipResponseDto, _$TipResponseDto];

  @override
  final String wireName = r'TipResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TipResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'transactionId';
    yield serializers.serialize(
      object.transactionId,
      specifiedType: const FullType(String),
    );
    yield r'grossAmount';
    yield serializers.serialize(
      object.grossAmount,
      specifiedType: const FullType(String),
    );
    yield r'recipientAmount';
    yield serializers.serialize(
      object.recipientAmount,
      specifiedType: const FullType(String),
    );
    yield r'platformAmount';
    yield serializers.serialize(
      object.platformAmount,
      specifiedType: const FullType(String),
    );
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
    if (object.threadTipTotal != null) {
      yield r'threadTipTotal';
      yield serializers.serialize(
        object.threadTipTotal,
        specifiedType: const FullType(String),
      );
    }
    if (object.momentTipTotal != null) {
      yield r'momentTipTotal';
      yield serializers.serialize(
        object.momentTipTotal,
        specifiedType: const FullType(String),
      );
    }
    yield r'recipientTipTotal';
    yield serializers.serialize(
      object.recipientTipTotal,
      specifiedType: const FullType(String),
    );
    yield r'recipientTipCount';
    yield serializers.serialize(
      object.recipientTipCount,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TipResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TipResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'transactionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.transactionId = valueDes;
          break;
        case r'grossAmount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.grossAmount = valueDes;
          break;
        case r'recipientAmount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.recipientAmount = valueDes;
          break;
        case r'platformAmount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.platformAmount = valueDes;
          break;
        case r'balance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.balance = valueDes;
          break;
        case r'threadTipTotal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threadTipTotal = valueDes;
          break;
        case r'momentTipTotal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.momentTipTotal = valueDes;
          break;
        case r'recipientTipTotal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.recipientTipTotal = valueDes;
          break;
        case r'recipientTipCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.recipientTipCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TipResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TipResponseDtoBuilder();
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
