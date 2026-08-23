//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posting_capability_response_dto.g.dart';

/// PostingCapabilityResponseDto
///
/// Properties:
/// * [canPost]
/// * [denialReason]
@BuiltValue()
abstract class PostingCapabilityResponseDto implements Built<PostingCapabilityResponseDto, PostingCapabilityResponseDtoBuilder> {
  @BuiltValueField(wireName: r'canPost')
  bool get canPost;

  @BuiltValueField(wireName: r'denialReason')
  PostingCapabilityResponseDtoDenialReasonEnum? get denialReason;
  // enum denialReasonEnum {  AUTHENTICATION_REQUIRED,  BLOCKED_RELATION,  COLLABORATOR_REQUIRED,  PLAYER_REQUIRED,  };

  PostingCapabilityResponseDto._();

  factory PostingCapabilityResponseDto([void updates(PostingCapabilityResponseDtoBuilder b)]) = _$PostingCapabilityResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostingCapabilityResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostingCapabilityResponseDto> get serializer => _$PostingCapabilityResponseDtoSerializer();
}

class _$PostingCapabilityResponseDtoSerializer implements PrimitiveSerializer<PostingCapabilityResponseDto> {
  @override
  final Iterable<Type> types = const [PostingCapabilityResponseDto, _$PostingCapabilityResponseDto];

  @override
  final String wireName = r'PostingCapabilityResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostingCapabilityResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'canPost';
    yield serializers.serialize(
      object.canPost,
      specifiedType: const FullType(bool),
    );
    yield r'denialReason';
    yield object.denialReason == null ? null : serializers.serialize(
      object.denialReason,
      specifiedType: const FullType.nullable(PostingCapabilityResponseDtoDenialReasonEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostingCapabilityResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostingCapabilityResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'canPost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canPost = valueDes;
          break;
        case r'denialReason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PostingCapabilityResponseDtoDenialReasonEnum),
          ) as PostingCapabilityResponseDtoDenialReasonEnum?;
          if (valueDes == null) continue;
          result.denialReason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostingCapabilityResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostingCapabilityResponseDtoBuilder();
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

class PostingCapabilityResponseDtoDenialReasonEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'AUTHENTICATION_REQUIRED')
  static const PostingCapabilityResponseDtoDenialReasonEnum AUTHENTICATION_REQUIRED = _$postingCapabilityResponseDtoDenialReasonEnum_AUTHENTICATION_REQUIRED;
  @BuiltValueEnumConst(wireName: r'BLOCKED_RELATION')
  static const PostingCapabilityResponseDtoDenialReasonEnum BLOCKED_RELATION = _$postingCapabilityResponseDtoDenialReasonEnum_BLOCKED_RELATION;
  @BuiltValueEnumConst(wireName: r'COLLABORATOR_REQUIRED')
  static const PostingCapabilityResponseDtoDenialReasonEnum COLLABORATOR_REQUIRED = _$postingCapabilityResponseDtoDenialReasonEnum_COLLABORATOR_REQUIRED;
  @BuiltValueEnumConst(wireName: r'PLAYER_REQUIRED')
  static const PostingCapabilityResponseDtoDenialReasonEnum PLAYER_REQUIRED = _$postingCapabilityResponseDtoDenialReasonEnum_PLAYER_REQUIRED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const PostingCapabilityResponseDtoDenialReasonEnum unknownDefaultOpenApi = _$postingCapabilityResponseDtoDenialReasonEnum_unknownDefaultOpenApi;

  static Serializer<PostingCapabilityResponseDtoDenialReasonEnum> get serializer => _$postingCapabilityResponseDtoDenialReasonEnumSerializer;

  const PostingCapabilityResponseDtoDenialReasonEnum._(String name): super(name);

  static BuiltSet<PostingCapabilityResponseDtoDenialReasonEnum> get values => _$postingCapabilityResponseDtoDenialReasonEnumValues;
  static PostingCapabilityResponseDtoDenialReasonEnum valueOf(String name) => _$postingCapabilityResponseDtoDenialReasonEnumValueOf(name);
}
