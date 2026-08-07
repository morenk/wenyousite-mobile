//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'draft_default_subthread_response_dto.g.dart';

/// DraftDefaultSubthreadResponseDto
///
/// Properties:
/// * [id]
/// * [title]
@BuiltValue()
abstract class DraftDefaultSubthreadResponseDto implements Built<DraftDefaultSubthreadResponseDto, DraftDefaultSubthreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  DraftDefaultSubthreadResponseDto._();

  factory DraftDefaultSubthreadResponseDto([void updates(DraftDefaultSubthreadResponseDtoBuilder b)]) = _$DraftDefaultSubthreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DraftDefaultSubthreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DraftDefaultSubthreadResponseDto> get serializer => _$DraftDefaultSubthreadResponseDtoSerializer();
}

class _$DraftDefaultSubthreadResponseDtoSerializer implements PrimitiveSerializer<DraftDefaultSubthreadResponseDto> {
  @override
  final Iterable<Type> types = const [DraftDefaultSubthreadResponseDto, _$DraftDefaultSubthreadResponseDto];

  @override
  final String wireName = r'DraftDefaultSubthreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DraftDefaultSubthreadResponseDto object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    DraftDefaultSubthreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DraftDefaultSubthreadResponseDtoBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DraftDefaultSubthreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DraftDefaultSubthreadResponseDtoBuilder();
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
