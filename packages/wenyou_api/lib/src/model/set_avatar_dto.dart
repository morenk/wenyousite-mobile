//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'set_avatar_dto.g.dart';

/// SetAvatarDto
///
/// Properties:
/// * [mediaId] - upload-url 返回的 mediaId
@BuiltValue()
abstract class SetAvatarDto implements Built<SetAvatarDto, SetAvatarDtoBuilder> {
  /// upload-url 返回的 mediaId
  @BuiltValueField(wireName: r'mediaId')
  String get mediaId;

  SetAvatarDto._();

  factory SetAvatarDto([void updates(SetAvatarDtoBuilder b)]) = _$SetAvatarDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SetAvatarDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SetAvatarDto> get serializer => _$SetAvatarDtoSerializer();
}

class _$SetAvatarDtoSerializer implements PrimitiveSerializer<SetAvatarDto> {
  @override
  final Iterable<Type> types = const [SetAvatarDto, _$SetAvatarDto];

  @override
  final String wireName = r'SetAvatarDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SetAvatarDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mediaId';
    yield serializers.serialize(
      object.mediaId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SetAvatarDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SetAvatarDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SetAvatarDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SetAvatarDtoBuilder();
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
