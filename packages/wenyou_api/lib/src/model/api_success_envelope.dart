//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'api_success_envelope.g.dart';

/// ApiSuccessEnvelope
///
/// Properties:
/// * [code]
/// * [message]
@BuiltValue(instantiable: false)
abstract class ApiSuccessEnvelope  {
  @BuiltValueField(wireName: r'code')
  ApiSuccessEnvelopeCodeEnum get code;
  // enum codeEnum {  0,  };

  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApiSuccessEnvelope> get serializer => _$ApiSuccessEnvelopeSerializer();
}

class _$ApiSuccessEnvelopeSerializer implements PrimitiveSerializer<ApiSuccessEnvelope> {
  @override
  final Iterable<Type> types = const [ApiSuccessEnvelope];

  @override
  final String wireName = r'ApiSuccessEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApiSuccessEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ApiSuccessEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  ApiSuccessEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($ApiSuccessEnvelope)) as $ApiSuccessEnvelope;
  }
}

/// a concrete implementation of [ApiSuccessEnvelope], since [ApiSuccessEnvelope] is not instantiable
@BuiltValue(instantiable: true)
abstract class $ApiSuccessEnvelope implements ApiSuccessEnvelope, Built<$ApiSuccessEnvelope, $ApiSuccessEnvelopeBuilder> {
  $ApiSuccessEnvelope._();

  factory $ApiSuccessEnvelope([void Function($ApiSuccessEnvelopeBuilder)? updates]) = _$$ApiSuccessEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($ApiSuccessEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$ApiSuccessEnvelope> get serializer => _$$ApiSuccessEnvelopeSerializer();
}

class _$$ApiSuccessEnvelopeSerializer implements PrimitiveSerializer<$ApiSuccessEnvelope> {
  @override
  final Iterable<Type> types = const [$ApiSuccessEnvelope, _$$ApiSuccessEnvelope];

  @override
  final String wireName = r'$ApiSuccessEnvelope';

  @override
  Object serialize(
    Serializers serializers,
    $ApiSuccessEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(ApiSuccessEnvelope))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ApiSuccessEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
          ) as ApiSuccessEnvelopeCodeEnum;
          result.code = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $ApiSuccessEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $ApiSuccessEnvelopeBuilder();
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

class ApiSuccessEnvelopeCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ApiSuccessEnvelopeCodeEnum number0 = _$apiSuccessEnvelopeCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ApiSuccessEnvelopeCodeEnum unknownDefaultOpenApi = _$apiSuccessEnvelopeCodeEnum_unknownDefaultOpenApi;

  static Serializer<ApiSuccessEnvelopeCodeEnum> get serializer => _$apiSuccessEnvelopeCodeEnumSerializer;

  const ApiSuccessEnvelopeCodeEnum._(String name): super(name);

  static BuiltSet<ApiSuccessEnvelopeCodeEnum> get values => _$apiSuccessEnvelopeCodeEnumValues;
  static ApiSuccessEnvelopeCodeEnum valueOf(String name) => _$apiSuccessEnvelopeCodeEnumValueOf(name);
}
