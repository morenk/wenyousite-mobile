//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_registration_snapshot_dto.g.dart';

/// FontRegistrationSnapshotDto
///
/// Properties:
/// * [assetCount] - 按 mobile 资产 SHA 去重的全集数量
/// * [totalAssetBytes] - 去重 SFNT 文件字节之和，不是 native 内存上限
/// * [registrationCount] - 按资产 SHA＋family 去重的注册全集数量
/// * [totalRegistrationAssetBytes] - 按注册键汇总输入字节，防止同资产多别名绕过账本
@BuiltValue()
abstract class FontRegistrationSnapshotDto implements Built<FontRegistrationSnapshotDto, FontRegistrationSnapshotDtoBuilder> {
  /// 按 mobile 资产 SHA 去重的全集数量
  @BuiltValueField(wireName: r'assetCount')
  int get assetCount;

  /// 去重 SFNT 文件字节之和，不是 native 内存上限
  @BuiltValueField(wireName: r'totalAssetBytes')
  int get totalAssetBytes;

  /// 按资产 SHA＋family 去重的注册全集数量
  @BuiltValueField(wireName: r'registrationCount')
  int get registrationCount;

  /// 按注册键汇总输入字节，防止同资产多别名绕过账本
  @BuiltValueField(wireName: r'totalRegistrationAssetBytes')
  int get totalRegistrationAssetBytes;

  FontRegistrationSnapshotDto._();

  factory FontRegistrationSnapshotDto([void updates(FontRegistrationSnapshotDtoBuilder b)]) = _$FontRegistrationSnapshotDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontRegistrationSnapshotDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontRegistrationSnapshotDto> get serializer => _$FontRegistrationSnapshotDtoSerializer();
}

class _$FontRegistrationSnapshotDtoSerializer implements PrimitiveSerializer<FontRegistrationSnapshotDto> {
  @override
  final Iterable<Type> types = const [FontRegistrationSnapshotDto, _$FontRegistrationSnapshotDto];

  @override
  final String wireName = r'FontRegistrationSnapshotDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontRegistrationSnapshotDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'assetCount';
    yield serializers.serialize(
      object.assetCount,
      specifiedType: const FullType(int),
    );
    yield r'totalAssetBytes';
    yield serializers.serialize(
      object.totalAssetBytes,
      specifiedType: const FullType(int),
    );
    yield r'registrationCount';
    yield serializers.serialize(
      object.registrationCount,
      specifiedType: const FullType(int),
    );
    yield r'totalRegistrationAssetBytes';
    yield serializers.serialize(
      object.totalRegistrationAssetBytes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontRegistrationSnapshotDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontRegistrationSnapshotDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'assetCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.assetCount = valueDes;
          break;
        case r'totalAssetBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalAssetBytes = valueDes;
          break;
        case r'registrationCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.registrationCount = valueDes;
          break;
        case r'totalRegistrationAssetBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalRegistrationAssetBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontRegistrationSnapshotDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontRegistrationSnapshotDtoBuilder();
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
