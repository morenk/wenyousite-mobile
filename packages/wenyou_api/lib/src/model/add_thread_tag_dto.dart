//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'add_thread_tag_dto.g.dart';

/// AddThreadTagDto
///
/// Properties:
/// * [name] - 主题帖标签名
@BuiltValue()
abstract class AddThreadTagDto implements Built<AddThreadTagDto, AddThreadTagDtoBuilder> {
  /// 主题帖标签名
  @BuiltValueField(wireName: r'name')
  String get name;

  AddThreadTagDto._();

  factory AddThreadTagDto([void updates(AddThreadTagDtoBuilder b)]) = _$AddThreadTagDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddThreadTagDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AddThreadTagDto> get serializer => _$AddThreadTagDtoSerializer();
}

class _$AddThreadTagDtoSerializer implements PrimitiveSerializer<AddThreadTagDto> {
  @override
  final Iterable<Type> types = const [AddThreadTagDto, _$AddThreadTagDto];

  @override
  final String wireName = r'AddThreadTagDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AddThreadTagDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AddThreadTagDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AddThreadTagDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AddThreadTagDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddThreadTagDtoBuilder();
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
