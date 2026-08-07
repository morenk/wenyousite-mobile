//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'draft_thread_count_response_dto.g.dart';

/// DraftThreadCountResponseDto
///
/// Properties:
/// * [subthreads]
/// * [posts]
@BuiltValue()
abstract class DraftThreadCountResponseDto implements Built<DraftThreadCountResponseDto, DraftThreadCountResponseDtoBuilder> {
  @BuiltValueField(wireName: r'subthreads')
  num get subthreads;

  @BuiltValueField(wireName: r'posts')
  num get posts;

  DraftThreadCountResponseDto._();

  factory DraftThreadCountResponseDto([void updates(DraftThreadCountResponseDtoBuilder b)]) = _$DraftThreadCountResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DraftThreadCountResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DraftThreadCountResponseDto> get serializer => _$DraftThreadCountResponseDtoSerializer();
}

class _$DraftThreadCountResponseDtoSerializer implements PrimitiveSerializer<DraftThreadCountResponseDto> {
  @override
  final Iterable<Type> types = const [DraftThreadCountResponseDto, _$DraftThreadCountResponseDto];

  @override
  final String wireName = r'DraftThreadCountResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DraftThreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'subthreads';
    yield serializers.serialize(
      object.subthreads,
      specifiedType: const FullType(num),
    );
    yield r'posts';
    yield serializers.serialize(
      object.posts,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DraftThreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DraftThreadCountResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'subthreads':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.subthreads = valueDes;
          break;
        case r'posts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.posts = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DraftThreadCountResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DraftThreadCountResponseDtoBuilder();
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
