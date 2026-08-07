//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/bookmark_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bookmarks_create201_response.g.dart';

/// BookmarksCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class BookmarksCreate201Response implements ApiSuccessEnvelope, Built<BookmarksCreate201Response, BookmarksCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BookmarkResponseDto get data;

  BookmarksCreate201Response._();

  factory BookmarksCreate201Response([void updates(BookmarksCreate201ResponseBuilder b)]) = _$BookmarksCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BookmarksCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BookmarksCreate201Response> get serializer => _$BookmarksCreate201ResponseSerializer();
}

class _$BookmarksCreate201ResponseSerializer implements PrimitiveSerializer<BookmarksCreate201Response> {
  @override
  final Iterable<Type> types = const [BookmarksCreate201Response, _$BookmarksCreate201Response];

  @override
  final String wireName = r'BookmarksCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BookmarksCreate201Response object, {
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
    BookmarksCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BookmarksCreate201ResponseBuilder result,
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
  BookmarksCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BookmarksCreate201ResponseBuilder();
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

class BookmarksCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const BookmarksCreate201ResponseCodeEnum number0 = _$bookmarksCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const BookmarksCreate201ResponseCodeEnum unknownDefaultOpenApi = _$bookmarksCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<BookmarksCreate201ResponseCodeEnum> get serializer => _$bookmarksCreate201ResponseCodeEnumSerializer;

  const BookmarksCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<BookmarksCreate201ResponseCodeEnum> get values => _$bookmarksCreate201ResponseCodeEnumValues;
  static BookmarksCreate201ResponseCodeEnum valueOf(String name) => _$bookmarksCreate201ResponseCodeEnumValueOf(name);
}
