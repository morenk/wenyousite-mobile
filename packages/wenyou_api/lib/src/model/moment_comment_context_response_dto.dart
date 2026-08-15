//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_comment_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_comment_context_response_dto.g.dart';

/// MomentCommentContextResponseDto
///
/// Properties:
/// * [root] - 目标所在的主评论；主评论已删除但仍有可见回复时返回墓碑内容
/// * [target] - 需要精确定位的可见主评论或楼中楼回复
/// * [replyCount] - 该主评论下当前查看者可见的楼中楼回复数
@BuiltValue()
abstract class MomentCommentContextResponseDto implements Built<MomentCommentContextResponseDto, MomentCommentContextResponseDtoBuilder> {
  /// 目标所在的主评论；主评论已删除但仍有可见回复时返回墓碑内容
  @BuiltValueField(wireName: r'root')
  MomentCommentResponseDto get root;

  /// 需要精确定位的可见主评论或楼中楼回复
  @BuiltValueField(wireName: r'target')
  MomentCommentResponseDto get target;

  /// 该主评论下当前查看者可见的楼中楼回复数
  @BuiltValueField(wireName: r'replyCount')
  num get replyCount;

  MomentCommentContextResponseDto._();

  factory MomentCommentContextResponseDto([void updates(MomentCommentContextResponseDtoBuilder b)]) = _$MomentCommentContextResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentCommentContextResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentCommentContextResponseDto> get serializer => _$MomentCommentContextResponseDtoSerializer();
}

class _$MomentCommentContextResponseDtoSerializer implements PrimitiveSerializer<MomentCommentContextResponseDto> {
  @override
  final Iterable<Type> types = const [MomentCommentContextResponseDto, _$MomentCommentContextResponseDto];

  @override
  final String wireName = r'MomentCommentContextResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentCommentContextResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'root';
    yield serializers.serialize(
      object.root,
      specifiedType: const FullType(MomentCommentResponseDto),
    );
    yield r'target';
    yield serializers.serialize(
      object.target,
      specifiedType: const FullType(MomentCommentResponseDto),
    );
    yield r'replyCount';
    yield serializers.serialize(
      object.replyCount,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MomentCommentContextResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentCommentContextResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'root':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentCommentResponseDto),
          ) as MomentCommentResponseDto;
          result.root.replace(valueDes);
          break;
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentCommentResponseDto),
          ) as MomentCommentResponseDto;
          result.target.replace(valueDes);
          break;
        case r'replyCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
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
  MomentCommentContextResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentCommentContextResponseDtoBuilder();
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
