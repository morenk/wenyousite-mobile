//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'request_code_dto.g.dart';

/// RequestCodeDto
///
/// Properties:
/// * [email] - 注册邮箱
@BuiltValue()
abstract class RequestCodeDto implements Built<RequestCodeDto, RequestCodeDtoBuilder> {
  /// 注册邮箱
  @BuiltValueField(wireName: r'email')
  String get email;

  RequestCodeDto._();

  factory RequestCodeDto([void updates(RequestCodeDtoBuilder b)]) = _$RequestCodeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RequestCodeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RequestCodeDto> get serializer => _$RequestCodeDtoSerializer();
}

class _$RequestCodeDtoSerializer implements PrimitiveSerializer<RequestCodeDto> {
  @override
  final Iterable<Type> types = const [RequestCodeDto, _$RequestCodeDto];

  @override
  final String wireName = r'RequestCodeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RequestCodeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RequestCodeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RequestCodeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RequestCodeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RequestCodeDtoBuilder();
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
