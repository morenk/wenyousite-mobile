//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/media_display_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rp_identity_response_dto.g.dart';

/// RpIdentityResponseDto
///
/// Properties:
/// * [id]
/// * [nickname] - 实际展示昵称，已应用账号缺省值
/// * [avatar]
/// * [avatarDisplay]
@BuiltValue()
abstract class RpIdentityResponseDto implements Built<RpIdentityResponseDto, RpIdentityResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 实际展示昵称，已应用账号缺省值
  @BuiltValueField(wireName: r'nickname')
  String get nickname;

  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  @BuiltValueField(wireName: r'avatarDisplay')
  MediaDisplayResponseDto? get avatarDisplay;

  RpIdentityResponseDto._();

  factory RpIdentityResponseDto([void updates(RpIdentityResponseDtoBuilder b)]) = _$RpIdentityResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RpIdentityResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RpIdentityResponseDto> get serializer => _$RpIdentityResponseDtoSerializer();
}

class _$RpIdentityResponseDtoSerializer implements PrimitiveSerializer<RpIdentityResponseDto> {
  @override
  final Iterable<Type> types = const [RpIdentityResponseDto, _$RpIdentityResponseDto];

  @override
  final String wireName = r'RpIdentityResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RpIdentityResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'nickname';
    yield serializers.serialize(
      object.nickname,
      specifiedType: const FullType(String),
    );
    yield r'avatar';
    yield object.avatar == null ? null : serializers.serialize(
      object.avatar,
      specifiedType: const FullType.nullable(String),
    );
    if (object.avatarDisplay != null) {
      yield r'avatarDisplay';
      yield serializers.serialize(
        object.avatarDisplay,
        specifiedType: const FullType.nullable(MediaDisplayResponseDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RpIdentityResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RpIdentityResponseDtoBuilder result,
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
        case r'nickname':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nickname = valueDes;
          break;
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatar = valueDes;
          break;
        case r'avatarDisplay':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MediaDisplayResponseDto),
          ) as MediaDisplayResponseDto?;
          if (valueDes == null) continue;
          result.avatarDisplay.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RpIdentityResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RpIdentityResponseDtoBuilder();
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
