//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recent_reply_subthread_response_dto.g.dart';

/// RecentReplySubthreadResponseDto
///
/// Properties:
/// * [title]
@BuiltValue()
abstract class RecentReplySubthreadResponseDto implements Built<RecentReplySubthreadResponseDto, RecentReplySubthreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String get title;

  RecentReplySubthreadResponseDto._();

  factory RecentReplySubthreadResponseDto([void updates(RecentReplySubthreadResponseDtoBuilder b)]) = _$RecentReplySubthreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecentReplySubthreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecentReplySubthreadResponseDto> get serializer => _$RecentReplySubthreadResponseDtoSerializer();
}

class _$RecentReplySubthreadResponseDtoSerializer implements PrimitiveSerializer<RecentReplySubthreadResponseDto> {
  @override
  final Iterable<Type> types = const [RecentReplySubthreadResponseDto, _$RecentReplySubthreadResponseDto];

  @override
  final String wireName = r'RecentReplySubthreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecentReplySubthreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecentReplySubthreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecentReplySubthreadResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  RecentReplySubthreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecentReplySubthreadResponseDtoBuilder();
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
