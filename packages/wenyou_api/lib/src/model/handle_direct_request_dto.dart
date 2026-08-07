//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'handle_direct_request_dto.g.dart';

/// HandleDirectRequestDto
///
/// Properties:
/// * [action]
@BuiltValue()
abstract class HandleDirectRequestDto implements Built<HandleDirectRequestDto, HandleDirectRequestDtoBuilder> {
  @BuiltValueField(wireName: r'action')
  HandleDirectRequestDtoActionEnum get action;
  // enum actionEnum {  ACCEPT,  DECLINE,  };

  HandleDirectRequestDto._();

  factory HandleDirectRequestDto([void updates(HandleDirectRequestDtoBuilder b)]) = _$HandleDirectRequestDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HandleDirectRequestDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HandleDirectRequestDto> get serializer => _$HandleDirectRequestDtoSerializer();
}

class _$HandleDirectRequestDtoSerializer implements PrimitiveSerializer<HandleDirectRequestDto> {
  @override
  final Iterable<Type> types = const [HandleDirectRequestDto, _$HandleDirectRequestDto];

  @override
  final String wireName = r'HandleDirectRequestDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HandleDirectRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(HandleDirectRequestDtoActionEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HandleDirectRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HandleDirectRequestDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HandleDirectRequestDtoActionEnum),
          ) as HandleDirectRequestDtoActionEnum;
          result.action = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HandleDirectRequestDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HandleDirectRequestDtoBuilder();
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

class HandleDirectRequestDtoActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ACCEPT')
  static const HandleDirectRequestDtoActionEnum ACCEPT = _$handleDirectRequestDtoActionEnum_ACCEPT;
  @BuiltValueEnumConst(wireName: r'DECLINE')
  static const HandleDirectRequestDtoActionEnum DECLINE = _$handleDirectRequestDtoActionEnum_DECLINE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const HandleDirectRequestDtoActionEnum unknownDefaultOpenApi = _$handleDirectRequestDtoActionEnum_unknownDefaultOpenApi;

  static Serializer<HandleDirectRequestDtoActionEnum> get serializer => _$handleDirectRequestDtoActionEnumSerializer;

  const HandleDirectRequestDtoActionEnum._(String name): super(name);

  static BuiltSet<HandleDirectRequestDtoActionEnum> get values => _$handleDirectRequestDtoActionEnumValues;
  static HandleDirectRequestDtoActionEnum valueOf(String name) => _$handleDirectRequestDtoActionEnumValueOf(name);
}
