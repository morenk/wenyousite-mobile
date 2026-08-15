//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'set_profile_cover_dto.g.dart';

/// SetProfileCoverDto
///
/// Properties:
/// * [mediaId] - 电脑端 3:1 背景图 mediaId
/// * [mobileMediaId] - 移动端 2:1 背景图 mediaId；旧客户端省略时会清空移动端裁切
@BuiltValue()
abstract class SetProfileCoverDto implements Built<SetProfileCoverDto, SetProfileCoverDtoBuilder> {
  /// 电脑端 3:1 背景图 mediaId
  @BuiltValueField(wireName: r'mediaId')
  String get mediaId;

  /// 移动端 2:1 背景图 mediaId；旧客户端省略时会清空移动端裁切
  @BuiltValueField(wireName: r'mobileMediaId')
  String? get mobileMediaId;

  SetProfileCoverDto._();

  factory SetProfileCoverDto([void updates(SetProfileCoverDtoBuilder b)]) = _$SetProfileCoverDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SetProfileCoverDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SetProfileCoverDto> get serializer => _$SetProfileCoverDtoSerializer();
}

class _$SetProfileCoverDtoSerializer implements PrimitiveSerializer<SetProfileCoverDto> {
  @override
  final Iterable<Type> types = const [SetProfileCoverDto, _$SetProfileCoverDto];

  @override
  final String wireName = r'SetProfileCoverDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SetProfileCoverDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mediaId';
    yield serializers.serialize(
      object.mediaId,
      specifiedType: const FullType(String),
    );
    if (object.mobileMediaId != null) {
      yield r'mobileMediaId';
      yield serializers.serialize(
        object.mobileMediaId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SetProfileCoverDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SetProfileCoverDtoBuilder result,
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
        case r'mobileMediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mobileMediaId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SetProfileCoverDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SetProfileCoverDtoBuilder();
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
