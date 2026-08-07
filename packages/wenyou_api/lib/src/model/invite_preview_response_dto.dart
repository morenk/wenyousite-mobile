//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/invite_thread_preview_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invite_preview_response_dto.g.dart';

/// InvitePreviewResponseDto
///
/// Properties:
/// * [thread] - 邀请对应的主题帖概要
/// * [alreadyJoined] - 当前登录用户是否已经加入该主题帖
@BuiltValue()
abstract class InvitePreviewResponseDto implements Built<InvitePreviewResponseDto, InvitePreviewResponseDtoBuilder> {
  /// 邀请对应的主题帖概要
  @BuiltValueField(wireName: r'thread')
  InviteThreadPreviewResponseDto get thread;

  /// 当前登录用户是否已经加入该主题帖
  @BuiltValueField(wireName: r'alreadyJoined')
  bool get alreadyJoined;

  InvitePreviewResponseDto._();

  factory InvitePreviewResponseDto([void updates(InvitePreviewResponseDtoBuilder b)]) = _$InvitePreviewResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvitePreviewResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvitePreviewResponseDto> get serializer => _$InvitePreviewResponseDtoSerializer();
}

class _$InvitePreviewResponseDtoSerializer implements PrimitiveSerializer<InvitePreviewResponseDto> {
  @override
  final Iterable<Type> types = const [InvitePreviewResponseDto, _$InvitePreviewResponseDto];

  @override
  final String wireName = r'InvitePreviewResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvitePreviewResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'thread';
    yield serializers.serialize(
      object.thread,
      specifiedType: const FullType(InviteThreadPreviewResponseDto),
    );
    yield r'alreadyJoined';
    yield serializers.serialize(
      object.alreadyJoined,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InvitePreviewResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InvitePreviewResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'thread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(InviteThreadPreviewResponseDto),
          ) as InviteThreadPreviewResponseDto;
          result.thread.replace(valueDes);
          break;
        case r'alreadyJoined':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.alreadyJoined = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InvitePreviewResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvitePreviewResponseDtoBuilder();
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
