//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'health_check200_response_all_of_data.g.dart';

/// HealthCheck200ResponseAllOfData
///
/// Properties:
/// * [status]
/// * [info]
/// * [error]
/// * [details]
@BuiltValue()
abstract class HealthCheck200ResponseAllOfData implements Built<HealthCheck200ResponseAllOfData, HealthCheck200ResponseAllOfDataBuilder> {
  @BuiltValueField(wireName: r'status')
  String? get status;

  @BuiltValueField(wireName: r'info')
  BuiltMap<String, BuiltMap<String, JsonObject?>>? get info;

  @BuiltValueField(wireName: r'error')
  BuiltMap<String, BuiltMap<String, JsonObject?>>? get error;

  @BuiltValueField(wireName: r'details')
  BuiltMap<String, BuiltMap<String, JsonObject?>>? get details;

  HealthCheck200ResponseAllOfData._();

  factory HealthCheck200ResponseAllOfData([void updates(HealthCheck200ResponseAllOfDataBuilder b)]) = _$HealthCheck200ResponseAllOfData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HealthCheck200ResponseAllOfDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HealthCheck200ResponseAllOfData> get serializer => _$HealthCheck200ResponseAllOfDataSerializer();
}

class _$HealthCheck200ResponseAllOfDataSerializer implements PrimitiveSerializer<HealthCheck200ResponseAllOfData> {
  @override
  final Iterable<Type> types = const [HealthCheck200ResponseAllOfData, _$HealthCheck200ResponseAllOfData];

  @override
  final String wireName = r'HealthCheck200ResponseAllOfData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HealthCheck200ResponseAllOfData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      );
    }
    if (object.info != null) {
      yield r'info';
      yield serializers.serialize(
        object.info,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
      );
    }
    if (object.error != null) {
      yield r'error';
      yield serializers.serialize(
        object.error,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
      );
    }
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    HealthCheck200ResponseAllOfData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HealthCheck200ResponseAllOfDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'info':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
          ) as BuiltMap<String, BuiltMap<String, JsonObject?>>?;
          if (valueDes == null) continue;
          result.info.replace(valueDes);
          break;
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
          ) as BuiltMap<String, BuiltMap<String, JsonObject?>>?;
          if (valueDes == null) continue;
          result.error.replace(valueDes);
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
          ) as BuiltMap<String, BuiltMap<String, JsonObject?>>;
          result.details.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HealthCheck200ResponseAllOfData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HealthCheck200ResponseAllOfDataBuilder();
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
