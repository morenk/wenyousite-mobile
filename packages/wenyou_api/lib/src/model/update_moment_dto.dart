//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_moment_dto.g.dart';

/// UpdateMomentDto
///
/// Properties:
/// * [title]
/// * [content]
/// * [mediaIds]
/// * [coverMediaId]
/// * [version] - 乐观锁版本
@BuiltValue()
abstract class UpdateMomentDto implements Built<UpdateMomentDto, UpdateMomentDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'content')
  String? get content;

  @BuiltValueField(wireName: r'mediaIds')
  BuiltList<String>? get mediaIds;

  @BuiltValueField(wireName: r'coverMediaId')
  String? get coverMediaId;

  /// 乐观锁版本
  @BuiltValueField(wireName: r'version')
  num get version;

  UpdateMomentDto._();

  factory UpdateMomentDto([void updates(UpdateMomentDtoBuilder b)]) = _$UpdateMomentDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateMomentDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateMomentDto> get serializer => _$UpdateMomentDtoSerializer();
}

class _$UpdateMomentDtoSerializer implements PrimitiveSerializer<UpdateMomentDto> {
  @override
  final Iterable<Type> types = const [UpdateMomentDto, _$UpdateMomentDto];

  @override
  final String wireName = r'UpdateMomentDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateMomentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    if (object.mediaIds != null) {
      yield r'mediaIds';
      yield serializers.serialize(
        object.mediaIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.coverMediaId != null) {
      yield r'coverMediaId';
      yield serializers.serialize(
        object.coverMediaId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateMomentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateMomentDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'mediaIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.mediaIds.replace(valueDes);
          break;
        case r'coverMediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.coverMediaId = valueDes;
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
  UpdateMomentDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateMomentDtoBuilder();
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
