//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recent_reply_thread_response_dto.g.dart';

/// RecentReplyThreadResponseDto
///
/// Properties:
/// * [title]
@BuiltValue()
abstract class RecentReplyThreadResponseDto implements Built<RecentReplyThreadResponseDto, RecentReplyThreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String get title;

  RecentReplyThreadResponseDto._();

  factory RecentReplyThreadResponseDto([void updates(RecentReplyThreadResponseDtoBuilder b)]) = _$RecentReplyThreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecentReplyThreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecentReplyThreadResponseDto> get serializer => _$RecentReplyThreadResponseDtoSerializer();
}

class _$RecentReplyThreadResponseDtoSerializer implements PrimitiveSerializer<RecentReplyThreadResponseDto> {
  @override
  final Iterable<Type> types = const [RecentReplyThreadResponseDto, _$RecentReplyThreadResponseDto];

  @override
  final String wireName = r'RecentReplyThreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecentReplyThreadResponseDto object, {
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
    RecentReplyThreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecentReplyThreadResponseDtoBuilder result,
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
  RecentReplyThreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecentReplyThreadResponseDtoBuilder();
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
