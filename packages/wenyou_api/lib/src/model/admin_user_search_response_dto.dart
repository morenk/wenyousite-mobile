//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_user_search_item_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_user_search_response_dto.g.dart';

/// AdminUserSearchResponseDto
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class AdminUserSearchResponseDto implements Built<AdminUserSearchResponseDto, AdminUserSearchResponseDtoBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<AdminUserSearchItemDto> get data;

  AdminUserSearchResponseDto._();

  factory AdminUserSearchResponseDto([void updates(AdminUserSearchResponseDtoBuilder b)]) = _$AdminUserSearchResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUserSearchResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUserSearchResponseDto> get serializer => _$AdminUserSearchResponseDtoSerializer();
}

class _$AdminUserSearchResponseDtoSerializer implements PrimitiveSerializer<AdminUserSearchResponseDto> {
  @override
  final Iterable<Type> types = const [AdminUserSearchResponseDto, _$AdminUserSearchResponseDto];

  @override
  final String wireName = r'AdminUserSearchResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUserSearchResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(AdminUserSearchItemDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUserSearchResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUserSearchResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminUserSearchItemDto)]),
          ) as BuiltList<AdminUserSearchItemDto>;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUserSearchResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUserSearchResponseDtoBuilder();
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
