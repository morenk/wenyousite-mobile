//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'api_pagination_meta.g.dart';

/// ApiPaginationMeta
///
/// Properties:
/// * [cursor]
/// * [hasMore]
@BuiltValue()
abstract class ApiPaginationMeta implements Built<ApiPaginationMeta, ApiPaginationMetaBuilder> {
  @BuiltValueField(wireName: r'cursor')
  String? get cursor;

  @BuiltValueField(wireName: r'hasMore')
  bool get hasMore;

  ApiPaginationMeta._();

  factory ApiPaginationMeta([void updates(ApiPaginationMetaBuilder b)]) = _$ApiPaginationMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApiPaginationMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApiPaginationMeta> get serializer => _$ApiPaginationMetaSerializer();
}

class _$ApiPaginationMetaSerializer implements PrimitiveSerializer<ApiPaginationMeta> {
  @override
  final Iterable<Type> types = const [ApiPaginationMeta, _$ApiPaginationMeta];

  @override
  final String wireName = r'ApiPaginationMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApiPaginationMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'cursor';
    yield object.cursor == null ? null : serializers.serialize(
      object.cursor,
      specifiedType: const FullType.nullable(String),
    );
    yield r'hasMore';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ApiPaginationMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ApiPaginationMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cursor = valueDes;
          break;
        case r'hasMore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ApiPaginationMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApiPaginationMetaBuilder();
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
