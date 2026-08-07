//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reordered_subthread_response_dto.g.dart';

/// ReorderedSubthreadResponseDto
///
/// Properties:
/// * [id]
/// * [title]
/// * [sortOrder]
@BuiltValue()
abstract class ReorderedSubthreadResponseDto implements Built<ReorderedSubthreadResponseDto, ReorderedSubthreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'sortOrder')
  num get sortOrder;

  ReorderedSubthreadResponseDto._();

  factory ReorderedSubthreadResponseDto([void updates(ReorderedSubthreadResponseDtoBuilder b)]) = _$ReorderedSubthreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReorderedSubthreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReorderedSubthreadResponseDto> get serializer => _$ReorderedSubthreadResponseDtoSerializer();
}

class _$ReorderedSubthreadResponseDtoSerializer implements PrimitiveSerializer<ReorderedSubthreadResponseDto> {
  @override
  final Iterable<Type> types = const [ReorderedSubthreadResponseDto, _$ReorderedSubthreadResponseDto];

  @override
  final String wireName = r'ReorderedSubthreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReorderedSubthreadResponseDto object, {
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
    yield r'sortOrder';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReorderedSubthreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReorderedSubthreadResponseDtoBuilder result,
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
        case r'sortOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.sortOrder = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReorderedSubthreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReorderedSubthreadResponseDtoBuilder();
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
