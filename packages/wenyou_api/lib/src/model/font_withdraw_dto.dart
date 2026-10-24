//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_withdraw_dto.g.dart';

/// FontWithdrawDto
///
/// Properties:
/// * [expectedCatalogRevision]
/// * [reason]
@BuiltValue()
abstract class FontWithdrawDto implements Built<FontWithdrawDto, FontWithdrawDtoBuilder> {
  @BuiltValueField(wireName: r'expectedCatalogRevision')
  int get expectedCatalogRevision;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  FontWithdrawDto._();

  factory FontWithdrawDto([void updates(FontWithdrawDtoBuilder b)]) = _$FontWithdrawDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontWithdrawDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontWithdrawDto> get serializer => _$FontWithdrawDtoSerializer();
}

class _$FontWithdrawDtoSerializer implements PrimitiveSerializer<FontWithdrawDto> {
  @override
  final Iterable<Type> types = const [FontWithdrawDto, _$FontWithdrawDto];

  @override
  final String wireName = r'FontWithdrawDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontWithdrawDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expectedCatalogRevision';
    yield serializers.serialize(
      object.expectedCatalogRevision,
      specifiedType: const FullType(int),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontWithdrawDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontWithdrawDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expectedCatalogRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedCatalogRevision = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontWithdrawDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontWithdrawDtoBuilder();
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
