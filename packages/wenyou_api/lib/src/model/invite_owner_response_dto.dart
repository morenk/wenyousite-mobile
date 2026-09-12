//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/media_display_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invite_owner_response_dto.g.dart';

/// InviteOwnerResponseDto
///
/// Properties:
/// * [avatarDisplay] - 头像完整 WebP 展示资源；avatar 保留来源身份
/// * [id] - 楼主用户 ID
/// * [username] - 楼主用户名
/// * [avatar] - 楼主头像 URL
@BuiltValue()
abstract class InviteOwnerResponseDto implements Built<InviteOwnerResponseDto, InviteOwnerResponseDtoBuilder> {
  /// 头像完整 WebP 展示资源；avatar 保留来源身份
  @BuiltValueField(wireName: r'avatarDisplay')
  MediaDisplayResponseDto? get avatarDisplay;

  /// 楼主用户 ID
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 楼主用户名
  @BuiltValueField(wireName: r'username')
  String get username;

  /// 楼主头像 URL
  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  InviteOwnerResponseDto._();

  factory InviteOwnerResponseDto([void updates(InviteOwnerResponseDtoBuilder b)]) = _$InviteOwnerResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InviteOwnerResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InviteOwnerResponseDto> get serializer => _$InviteOwnerResponseDtoSerializer();
}

class _$InviteOwnerResponseDtoSerializer implements PrimitiveSerializer<InviteOwnerResponseDto> {
  @override
  final Iterable<Type> types = const [InviteOwnerResponseDto, _$InviteOwnerResponseDto];

  @override
  final String wireName = r'InviteOwnerResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InviteOwnerResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.avatarDisplay != null) {
      yield r'avatarDisplay';
      yield serializers.serialize(
        object.avatarDisplay,
        specifiedType: const FullType.nullable(MediaDisplayResponseDto),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'avatar';
    yield object.avatar == null ? null : serializers.serialize(
      object.avatar,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InviteOwnerResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InviteOwnerResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avatarDisplay':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MediaDisplayResponseDto),
          ) as MediaDisplayResponseDto?;
          if (valueDes == null) continue;
          result.avatarDisplay.replace(valueDes);
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatar = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InviteOwnerResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InviteOwnerResponseDtoBuilder();
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
