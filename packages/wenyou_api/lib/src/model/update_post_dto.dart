//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_post_dto.g.dart';

/// UpdatePostDto
///
/// Properties:
/// * [content] - 新正文；骰子节点随正文移动或删除，新增节点由服务端结算
/// * [version] - 乐观锁版本号（必填，前端需先 fetch 获取当前 version，传入过期版本会返回 409）
@BuiltValue()
abstract class UpdatePostDto implements Built<UpdatePostDto, UpdatePostDtoBuilder> {
  /// 新正文；骰子节点随正文移动或删除，新增节点由服务端结算
  @BuiltValueField(wireName: r'content')
  String get content;

  /// 乐观锁版本号（必填，前端需先 fetch 获取当前 version，传入过期版本会返回 409）
  @BuiltValueField(wireName: r'version')
  num get version;

  UpdatePostDto._();

  factory UpdatePostDto([void updates(UpdatePostDtoBuilder b)]) = _$UpdatePostDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdatePostDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdatePostDto> get serializer => _$UpdatePostDtoSerializer();
}

class _$UpdatePostDtoSerializer implements PrimitiveSerializer<UpdatePostDto> {
  @override
  final Iterable<Type> types = const [UpdatePostDto, _$UpdatePostDto];

  @override
  final String wireName = r'UpdatePostDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdatePostDto object, {
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
    UpdatePostDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdatePostDtoBuilder result,
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
  UpdatePostDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdatePostDtoBuilder();
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
