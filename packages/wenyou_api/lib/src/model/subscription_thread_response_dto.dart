//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_category_info_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subscription_thread_response_dto.g.dart';

/// SubscriptionThreadResponseDto
///
/// Properties:
/// * [id]
/// * [title]
/// * [category] - 动态分类 slug
/// * [categoryInfo]
@BuiltValue()
abstract class SubscriptionThreadResponseDto implements Built<SubscriptionThreadResponseDto, SubscriptionThreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  /// 动态分类 slug
  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'categoryInfo')
  ThreadCategoryInfoDto? get categoryInfo;

  SubscriptionThreadResponseDto._();

  factory SubscriptionThreadResponseDto([void updates(SubscriptionThreadResponseDtoBuilder b)]) = _$SubscriptionThreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubscriptionThreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubscriptionThreadResponseDto> get serializer => _$SubscriptionThreadResponseDtoSerializer();
}

class _$SubscriptionThreadResponseDtoSerializer implements PrimitiveSerializer<SubscriptionThreadResponseDto> {
  @override
  final Iterable<Type> types = const [SubscriptionThreadResponseDto, _$SubscriptionThreadResponseDto];

  @override
  final String wireName = r'SubscriptionThreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubscriptionThreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'category';
    yield object.category == null ? null : serializers.serialize(
      object.category,
      specifiedType: const FullType.nullable(String),
    );
    yield r'categoryInfo';
    yield object.categoryInfo == null ? null : serializers.serialize(
      object.categoryInfo,
      specifiedType: const FullType.nullable(ThreadCategoryInfoDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SubscriptionThreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubscriptionThreadResponseDtoBuilder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.category = valueDes;
          break;
        case r'categoryInfo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ThreadCategoryInfoDto),
          ) as ThreadCategoryInfoDto?;
          if (valueDes == null) continue;
          result.categoryInfo.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SubscriptionThreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubscriptionThreadResponseDtoBuilder();
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
