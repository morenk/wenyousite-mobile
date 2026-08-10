//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/bookmark_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bookmarks_move200_response.g.dart';

/// BookmarksMove200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class BookmarksMove200Response implements ApiSuccessEnvelope, Built<BookmarksMove200Response, BookmarksMove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BookmarkResponseDto get data;

  BookmarksMove200Response._();

  factory BookmarksMove200Response([void updates(BookmarksMove200ResponseBuilder b)]) = _$BookmarksMove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BookmarksMove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BookmarksMove200Response> get serializer => _$BookmarksMove200ResponseSerializer();
}

class _$BookmarksMove200ResponseSerializer implements PrimitiveSerializer<BookmarksMove200Response> {
  @override
  final Iterable<Type> types = const [BookmarksMove200Response, _$BookmarksMove200Response];

  @override
  final String wireName = r'BookmarksMove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BookmarksMove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BookmarkResponseDto),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BookmarksMove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BookmarksMove200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BookmarkResponseDto),
          ) as BookmarkResponseDto;
          result.data.replace(valueDes);
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
          ) as ApiSuccessEnvelopeCodeEnum;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BookmarksMove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BookmarksMove200ResponseBuilder();
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

class BookmarksMove200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const BookmarksMove200ResponseCodeEnum number0 = _$bookmarksMove200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const BookmarksMove200ResponseCodeEnum unknownDefaultOpenApi = _$bookmarksMove200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<BookmarksMove200ResponseCodeEnum> get serializer => _$bookmarksMove200ResponseCodeEnumSerializer;

  const BookmarksMove200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<BookmarksMove200ResponseCodeEnum> get values => _$bookmarksMove200ResponseCodeEnumValues;
  static BookmarksMove200ResponseCodeEnum valueOf(String name) => _$bookmarksMove200ResponseCodeEnumValueOf(name);
}
