//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_capabilities_response_dto.g.dart';

/// ThreadCapabilitiesResponseDto
///
/// Properties:
/// * [canManageThread]
/// * [canManageMembers]
/// * [isOwner]
@BuiltValue()
abstract class ThreadCapabilitiesResponseDto implements Built<ThreadCapabilitiesResponseDto, ThreadCapabilitiesResponseDtoBuilder> {
  @BuiltValueField(wireName: r'canManageThread')
  bool get canManageThread;

  @BuiltValueField(wireName: r'canManageMembers')
  bool get canManageMembers;

  @BuiltValueField(wireName: r'isOwner')
  bool get isOwner;

  ThreadCapabilitiesResponseDto._();

  factory ThreadCapabilitiesResponseDto([void updates(ThreadCapabilitiesResponseDtoBuilder b)]) = _$ThreadCapabilitiesResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadCapabilitiesResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadCapabilitiesResponseDto> get serializer => _$ThreadCapabilitiesResponseDtoSerializer();
}

class _$ThreadCapabilitiesResponseDtoSerializer implements PrimitiveSerializer<ThreadCapabilitiesResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadCapabilitiesResponseDto, _$ThreadCapabilitiesResponseDto];

  @override
  final String wireName = r'ThreadCapabilitiesResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadCapabilitiesResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'canManageThread';
    yield serializers.serialize(
      object.canManageThread,
      specifiedType: const FullType(bool),
    );
    yield r'canManageMembers';
    yield serializers.serialize(
      object.canManageMembers,
      specifiedType: const FullType(bool),
    );
    yield r'isOwner';
    yield serializers.serialize(
      object.isOwner,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadCapabilitiesResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadCapabilitiesResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'canManageThread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canManageThread = valueDes;
          break;
        case r'canManageMembers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canManageMembers = valueDes;
          break;
        case r'isOwner':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isOwner = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadCapabilitiesResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadCapabilitiesResponseDtoBuilder();
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
