//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/delete_bookmark_folder_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bookmarks_delete_folder200_response.g.dart';

/// BookmarksDeleteFolder200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class BookmarksDeleteFolder200Response implements ApiSuccessEnvelope, Built<BookmarksDeleteFolder200Response, BookmarksDeleteFolder200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DeleteBookmarkFolderResponseDto get data;

  BookmarksDeleteFolder200Response._();

  factory BookmarksDeleteFolder200Response([void updates(BookmarksDeleteFolder200ResponseBuilder b)]) = _$BookmarksDeleteFolder200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BookmarksDeleteFolder200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BookmarksDeleteFolder200Response> get serializer => _$BookmarksDeleteFolder200ResponseSerializer();
}

class _$BookmarksDeleteFolder200ResponseSerializer implements PrimitiveSerializer<BookmarksDeleteFolder200Response> {
  @override
  final Iterable<Type> types = const [BookmarksDeleteFolder200Response, _$BookmarksDeleteFolder200Response];

  @override
  final String wireName = r'BookmarksDeleteFolder200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BookmarksDeleteFolder200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DeleteBookmarkFolderResponseDto),
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
    BookmarksDeleteFolder200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BookmarksDeleteFolder200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeleteBookmarkFolderResponseDto),
          ) as DeleteBookmarkFolderResponseDto;
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
  BookmarksDeleteFolder200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BookmarksDeleteFolder200ResponseBuilder();
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

class BookmarksDeleteFolder200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const BookmarksDeleteFolder200ResponseCodeEnum number0 = _$bookmarksDeleteFolder200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const BookmarksDeleteFolder200ResponseCodeEnum unknownDefaultOpenApi = _$bookmarksDeleteFolder200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<BookmarksDeleteFolder200ResponseCodeEnum> get serializer => _$bookmarksDeleteFolder200ResponseCodeEnumSerializer;

  const BookmarksDeleteFolder200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<BookmarksDeleteFolder200ResponseCodeEnum> get values => _$bookmarksDeleteFolder200ResponseCodeEnumValues;
  static BookmarksDeleteFolder200ResponseCodeEnum valueOf(String name) => _$bookmarksDeleteFolder200ResponseCodeEnumValueOf(name);
}
