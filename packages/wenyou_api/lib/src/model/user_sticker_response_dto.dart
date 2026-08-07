//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/sticker_asset_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_sticker_response_dto.g.dart';

/// UserStickerResponseDto
///
/// Properties:
/// * [id]
/// * [position]
/// * [lastUsedAt]
/// * [asset]
/// * [markdown] - 插入编辑器时使用的标准 Markdown
@BuiltValue()
abstract class UserStickerResponseDto implements Built<UserStickerResponseDto, UserStickerResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'position')
  num get position;

  @BuiltValueField(wireName: r'lastUsedAt')
  DateTime? get lastUsedAt;

  @BuiltValueField(wireName: r'asset')
  StickerAssetResponseDto get asset;

  /// 插入编辑器时使用的标准 Markdown
  @BuiltValueField(wireName: r'markdown')
  String get markdown;

  UserStickerResponseDto._();

  factory UserStickerResponseDto([void updates(UserStickerResponseDtoBuilder b)]) = _$UserStickerResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserStickerResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserStickerResponseDto> get serializer => _$UserStickerResponseDtoSerializer();
}

class _$UserStickerResponseDtoSerializer implements PrimitiveSerializer<UserStickerResponseDto> {
  @override
  final Iterable<Type> types = const [UserStickerResponseDto, _$UserStickerResponseDto];

  @override
  final String wireName = r'UserStickerResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserStickerResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(num),
    );
    if (object.lastUsedAt != null) {
      yield r'lastUsedAt';
      yield serializers.serialize(
        object.lastUsedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'asset';
    yield serializers.serialize(
      object.asset,
      specifiedType: const FullType(StickerAssetResponseDto),
    );
    yield r'markdown';
    yield serializers.serialize(
      object.markdown,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserStickerResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserStickerResponseDtoBuilder result,
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
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.position = valueDes;
          break;
        case r'lastUsedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastUsedAt = valueDes;
          break;
        case r'asset':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StickerAssetResponseDto),
          ) as StickerAssetResponseDto;
          result.asset.replace(valueDes);
          break;
        case r'markdown':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.markdown = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserStickerResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserStickerResponseDtoBuilder();
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
