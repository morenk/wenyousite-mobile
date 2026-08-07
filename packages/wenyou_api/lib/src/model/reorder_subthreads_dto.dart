//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reorder_subthreads_dto.g.dart';

/// ReorderSubthreadsDto
///
/// Properties:
/// * [ids] - 按目标顺序排列的子贴 ID 列表，第一项将成为 sortOrder=0（默认子贴，不可变）
@BuiltValue()
abstract class ReorderSubthreadsDto implements Built<ReorderSubthreadsDto, ReorderSubthreadsDtoBuilder> {
  /// 按目标顺序排列的子贴 ID 列表，第一项将成为 sortOrder=0（默认子贴，不可变）
  @BuiltValueField(wireName: r'ids')
  BuiltList<String> get ids;

  ReorderSubthreadsDto._();

  factory ReorderSubthreadsDto([void updates(ReorderSubthreadsDtoBuilder b)]) = _$ReorderSubthreadsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReorderSubthreadsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReorderSubthreadsDto> get serializer => _$ReorderSubthreadsDtoSerializer();
}

class _$ReorderSubthreadsDtoSerializer implements PrimitiveSerializer<ReorderSubthreadsDto> {
  @override
  final Iterable<Type> types = const [ReorderSubthreadsDto, _$ReorderSubthreadsDto];

  @override
  final String wireName = r'ReorderSubthreadsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReorderSubthreadsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ids';
    yield serializers.serialize(
      object.ids,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReorderSubthreadsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReorderSubthreadsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.ids.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReorderSubthreadsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReorderSubthreadsDtoBuilder();
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
