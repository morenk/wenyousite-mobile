//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_activity_summary_response_dto.g.dart';

/// UserActivitySummaryResponseDto
///
/// Properties:
/// * [momentCount] - 当前查看者可见的未删除动态数
/// * [createdThreadCount] - 当前查看者可见的已发布自建主题数
/// * [playedThreadCount] - 当前查看者可见的玩家身份参与主题数；未公开时为 null
/// * [replyCount] - 当前查看者可见的存活楼层/楼中楼回复数；未公开时为 null
@BuiltValue()
abstract class UserActivitySummaryResponseDto implements Built<UserActivitySummaryResponseDto, UserActivitySummaryResponseDtoBuilder> {
  /// 当前查看者可见的未删除动态数
  @BuiltValueField(wireName: r'momentCount')
  num get momentCount;

  /// 当前查看者可见的已发布自建主题数
  @BuiltValueField(wireName: r'createdThreadCount')
  num get createdThreadCount;

  /// 当前查看者可见的玩家身份参与主题数；未公开时为 null
  @BuiltValueField(wireName: r'playedThreadCount')
  num? get playedThreadCount;

  /// 当前查看者可见的存活楼层/楼中楼回复数；未公开时为 null
  @BuiltValueField(wireName: r'replyCount')
  num? get replyCount;

  UserActivitySummaryResponseDto._();

  factory UserActivitySummaryResponseDto([void updates(UserActivitySummaryResponseDtoBuilder b)]) = _$UserActivitySummaryResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserActivitySummaryResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserActivitySummaryResponseDto> get serializer => _$UserActivitySummaryResponseDtoSerializer();
}

class _$UserActivitySummaryResponseDtoSerializer implements PrimitiveSerializer<UserActivitySummaryResponseDto> {
  @override
  final Iterable<Type> types = const [UserActivitySummaryResponseDto, _$UserActivitySummaryResponseDto];

  @override
  final String wireName = r'UserActivitySummaryResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserActivitySummaryResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'momentCount';
    yield serializers.serialize(
      object.momentCount,
      specifiedType: const FullType(num),
    );
    yield r'createdThreadCount';
    yield serializers.serialize(
      object.createdThreadCount,
      specifiedType: const FullType(num),
    );
    yield r'playedThreadCount';
    yield object.playedThreadCount == null ? null : serializers.serialize(
      object.playedThreadCount,
      specifiedType: const FullType.nullable(num),
    );
    yield r'replyCount';
    yield object.replyCount == null ? null : serializers.serialize(
      object.replyCount,
      specifiedType: const FullType.nullable(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserActivitySummaryResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserActivitySummaryResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'momentCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.momentCount = valueDes;
          break;
        case r'createdThreadCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.createdThreadCount = valueDes;
          break;
        case r'playedThreadCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.playedThreadCount = valueDes;
          break;
        case r'replyCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.replyCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserActivitySummaryResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserActivitySummaryResponseDtoBuilder();
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
