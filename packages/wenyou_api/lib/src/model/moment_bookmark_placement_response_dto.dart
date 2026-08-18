//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_bookmark_placement_response_dto.g.dart';

/// MomentBookmarkPlacementResponseDto
///
/// Properties:
/// * [momentId]
/// * [folderId]
@BuiltValue()
abstract class MomentBookmarkPlacementResponseDto implements Built<MomentBookmarkPlacementResponseDto, MomentBookmarkPlacementResponseDtoBuilder> {
  @BuiltValueField(wireName: r'momentId')
  String get momentId;

  @BuiltValueField(wireName: r'folderId')
  String get folderId;

  MomentBookmarkPlacementResponseDto._();

  factory MomentBookmarkPlacementResponseDto([void updates(MomentBookmarkPlacementResponseDtoBuilder b)]) = _$MomentBookmarkPlacementResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentBookmarkPlacementResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentBookmarkPlacementResponseDto> get serializer => _$MomentBookmarkPlacementResponseDtoSerializer();
}

class _$MomentBookmarkPlacementResponseDtoSerializer implements PrimitiveSerializer<MomentBookmarkPlacementResponseDto> {
  @override
  final Iterable<Type> types = const [MomentBookmarkPlacementResponseDto, _$MomentBookmarkPlacementResponseDto];

  @override
  final String wireName = r'MomentBookmarkPlacementResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentBookmarkPlacementResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'momentId';
    yield serializers.serialize(
      object.momentId,
      specifiedType: const FullType(String),
    );
    yield r'folderId';
    yield serializers.serialize(
      object.folderId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MomentBookmarkPlacementResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentBookmarkPlacementResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'momentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.momentId = valueDes;
          break;
        case r'folderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.folderId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MomentBookmarkPlacementResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentBookmarkPlacementResponseDtoBuilder();
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
