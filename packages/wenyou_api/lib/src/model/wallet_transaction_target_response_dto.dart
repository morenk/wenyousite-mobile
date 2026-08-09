//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'wallet_transaction_target_response_dto.g.dart';

/// WalletTransactionTargetResponseDto
///
/// Properties:
/// * [type]
/// * [id]
/// * [title]
@BuiltValue()
abstract class WalletTransactionTargetResponseDto implements Built<WalletTransactionTargetResponseDto, WalletTransactionTargetResponseDtoBuilder> {
  @BuiltValueField(wireName: r'type')
  WalletTransactionTargetResponseDtoTypeEnum get type;
  // enum typeEnum {  THREAD,  USER,  MOMENT,  NONE,  };

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'title')
  String? get title;

  WalletTransactionTargetResponseDto._();

  factory WalletTransactionTargetResponseDto([void updates(WalletTransactionTargetResponseDtoBuilder b)]) = _$WalletTransactionTargetResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WalletTransactionTargetResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WalletTransactionTargetResponseDto> get serializer => _$WalletTransactionTargetResponseDtoSerializer();
}

class _$WalletTransactionTargetResponseDtoSerializer implements PrimitiveSerializer<WalletTransactionTargetResponseDto> {
  @override
  final Iterable<Type> types = const [WalletTransactionTargetResponseDto, _$WalletTransactionTargetResponseDto];

  @override
  final String wireName = r'WalletTransactionTargetResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WalletTransactionTargetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(WalletTransactionTargetResponseDtoTypeEnum),
    );
    yield r'id';
    yield object.id == null ? null : serializers.serialize(
      object.id,
      specifiedType: const FullType.nullable(String),
    );
    yield r'title';
    yield object.title == null ? null : serializers.serialize(
      object.title,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WalletTransactionTargetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WalletTransactionTargetResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WalletTransactionTargetResponseDtoTypeEnum),
          ) as WalletTransactionTargetResponseDtoTypeEnum;
          result.type = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.title = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WalletTransactionTargetResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WalletTransactionTargetResponseDtoBuilder();
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

class WalletTransactionTargetResponseDtoTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'THREAD')
  static const WalletTransactionTargetResponseDtoTypeEnum THREAD = _$walletTransactionTargetResponseDtoTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'USER')
  static const WalletTransactionTargetResponseDtoTypeEnum USER = _$walletTransactionTargetResponseDtoTypeEnum_USER;
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const WalletTransactionTargetResponseDtoTypeEnum MOMENT = _$walletTransactionTargetResponseDtoTypeEnum_MOMENT;
  @BuiltValueEnumConst(wireName: r'NONE')
  static const WalletTransactionTargetResponseDtoTypeEnum NONE = _$walletTransactionTargetResponseDtoTypeEnum_NONE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const WalletTransactionTargetResponseDtoTypeEnum unknownDefaultOpenApi = _$walletTransactionTargetResponseDtoTypeEnum_unknownDefaultOpenApi;

  static Serializer<WalletTransactionTargetResponseDtoTypeEnum> get serializer => _$walletTransactionTargetResponseDtoTypeEnumSerializer;

  const WalletTransactionTargetResponseDtoTypeEnum._(String name): super(name);

  static BuiltSet<WalletTransactionTargetResponseDtoTypeEnum> get values => _$walletTransactionTargetResponseDtoTypeEnumValues;
  static WalletTransactionTargetResponseDtoTypeEnum valueOf(String name) => _$walletTransactionTargetResponseDtoTypeEnumValueOf(name);
}
