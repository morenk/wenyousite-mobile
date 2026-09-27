//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mobile_release_snapshot_dto.g.dart';

/// MobileReleaseSnapshotDto
///
/// Properties:
/// * [summary] - 纯文本摘要；至少含一个非空白字符，不解析 Markdown/HTML
/// * [items] - 1–30 条纯文本，每条最多 500 字符且非空白；客户端按文本显示
/// * [revision]
/// * [confirmedAt]
@BuiltValue()
abstract class MobileReleaseSnapshotDto implements Built<MobileReleaseSnapshotDto, MobileReleaseSnapshotDtoBuilder> {
  /// 纯文本摘要；至少含一个非空白字符，不解析 Markdown/HTML
  @BuiltValueField(wireName: r'summary')
  String get summary;

  /// 1–30 条纯文本，每条最多 500 字符且非空白；客户端按文本显示
  @BuiltValueField(wireName: r'items')
  BuiltList<String> get items;

  @BuiltValueField(wireName: r'revision')
  num get revision;

  @BuiltValueField(wireName: r'confirmedAt')
  DateTime get confirmedAt;

  MobileReleaseSnapshotDto._();

  factory MobileReleaseSnapshotDto([void updates(MobileReleaseSnapshotDtoBuilder b)]) = _$MobileReleaseSnapshotDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MobileReleaseSnapshotDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MobileReleaseSnapshotDto> get serializer => _$MobileReleaseSnapshotDtoSerializer();
}

class _$MobileReleaseSnapshotDtoSerializer implements PrimitiveSerializer<MobileReleaseSnapshotDto> {
  @override
  final Iterable<Type> types = const [MobileReleaseSnapshotDto, _$MobileReleaseSnapshotDto];

  @override
  final String wireName = r'MobileReleaseSnapshotDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MobileReleaseSnapshotDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'summary';
    yield serializers.serialize(
      object.summary,
      specifiedType: const FullType(String),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(num),
    );
    yield r'confirmedAt';
    yield serializers.serialize(
      object.confirmedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MobileReleaseSnapshotDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MobileReleaseSnapshotDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.summary = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.items.replace(valueDes);
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.revision = valueDes;
          break;
        case r'confirmedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.confirmedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MobileReleaseSnapshotDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MobileReleaseSnapshotDtoBuilder();
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
