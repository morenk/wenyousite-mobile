//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:wenyou_api/src/model/wallet_transaction_target_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'wallet_transaction_response_dto.g.dart';

/// WalletTransactionResponseDto
///
/// Properties:
/// * [id]
/// * [type]
/// * [direction]
/// * [amount] - 该用户本次实际收入或支出
/// * [grossAmount]
/// * [recipientAmount]
/// * [platformAmount]
/// * [balanceAfter]
/// * [counterparty]
/// * [target]
/// * [createdAt]
@BuiltValue()
abstract class WalletTransactionResponseDto implements Built<WalletTransactionResponseDto, WalletTransactionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'type')
  WalletTransactionResponseDtoTypeEnum get type;
  // enum typeEnum {  DAILY_CHECK_IN,  TIP,  };

  @BuiltValueField(wireName: r'direction')
  WalletTransactionResponseDtoDirectionEnum get direction;
  // enum directionEnum {  INCOME,  EXPENSE,  };

  /// 该用户本次实际收入或支出
  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'grossAmount')
  String get grossAmount;

  @BuiltValueField(wireName: r'recipientAmount')
  String get recipientAmount;

  @BuiltValueField(wireName: r'platformAmount')
  String get platformAmount;

  @BuiltValueField(wireName: r'balanceAfter')
  String get balanceAfter;

  @BuiltValueField(wireName: r'counterparty')
  PostAuthorResponseDto? get counterparty;

  @BuiltValueField(wireName: r'target')
  WalletTransactionTargetResponseDto get target;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  WalletTransactionResponseDto._();

  factory WalletTransactionResponseDto([void updates(WalletTransactionResponseDtoBuilder b)]) = _$WalletTransactionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WalletTransactionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WalletTransactionResponseDto> get serializer => _$WalletTransactionResponseDtoSerializer();
}

class _$WalletTransactionResponseDtoSerializer implements PrimitiveSerializer<WalletTransactionResponseDto> {
  @override
  final Iterable<Type> types = const [WalletTransactionResponseDto, _$WalletTransactionResponseDto];

  @override
  final String wireName = r'WalletTransactionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WalletTransactionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(WalletTransactionResponseDtoTypeEnum),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(WalletTransactionResponseDtoDirectionEnum),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
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
    yield r'balanceAfter';
    yield serializers.serialize(
      object.balanceAfter,
      specifiedType: const FullType(String),
    );
    yield r'counterparty';
    yield object.counterparty == null ? null : serializers.serialize(
      object.counterparty,
      specifiedType: const FullType.nullable(PostAuthorResponseDto),
    );
    yield r'target';
    yield serializers.serialize(
      object.target,
      specifiedType: const FullType(WalletTransactionTargetResponseDto),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WalletTransactionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WalletTransactionResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WalletTransactionResponseDtoTypeEnum),
          ) as WalletTransactionResponseDtoTypeEnum;
          result.type = valueDes;
          break;
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WalletTransactionResponseDtoDirectionEnum),
          ) as WalletTransactionResponseDtoDirectionEnum;
          result.direction = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
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
        case r'balanceAfter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.balanceAfter = valueDes;
          break;
        case r'counterparty':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PostAuthorResponseDto),
          ) as PostAuthorResponseDto?;
          if (valueDes == null) continue;
          result.counterparty.replace(valueDes);
          break;
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WalletTransactionTargetResponseDto),
          ) as WalletTransactionTargetResponseDto;
          result.target.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WalletTransactionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WalletTransactionResponseDtoBuilder();
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

class WalletTransactionResponseDtoTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'DAILY_CHECK_IN')
  static const WalletTransactionResponseDtoTypeEnum DAILY_CHECK_IN = _$walletTransactionResponseDtoTypeEnum_DAILY_CHECK_IN;
  @BuiltValueEnumConst(wireName: r'TIP')
  static const WalletTransactionResponseDtoTypeEnum TIP = _$walletTransactionResponseDtoTypeEnum_TIP;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const WalletTransactionResponseDtoTypeEnum unknownDefaultOpenApi = _$walletTransactionResponseDtoTypeEnum_unknownDefaultOpenApi;

  static Serializer<WalletTransactionResponseDtoTypeEnum> get serializer => _$walletTransactionResponseDtoTypeEnumSerializer;

  const WalletTransactionResponseDtoTypeEnum._(String name): super(name);

  static BuiltSet<WalletTransactionResponseDtoTypeEnum> get values => _$walletTransactionResponseDtoTypeEnumValues;
  static WalletTransactionResponseDtoTypeEnum valueOf(String name) => _$walletTransactionResponseDtoTypeEnumValueOf(name);
}

class WalletTransactionResponseDtoDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'INCOME')
  static const WalletTransactionResponseDtoDirectionEnum INCOME = _$walletTransactionResponseDtoDirectionEnum_INCOME;
  @BuiltValueEnumConst(wireName: r'EXPENSE')
  static const WalletTransactionResponseDtoDirectionEnum EXPENSE = _$walletTransactionResponseDtoDirectionEnum_EXPENSE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const WalletTransactionResponseDtoDirectionEnum unknownDefaultOpenApi = _$walletTransactionResponseDtoDirectionEnum_unknownDefaultOpenApi;

  static Serializer<WalletTransactionResponseDtoDirectionEnum> get serializer => _$walletTransactionResponseDtoDirectionEnumSerializer;

  const WalletTransactionResponseDtoDirectionEnum._(String name): super(name);

  static BuiltSet<WalletTransactionResponseDtoDirectionEnum> get values => _$walletTransactionResponseDtoDirectionEnumValues;
  static WalletTransactionResponseDtoDirectionEnum valueOf(String name) => _$walletTransactionResponseDtoDirectionEnumValueOf(name);
}
