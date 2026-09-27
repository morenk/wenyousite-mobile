//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/bookmark_folder_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bookmarks_rename_folder200_response.g.dart';

/// BookmarksRenameFolder200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class BookmarksRenameFolder200Response implements ApiSuccessEnvelope, Built<BookmarksRenameFolder200Response, BookmarksRenameFolder200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BookmarkFolderResponseDto get data;

  BookmarksRenameFolder200Response._();

  factory BookmarksRenameFolder200Response([void updates(BookmarksRenameFolder200ResponseBuilder b)]) = _$BookmarksRenameFolder200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BookmarksRenameFolder200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BookmarksRenameFolder200Response> get serializer => _$BookmarksRenameFolder200ResponseSerializer();
}

class _$BookmarksRenameFolder200ResponseSerializer implements PrimitiveSerializer<BookmarksRenameFolder200Response> {
  @override
  final Iterable<Type> types = const [BookmarksRenameFolder200Response, _$BookmarksRenameFolder200Response];

  @override
  final String wireName = r'BookmarksRenameFolder200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BookmarksRenameFolder200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BookmarkFolderResponseDto),
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
    BookmarksRenameFolder200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BookmarksRenameFolder200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BookmarkFolderResponseDto),
          ) as BookmarkFolderResponseDto;
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
  BookmarksRenameFolder200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BookmarksRenameFolder200ResponseBuilder();
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

class BookmarksRenameFolder200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const BookmarksRenameFolder200ResponseCodeEnum number0 = _$bookmarksRenameFolder200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const BookmarksRenameFolder200ResponseCodeEnum unknownDefaultOpenApi = _$bookmarksRenameFolder200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<BookmarksRenameFolder200ResponseCodeEnum> get serializer => _$bookmarksRenameFolder200ResponseCodeEnumSerializer;

  const BookmarksRenameFolder200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<BookmarksRenameFolder200ResponseCodeEnum> get values => _$bookmarksRenameFolder200ResponseCodeEnumValues;
  static BookmarksRenameFolder200ResponseCodeEnum valueOf(String name) => _$bookmarksRenameFolder200ResponseCodeEnumValueOf(name);
}
