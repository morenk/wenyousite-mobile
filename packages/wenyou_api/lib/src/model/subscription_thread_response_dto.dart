//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subscription_thread_response_dto.g.dart';

/// SubscriptionThreadResponseDto
///
/// Properties:
/// * [id]
/// * [title]
/// * [category]
@BuiltValue()
abstract class SubscriptionThreadResponseDto implements Built<SubscriptionThreadResponseDto, SubscriptionThreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'category')
  SubscriptionThreadResponseDtoCategoryEnum get category;
  // enum categoryEnum {  DEDUCTION,  NATION,  RPG,  };

  SubscriptionThreadResponseDto._();

  factory SubscriptionThreadResponseDto([void updates(SubscriptionThreadResponseDtoBuilder b)]) = _$SubscriptionThreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubscriptionThreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubscriptionThreadResponseDto> get serializer => _$SubscriptionThreadResponseDtoSerializer();
}

class _$SubscriptionThreadResponseDtoSerializer implements PrimitiveSerializer<SubscriptionThreadResponseDto> {
  @override
  final Iterable<Type> types = const [SubscriptionThreadResponseDto, _$SubscriptionThreadResponseDto];

  @override
  final String wireName = r'SubscriptionThreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubscriptionThreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(SubscriptionThreadResponseDtoCategoryEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SubscriptionThreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubscriptionThreadResponseDtoBuilder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SubscriptionThreadResponseDtoCategoryEnum),
          ) as SubscriptionThreadResponseDtoCategoryEnum;
          result.category = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SubscriptionThreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubscriptionThreadResponseDtoBuilder();
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

class SubscriptionThreadResponseDtoCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'DEDUCTION')
  static const SubscriptionThreadResponseDtoCategoryEnum DEDUCTION = _$subscriptionThreadResponseDtoCategoryEnum_DEDUCTION;
  @BuiltValueEnumConst(wireName: r'NATION')
  static const SubscriptionThreadResponseDtoCategoryEnum NATION = _$subscriptionThreadResponseDtoCategoryEnum_NATION;
  @BuiltValueEnumConst(wireName: r'RPG')
  static const SubscriptionThreadResponseDtoCategoryEnum RPG = _$subscriptionThreadResponseDtoCategoryEnum_RPG;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SubscriptionThreadResponseDtoCategoryEnum unknownDefaultOpenApi = _$subscriptionThreadResponseDtoCategoryEnum_unknownDefaultOpenApi;

  static Serializer<SubscriptionThreadResponseDtoCategoryEnum> get serializer => _$subscriptionThreadResponseDtoCategoryEnumSerializer;

  const SubscriptionThreadResponseDtoCategoryEnum._(String name): super(name);

  static BuiltSet<SubscriptionThreadResponseDtoCategoryEnum> get values => _$subscriptionThreadResponseDtoCategoryEnumValues;
  static SubscriptionThreadResponseDtoCategoryEnum valueOf(String name) => _$subscriptionThreadResponseDtoCategoryEnumValueOf(name);
}
