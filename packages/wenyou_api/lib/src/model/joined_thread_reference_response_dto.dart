//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'joined_thread_reference_response_dto.g.dart';

/// JoinedThreadReferenceResponseDto
///
/// Properties:
/// * [id]
/// * [title]
@BuiltValue()
abstract class JoinedThreadReferenceResponseDto implements Built<JoinedThreadReferenceResponseDto, JoinedThreadReferenceResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String? get title;

  JoinedThreadReferenceResponseDto._();

  factory JoinedThreadReferenceResponseDto([void updates(JoinedThreadReferenceResponseDtoBuilder b)]) = _$JoinedThreadReferenceResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(JoinedThreadReferenceResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<JoinedThreadReferenceResponseDto> get serializer => _$JoinedThreadReferenceResponseDtoSerializer();
}

class _$JoinedThreadReferenceResponseDtoSerializer implements PrimitiveSerializer<JoinedThreadReferenceResponseDto> {
  @override
  final Iterable<Type> types = const [JoinedThreadReferenceResponseDto, _$JoinedThreadReferenceResponseDto];

  @override
  final String wireName = r'JoinedThreadReferenceResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    JoinedThreadReferenceResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
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
    JoinedThreadReferenceResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required JoinedThreadReferenceResponseDtoBuilder result,
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
  JoinedThreadReferenceResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = JoinedThreadReferenceResponseDtoBuilder();
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
