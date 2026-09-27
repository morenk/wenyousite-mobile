//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/media_display_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_content_media_dto.g.dart';

/// AdminContentMediaDto
///
/// Properties:
/// * [id]
/// * [url]
/// * [display]
@BuiltValue()
abstract class AdminContentMediaDto implements Built<AdminContentMediaDto, AdminContentMediaDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'display')
  MediaDisplayResponseDto? get display;

  AdminContentMediaDto._();

  factory AdminContentMediaDto([void updates(AdminContentMediaDtoBuilder b)]) = _$AdminContentMediaDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminContentMediaDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminContentMediaDto> get serializer => _$AdminContentMediaDtoSerializer();
}

class _$AdminContentMediaDtoSerializer implements PrimitiveSerializer<AdminContentMediaDto> {
  @override
  final Iterable<Type> types = const [AdminContentMediaDto, _$AdminContentMediaDto];

  @override
  final String wireName = r'AdminContentMediaDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminContentMediaDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'display';
    yield object.display == null ? null : serializers.serialize(
      object.display,
      specifiedType: const FullType.nullable(MediaDisplayResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminContentMediaDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminContentMediaDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'display':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MediaDisplayResponseDto),
          ) as MediaDisplayResponseDto?;
          if (valueDes == null) continue;
          result.display.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminContentMediaDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminContentMediaDtoBuilder();
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
