//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'appeal_access_token_response_dto.g.dart';

/// AppealAccessTokenResponseDto
///
/// Properties:
/// * [appealToken] - 仅可用于用户申诉接口的短期 Bearer JWT
/// * [expiresAt]
@BuiltValue()
abstract class AppealAccessTokenResponseDto implements Built<AppealAccessTokenResponseDto, AppealAccessTokenResponseDtoBuilder> {
  /// 仅可用于用户申诉接口的短期 Bearer JWT
  @BuiltValueField(wireName: r'appealToken')
  String get appealToken;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  AppealAccessTokenResponseDto._();

  factory AppealAccessTokenResponseDto([void updates(AppealAccessTokenResponseDtoBuilder b)]) = _$AppealAccessTokenResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppealAccessTokenResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppealAccessTokenResponseDto> get serializer => _$AppealAccessTokenResponseDtoSerializer();
}

class _$AppealAccessTokenResponseDtoSerializer implements PrimitiveSerializer<AppealAccessTokenResponseDto> {
  @override
  final Iterable<Type> types = const [AppealAccessTokenResponseDto, _$AppealAccessTokenResponseDto];

  @override
  final String wireName = r'AppealAccessTokenResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppealAccessTokenResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'appealToken';
    yield serializers.serialize(
      object.appealToken,
      specifiedType: const FullType(String),
    );
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AppealAccessTokenResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AppealAccessTokenResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'appealToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.appealToken = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AppealAccessTokenResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppealAccessTokenResponseDtoBuilder();
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
