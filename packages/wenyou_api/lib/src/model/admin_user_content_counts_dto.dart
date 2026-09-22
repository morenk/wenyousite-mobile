//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_user_content_counts_dto.g.dart';

/// AdminUserContentCountsDto
///
/// Properties:
/// * [thread]
/// * [post]
/// * [moment]
/// * [momentComment]
@BuiltValue()
abstract class AdminUserContentCountsDto implements Built<AdminUserContentCountsDto, AdminUserContentCountsDtoBuilder> {
  @BuiltValueField(wireName: r'thread')
  num get thread;

  @BuiltValueField(wireName: r'post')
  num get post;

  @BuiltValueField(wireName: r'moment')
  num get moment;

  @BuiltValueField(wireName: r'moment_comment')
  num get momentComment;

  AdminUserContentCountsDto._();

  factory AdminUserContentCountsDto([void updates(AdminUserContentCountsDtoBuilder b)]) = _$AdminUserContentCountsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUserContentCountsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUserContentCountsDto> get serializer => _$AdminUserContentCountsDtoSerializer();
}

class _$AdminUserContentCountsDtoSerializer implements PrimitiveSerializer<AdminUserContentCountsDto> {
  @override
  final Iterable<Type> types = const [AdminUserContentCountsDto, _$AdminUserContentCountsDto];

  @override
  final String wireName = r'AdminUserContentCountsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUserContentCountsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'thread';
    yield serializers.serialize(
      object.thread,
      specifiedType: const FullType(num),
    );
    yield r'post';
    yield serializers.serialize(
      object.post,
      specifiedType: const FullType(num),
    );
    yield r'moment';
    yield serializers.serialize(
      object.moment,
      specifiedType: const FullType(num),
    );
    yield r'moment_comment';
    yield serializers.serialize(
      object.momentComment,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUserContentCountsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUserContentCountsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'thread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.thread = valueDes;
          break;
        case r'post':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.post = valueDes;
          break;
        case r'moment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.moment = valueDes;
          break;
        case r'moment_comment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.momentComment = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUserContentCountsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUserContentCountsDtoBuilder();
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
