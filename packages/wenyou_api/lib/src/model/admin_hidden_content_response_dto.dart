//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_hidden_content_user_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_hidden_content_response_dto.g.dart';

/// AdminHiddenContentResponseDto
///
/// Properties:
/// * [targetType]
/// * [targetId]
/// * [summary]
/// * [author]
/// * [moderator]
/// * [hiddenAt]
/// * [reason]
/// * [canRestore]
/// * [restoreBlockedReason]
/// * [threadId]
/// * [parentPostId]
/// * [momentId]
/// * [parentCommentId]
@BuiltValue()
abstract class AdminHiddenContentResponseDto implements Built<AdminHiddenContentResponseDto, AdminHiddenContentResponseDtoBuilder> {
  @BuiltValueField(wireName: r'targetType')
  AdminHiddenContentResponseDtoTargetTypeEnum get targetType;
  // enum targetTypeEnum {  THREAD,  POST,  MOMENT,  MOMENT_COMMENT,  };

  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  @BuiltValueField(wireName: r'summary')
  String get summary;

  @BuiltValueField(wireName: r'author')
  AdminHiddenContentUserResponseDto get author;

  @BuiltValueField(wireName: r'moderator')
  AdminHiddenContentUserResponseDto? get moderator;

  @BuiltValueField(wireName: r'hiddenAt')
  DateTime get hiddenAt;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'canRestore')
  bool get canRestore;

  @BuiltValueField(wireName: r'restoreBlockedReason')
  String? get restoreBlockedReason;

  @BuiltValueField(wireName: r'threadId')
  String? get threadId;

  @BuiltValueField(wireName: r'parentPostId')
  String? get parentPostId;

  @BuiltValueField(wireName: r'momentId')
  String? get momentId;

  @BuiltValueField(wireName: r'parentCommentId')
  String? get parentCommentId;

  AdminHiddenContentResponseDto._();

  factory AdminHiddenContentResponseDto([void updates(AdminHiddenContentResponseDtoBuilder b)]) = _$AdminHiddenContentResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminHiddenContentResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminHiddenContentResponseDto> get serializer => _$AdminHiddenContentResponseDtoSerializer();
}

class _$AdminHiddenContentResponseDtoSerializer implements PrimitiveSerializer<AdminHiddenContentResponseDto> {
  @override
  final Iterable<Type> types = const [AdminHiddenContentResponseDto, _$AdminHiddenContentResponseDto];

  @override
  final String wireName = r'AdminHiddenContentResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminHiddenContentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'targetType';
    yield serializers.serialize(
      object.targetType,
      specifiedType: const FullType(AdminHiddenContentResponseDtoTargetTypeEnum),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'summary';
    yield serializers.serialize(
      object.summary,
      specifiedType: const FullType(String),
    );
    yield r'author';
    yield serializers.serialize(
      object.author,
      specifiedType: const FullType(AdminHiddenContentUserResponseDto),
    );
    yield r'moderator';
    yield object.moderator == null ? null : serializers.serialize(
      object.moderator,
      specifiedType: const FullType.nullable(AdminHiddenContentUserResponseDto),
    );
    yield r'hiddenAt';
    yield serializers.serialize(
      object.hiddenAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'reason';
    yield object.reason == null ? null : serializers.serialize(
      object.reason,
      specifiedType: const FullType.nullable(String),
    );
    yield r'canRestore';
    yield serializers.serialize(
      object.canRestore,
      specifiedType: const FullType(bool),
    );
    yield r'restoreBlockedReason';
    yield object.restoreBlockedReason == null ? null : serializers.serialize(
      object.restoreBlockedReason,
      specifiedType: const FullType.nullable(String),
    );
    yield r'threadId';
    yield object.threadId == null ? null : serializers.serialize(
      object.threadId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'parentPostId';
    yield object.parentPostId == null ? null : serializers.serialize(
      object.parentPostId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'momentId';
    yield object.momentId == null ? null : serializers.serialize(
      object.momentId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'parentCommentId';
    yield object.parentCommentId == null ? null : serializers.serialize(
      object.parentCommentId,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminHiddenContentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminHiddenContentResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'targetType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminHiddenContentResponseDtoTargetTypeEnum),
          ) as AdminHiddenContentResponseDtoTargetTypeEnum;
          result.targetType = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetId = valueDes;
          break;
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.summary = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminHiddenContentUserResponseDto),
          ) as AdminHiddenContentUserResponseDto;
          result.author.replace(valueDes);
          break;
        case r'moderator':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AdminHiddenContentUserResponseDto),
          ) as AdminHiddenContentUserResponseDto?;
          if (valueDes == null) continue;
          result.moderator.replace(valueDes);
          break;
        case r'hiddenAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.hiddenAt = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'canRestore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canRestore = valueDes;
          break;
        case r'restoreBlockedReason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.restoreBlockedReason = valueDes;
          break;
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.threadId = valueDes;
          break;
        case r'parentPostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentPostId = valueDes;
          break;
        case r'momentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.momentId = valueDes;
          break;
        case r'parentCommentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentCommentId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminHiddenContentResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminHiddenContentResponseDtoBuilder();
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

class AdminHiddenContentResponseDtoTargetTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'THREAD')
  static const AdminHiddenContentResponseDtoTargetTypeEnum THREAD = _$adminHiddenContentResponseDtoTargetTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'POST')
  static const AdminHiddenContentResponseDtoTargetTypeEnum POST = _$adminHiddenContentResponseDtoTargetTypeEnum_POST;
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const AdminHiddenContentResponseDtoTargetTypeEnum MOMENT = _$adminHiddenContentResponseDtoTargetTypeEnum_MOMENT;
  @BuiltValueEnumConst(wireName: r'MOMENT_COMMENT')
  static const AdminHiddenContentResponseDtoTargetTypeEnum MOMENT_COMMENT = _$adminHiddenContentResponseDtoTargetTypeEnum_MOMENT_COMMENT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminHiddenContentResponseDtoTargetTypeEnum unknownDefaultOpenApi = _$adminHiddenContentResponseDtoTargetTypeEnum_unknownDefaultOpenApi;

  static Serializer<AdminHiddenContentResponseDtoTargetTypeEnum> get serializer => _$adminHiddenContentResponseDtoTargetTypeEnumSerializer;

  const AdminHiddenContentResponseDtoTargetTypeEnum._(String name): super(name);

  static BuiltSet<AdminHiddenContentResponseDtoTargetTypeEnum> get values => _$adminHiddenContentResponseDtoTargetTypeEnumValues;
  static AdminHiddenContentResponseDtoTargetTypeEnum valueOf(String name) => _$adminHiddenContentResponseDtoTargetTypeEnumValueOf(name);
}
