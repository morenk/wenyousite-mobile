//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_draft_dto.g.dart';

/// UpdateDraftDto
///
/// Properties:
/// * [content] - 更新后的草稿正文
/// * [version] - 当前乐观锁版本
@BuiltValue()
abstract class UpdateDraftDto implements Built<UpdateDraftDto, UpdateDraftDtoBuilder> {
  /// 更新后的草稿正文
  @BuiltValueField(wireName: r'content')
  String get content;

  /// 当前乐观锁版本
  @BuiltValueField(wireName: r'version')
  num get version;

  UpdateDraftDto._();

  factory UpdateDraftDto([void updates(UpdateDraftDtoBuilder b)]) = _$UpdateDraftDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateDraftDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateDraftDto> get serializer => _$UpdateDraftDtoSerializer();
}

class _$UpdateDraftDtoSerializer implements PrimitiveSerializer<UpdateDraftDto> {
  @override
  final Iterable<Type> types = const [UpdateDraftDto, _$UpdateDraftDto];

  @override
  final String wireName = r'UpdateDraftDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateDraftDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateDraftDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateDraftDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateDraftDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateDraftDtoBuilder();
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
