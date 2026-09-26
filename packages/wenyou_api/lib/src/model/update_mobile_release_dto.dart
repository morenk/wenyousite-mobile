//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_mobile_release_dto.g.dart';

/// UpdateMobileReleaseDto
///
/// Properties:
/// * [summary] - 纯文本摘要；至少含一个非空白字符，不解析 Markdown/HTML
/// * [items] - 1–30 条纯文本，每条最多 500 字符且非空白；客户端按文本显示
/// * [versionName] - 仅从未确认的草稿允许修正版本名；平台/build 固定
/// * [revision]
@BuiltValue()
abstract class UpdateMobileReleaseDto implements Built<UpdateMobileReleaseDto, UpdateMobileReleaseDtoBuilder> {
  /// 纯文本摘要；至少含一个非空白字符，不解析 Markdown/HTML
  @BuiltValueField(wireName: r'summary')
  String get summary;

  /// 1–30 条纯文本，每条最多 500 字符且非空白；客户端按文本显示
  @BuiltValueField(wireName: r'items')
  BuiltList<String> get items;

  /// 仅从未确认的草稿允许修正版本名；平台/build 固定
  @BuiltValueField(wireName: r'versionName')
  String? get versionName;

  @BuiltValueField(wireName: r'revision')
  num get revision;

  UpdateMobileReleaseDto._();

  factory UpdateMobileReleaseDto([void updates(UpdateMobileReleaseDtoBuilder b)]) = _$UpdateMobileReleaseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateMobileReleaseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateMobileReleaseDto> get serializer => _$UpdateMobileReleaseDtoSerializer();
}

class _$UpdateMobileReleaseDtoSerializer implements PrimitiveSerializer<UpdateMobileReleaseDto> {
  @override
  final Iterable<Type> types = const [UpdateMobileReleaseDto, _$UpdateMobileReleaseDto];

  @override
  final String wireName = r'UpdateMobileReleaseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateMobileReleaseDto object, {
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
    if (object.versionName != null) {
      yield r'versionName';
      yield serializers.serialize(
        object.versionName,
        specifiedType: const FullType(String),
      );
    }
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateMobileReleaseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateMobileReleaseDtoBuilder result,
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
        case r'versionName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.versionName = valueDes;
          break;
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
  UpdateMobileReleaseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateMobileReleaseDtoBuilder();
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
