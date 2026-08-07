//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/recent_reply_dice_response_dto.dart';
import 'package:wenyou_api/src/model/recent_reply_subthread_response_dto.dart';
import 'package:wenyou_api/src/model/recent_reply_thread_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recent_reply_response_dto.g.dart';

/// RecentReplyResponseDto
///
/// Properties:
/// * [id]
/// * [createdAt]
/// * [floorNumber]
/// * [parentPostId]
/// * [content]
/// * [threadId]
/// * [thread]
/// * [subthreadId]
/// * [subthread]
/// * [diceRolls]
/// * [preview]
@BuiltValue()
abstract class RecentReplyResponseDto implements Built<RecentReplyResponseDto, RecentReplyResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'floorNumber')
  num? get floorNumber;

  @BuiltValueField(wireName: r'parentPostId')
  String? get parentPostId;

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'thread')
  RecentReplyThreadResponseDto get thread;

  @BuiltValueField(wireName: r'subthreadId')
  String get subthreadId;

  @BuiltValueField(wireName: r'subthread')
  RecentReplySubthreadResponseDto get subthread;

  @BuiltValueField(wireName: r'diceRolls')
  BuiltList<RecentReplyDiceResponseDto> get diceRolls;

  @BuiltValueField(wireName: r'preview')
  String get preview;

  RecentReplyResponseDto._();

  factory RecentReplyResponseDto([void updates(RecentReplyResponseDtoBuilder b)]) = _$RecentReplyResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecentReplyResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecentReplyResponseDto> get serializer => _$RecentReplyResponseDtoSerializer();
}

class _$RecentReplyResponseDtoSerializer implements PrimitiveSerializer<RecentReplyResponseDto> {
  @override
  final Iterable<Type> types = const [RecentReplyResponseDto, _$RecentReplyResponseDto];

  @override
  final String wireName = r'RecentReplyResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecentReplyResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'floorNumber';
    yield object.floorNumber == null ? null : serializers.serialize(
      object.floorNumber,
      specifiedType: const FullType.nullable(num),
    );
    yield r'parentPostId';
    yield object.parentPostId == null ? null : serializers.serialize(
      object.parentPostId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'threadId';
    yield serializers.serialize(
      object.threadId,
      specifiedType: const FullType(String),
    );
    yield r'thread';
    yield serializers.serialize(
      object.thread,
      specifiedType: const FullType(RecentReplyThreadResponseDto),
    );
    yield r'subthreadId';
    yield serializers.serialize(
      object.subthreadId,
      specifiedType: const FullType(String),
    );
    yield r'subthread';
    yield serializers.serialize(
      object.subthread,
      specifiedType: const FullType(RecentReplySubthreadResponseDto),
    );
    yield r'diceRolls';
    yield serializers.serialize(
      object.diceRolls,
      specifiedType: const FullType(BuiltList, [FullType(RecentReplyDiceResponseDto)]),
    );
    yield r'preview';
    yield serializers.serialize(
      object.preview,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecentReplyResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecentReplyResponseDtoBuilder result,
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
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'floorNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.floorNumber = valueDes;
          break;
        case r'parentPostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentPostId = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threadId = valueDes;
          break;
        case r'thread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RecentReplyThreadResponseDto),
          ) as RecentReplyThreadResponseDto;
          result.thread.replace(valueDes);
          break;
        case r'subthreadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subthreadId = valueDes;
          break;
        case r'subthread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RecentReplySubthreadResponseDto),
          ) as RecentReplySubthreadResponseDto;
          result.subthread.replace(valueDes);
          break;
        case r'diceRolls':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RecentReplyDiceResponseDto)]),
          ) as BuiltList<RecentReplyDiceResponseDto>;
          result.diceRolls.replace(valueDes);
          break;
        case r'preview':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.preview = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecentReplyResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecentReplyResponseDtoBuilder();
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
