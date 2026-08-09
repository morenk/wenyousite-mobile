//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/invite_owner_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invite_thread_preview_response_dto.g.dart';

/// InviteThreadPreviewResponseDto
///
/// Properties:
/// * [id] - 主题帖 ID
/// * [title] - 主题帖标题
/// * [category] - 动态分类 slug
/// * [status] - 主题帖状态
/// * [owner] - 楼主信息
/// * [memberCount] - 当前参与人数
/// * [createdAt] - 主题帖创建时间
@BuiltValue()
abstract class InviteThreadPreviewResponseDto implements Built<InviteThreadPreviewResponseDto, InviteThreadPreviewResponseDtoBuilder> {
  /// 主题帖 ID
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 主题帖标题
  @BuiltValueField(wireName: r'title')
  String get title;

  /// 动态分类 slug
  @BuiltValueField(wireName: r'category')
  String? get category;

  /// 主题帖状态
  @BuiltValueField(wireName: r'status')
  InviteThreadPreviewResponseDtoStatusEnum get status;
  // enum statusEnum {  RECRUITING,  CLOSED,  FINISHED,  };

  /// 楼主信息
  @BuiltValueField(wireName: r'owner')
  InviteOwnerResponseDto get owner;

  /// 当前参与人数
  @BuiltValueField(wireName: r'memberCount')
  num get memberCount;

  /// 主题帖创建时间
  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  InviteThreadPreviewResponseDto._();

  factory InviteThreadPreviewResponseDto([void updates(InviteThreadPreviewResponseDtoBuilder b)]) = _$InviteThreadPreviewResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InviteThreadPreviewResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InviteThreadPreviewResponseDto> get serializer => _$InviteThreadPreviewResponseDtoSerializer();
}

class _$InviteThreadPreviewResponseDtoSerializer implements PrimitiveSerializer<InviteThreadPreviewResponseDto> {
  @override
  final Iterable<Type> types = const [InviteThreadPreviewResponseDto, _$InviteThreadPreviewResponseDto];

  @override
  final String wireName = r'InviteThreadPreviewResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InviteThreadPreviewResponseDto object, {
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
    yield r'category';
    yield object.category == null ? null : serializers.serialize(
      object.category,
      specifiedType: const FullType.nullable(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(InviteThreadPreviewResponseDtoStatusEnum),
    );
    yield r'owner';
    yield serializers.serialize(
      object.owner,
      specifiedType: const FullType(InviteOwnerResponseDto),
    );
    yield r'memberCount';
    yield serializers.serialize(
      object.memberCount,
      specifiedType: const FullType(num),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InviteThreadPreviewResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InviteThreadPreviewResponseDtoBuilder result,
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
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.category = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(InviteThreadPreviewResponseDtoStatusEnum),
          ) as InviteThreadPreviewResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'owner':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(InviteOwnerResponseDto),
          ) as InviteOwnerResponseDto;
          result.owner.replace(valueDes);
          break;
        case r'memberCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.memberCount = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InviteThreadPreviewResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InviteThreadPreviewResponseDtoBuilder();
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

class InviteThreadPreviewResponseDtoStatusEnum extends EnumClass {

  /// 主题帖状态
  @BuiltValueEnumConst(wireName: r'RECRUITING')
  static const InviteThreadPreviewResponseDtoStatusEnum RECRUITING = _$inviteThreadPreviewResponseDtoStatusEnum_RECRUITING;
  /// 主题帖状态
  @BuiltValueEnumConst(wireName: r'CLOSED')
  static const InviteThreadPreviewResponseDtoStatusEnum CLOSED = _$inviteThreadPreviewResponseDtoStatusEnum_CLOSED;
  /// 主题帖状态
  @BuiltValueEnumConst(wireName: r'FINISHED')
  static const InviteThreadPreviewResponseDtoStatusEnum FINISHED = _$inviteThreadPreviewResponseDtoStatusEnum_FINISHED;
  /// 主题帖状态
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const InviteThreadPreviewResponseDtoStatusEnum unknownDefaultOpenApi = _$inviteThreadPreviewResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<InviteThreadPreviewResponseDtoStatusEnum> get serializer => _$inviteThreadPreviewResponseDtoStatusEnumSerializer;

  const InviteThreadPreviewResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<InviteThreadPreviewResponseDtoStatusEnum> get values => _$inviteThreadPreviewResponseDtoStatusEnumValues;
  static InviteThreadPreviewResponseDtoStatusEnum valueOf(String name) => _$inviteThreadPreviewResponseDtoStatusEnumValueOf(name);
}
