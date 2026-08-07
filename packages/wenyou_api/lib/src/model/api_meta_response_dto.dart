//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_capabilities_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'api_meta_response_dto.g.dart';

/// ApiMetaResponseDto
///
/// Properties:
/// * [contractVersion]
/// * [buildSha]
/// * [markdownContractVersion]
/// * [capabilities]
@BuiltValue()
abstract class ApiMetaResponseDto implements Built<ApiMetaResponseDto, ApiMetaResponseDtoBuilder> {
  @BuiltValueField(wireName: r'contractVersion')
  String get contractVersion;

  @BuiltValueField(wireName: r'buildSha')
  String? get buildSha;

  @BuiltValueField(wireName: r'markdownContractVersion')
  num get markdownContractVersion;

  @BuiltValueField(wireName: r'capabilities')
  ApiCapabilitiesResponseDto get capabilities;

  ApiMetaResponseDto._();

  factory ApiMetaResponseDto([void updates(ApiMetaResponseDtoBuilder b)]) = _$ApiMetaResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApiMetaResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApiMetaResponseDto> get serializer => _$ApiMetaResponseDtoSerializer();
}

class _$ApiMetaResponseDtoSerializer implements PrimitiveSerializer<ApiMetaResponseDto> {
  @override
  final Iterable<Type> types = const [ApiMetaResponseDto, _$ApiMetaResponseDto];

  @override
  final String wireName = r'ApiMetaResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApiMetaResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'contractVersion';
    yield serializers.serialize(
      object.contractVersion,
      specifiedType: const FullType(String),
    );
    yield r'buildSha';
    yield object.buildSha == null ? null : serializers.serialize(
      object.buildSha,
      specifiedType: const FullType.nullable(String),
    );
    yield r'markdownContractVersion';
    yield serializers.serialize(
      object.markdownContractVersion,
      specifiedType: const FullType(num),
    );
    yield r'capabilities';
    yield serializers.serialize(
      object.capabilities,
      specifiedType: const FullType(ApiCapabilitiesResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ApiMetaResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ApiMetaResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'contractVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contractVersion = valueDes;
          break;
        case r'buildSha':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.buildSha = valueDes;
          break;
        case r'markdownContractVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.markdownContractVersion = valueDes;
          break;
        case r'capabilities':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiCapabilitiesResponseDto),
          ) as ApiCapabilitiesResponseDto;
          result.capabilities.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ApiMetaResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApiMetaResponseDtoBuilder();
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
