//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_snapshot_safety_ceiling_dto.g.dart';

/// FontSnapshotSafetyCeilingDto
///
/// Properties:
/// * [maxSnapshotAssets] - 消费者本地固定接受边界，不能直接服从远端扩大
/// * [maxSnapshotAssetBytes] - 消费者本地固定注册输入边界，不代表设备内存安全
@BuiltValue()
abstract class FontSnapshotSafetyCeilingDto implements Built<FontSnapshotSafetyCeilingDto, FontSnapshotSafetyCeilingDtoBuilder> {
  /// 消费者本地固定接受边界，不能直接服从远端扩大
  @BuiltValueField(wireName: r'maxSnapshotAssets')
  FontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum get maxSnapshotAssets;
  // enum maxSnapshotAssetsEnum {  1024,  };

  /// 消费者本地固定注册输入边界，不代表设备内存安全
  @BuiltValueField(wireName: r'maxSnapshotAssetBytes')
  FontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum get maxSnapshotAssetBytes;
  // enum maxSnapshotAssetBytesEnum {  268435456,  };

  FontSnapshotSafetyCeilingDto._();

  factory FontSnapshotSafetyCeilingDto([void updates(FontSnapshotSafetyCeilingDtoBuilder b)]) = _$FontSnapshotSafetyCeilingDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontSnapshotSafetyCeilingDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontSnapshotSafetyCeilingDto> get serializer => _$FontSnapshotSafetyCeilingDtoSerializer();
}

class _$FontSnapshotSafetyCeilingDtoSerializer implements PrimitiveSerializer<FontSnapshotSafetyCeilingDto> {
  @override
  final Iterable<Type> types = const [FontSnapshotSafetyCeilingDto, _$FontSnapshotSafetyCeilingDto];

  @override
  final String wireName = r'FontSnapshotSafetyCeilingDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontSnapshotSafetyCeilingDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'maxSnapshotAssets';
    yield serializers.serialize(
      object.maxSnapshotAssets,
      specifiedType: const FullType(FontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum),
    );
    yield r'maxSnapshotAssetBytes';
    yield serializers.serialize(
      object.maxSnapshotAssetBytes,
      specifiedType: const FullType(FontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontSnapshotSafetyCeilingDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontSnapshotSafetyCeilingDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'maxSnapshotAssets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum),
          ) as FontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum;
          result.maxSnapshotAssets = valueDes;
          break;
        case r'maxSnapshotAssetBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum),
          ) as FontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum;
          result.maxSnapshotAssetBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontSnapshotSafetyCeilingDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontSnapshotSafetyCeilingDtoBuilder();
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

class FontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum extends EnumClass {

  /// 消费者本地固定接受边界，不能直接服从远端扩大
  @BuiltValueEnumConst(wireName: r'1024')
  static const FontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum n1024 = _$fontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum_n1024;
  /// 消费者本地固定接受边界，不能直接服从远端扩大
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum unknownDefaultOpenApi = _$fontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum_unknownDefaultOpenApi;

  static Serializer<FontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum> get serializer => _$fontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnumSerializer;

  const FontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum._(String name): super(name);

  static BuiltSet<FontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum> get values => _$fontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnumValues;
  static FontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnum valueOf(String name) => _$fontSnapshotSafetyCeilingDtoMaxSnapshotAssetsEnumValueOf(name);
}

class FontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum extends EnumClass {

  /// 消费者本地固定注册输入边界，不代表设备内存安全
  @BuiltValueEnumConst(wireName: r'268435456')
  static const FontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum n268435456 = _$fontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum_n268435456;
  /// 消费者本地固定注册输入边界，不代表设备内存安全
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum unknownDefaultOpenApi = _$fontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum_unknownDefaultOpenApi;

  static Serializer<FontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum> get serializer => _$fontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnumSerializer;

  const FontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum._(String name): super(name);

  static BuiltSet<FontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum> get values => _$fontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnumValues;
  static FontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnum valueOf(String name) => _$fontSnapshotSafetyCeilingDtoMaxSnapshotAssetBytesEnumValueOf(name);
}
