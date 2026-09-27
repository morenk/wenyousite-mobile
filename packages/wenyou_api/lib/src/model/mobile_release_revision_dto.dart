//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mobile_release_revision_dto.g.dart';

/// MobileReleaseRevisionDto
///
/// Properties:
/// * [revision] - 最后读取的编辑 revision；竞争返回 HTTP 409，重新读取后再操作
@BuiltValue()
abstract class MobileReleaseRevisionDto implements Built<MobileReleaseRevisionDto, MobileReleaseRevisionDtoBuilder> {
  /// 最后读取的编辑 revision；竞争返回 HTTP 409，重新读取后再操作
  @BuiltValueField(wireName: r'revision')
  num get revision;

  MobileReleaseRevisionDto._();

  factory MobileReleaseRevisionDto([void updates(MobileReleaseRevisionDtoBuilder b)]) = _$MobileReleaseRevisionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MobileReleaseRevisionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MobileReleaseRevisionDto> get serializer => _$MobileReleaseRevisionDtoSerializer();
}

class _$MobileReleaseRevisionDtoSerializer implements PrimitiveSerializer<MobileReleaseRevisionDto> {
  @override
  final Iterable<Type> types = const [MobileReleaseRevisionDto, _$MobileReleaseRevisionDto];

  @override
  final String wireName = r'MobileReleaseRevisionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MobileReleaseRevisionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MobileReleaseRevisionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MobileReleaseRevisionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.revision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MobileReleaseRevisionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MobileReleaseRevisionDtoBuilder();
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
