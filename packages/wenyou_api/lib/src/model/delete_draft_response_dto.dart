//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_draft_response_dto.g.dart';

/// DeleteDraftResponseDto
///
/// Properties:
/// * [message]
@BuiltValue()
abstract class DeleteDraftResponseDto implements Built<DeleteDraftResponseDto, DeleteDraftResponseDtoBuilder> {
  @BuiltValueField(wireName: r'message')
  String get message;

  DeleteDraftResponseDto._();

  factory DeleteDraftResponseDto([void updates(DeleteDraftResponseDtoBuilder b)]) = _$DeleteDraftResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteDraftResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteDraftResponseDto> get serializer => _$DeleteDraftResponseDtoSerializer();
}

class _$DeleteDraftResponseDtoSerializer implements PrimitiveSerializer<DeleteDraftResponseDto> {
  @override
  final Iterable<Type> types = const [DeleteDraftResponseDto, _$DeleteDraftResponseDto];

  @override
  final String wireName = r'DeleteDraftResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteDraftResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteDraftResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeleteDraftResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteDraftResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteDraftResponseDtoBuilder();
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
