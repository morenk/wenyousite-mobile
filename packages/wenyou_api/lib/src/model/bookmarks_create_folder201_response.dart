//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/bookmark_folder_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bookmarks_create_folder201_response.g.dart';

/// BookmarksCreateFolder201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class BookmarksCreateFolder201Response implements ApiSuccessEnvelope, Built<BookmarksCreateFolder201Response, BookmarksCreateFolder201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BookmarkFolderResponseDto get data;

  BookmarksCreateFolder201Response._();

  factory BookmarksCreateFolder201Response([void updates(BookmarksCreateFolder201ResponseBuilder b)]) = _$BookmarksCreateFolder201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BookmarksCreateFolder201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BookmarksCreateFolder201Response> get serializer => _$BookmarksCreateFolder201ResponseSerializer();
}

class _$BookmarksCreateFolder201ResponseSerializer implements PrimitiveSerializer<BookmarksCreateFolder201Response> {
  @override
  final Iterable<Type> types = const [BookmarksCreateFolder201Response, _$BookmarksCreateFolder201Response];

  @override
  final String wireName = r'BookmarksCreateFolder201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BookmarksCreateFolder201Response object, {
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
    BookmarksCreateFolder201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BookmarksCreateFolder201ResponseBuilder result,
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
  BookmarksCreateFolder201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BookmarksCreateFolder201ResponseBuilder();
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

class BookmarksCreateFolder201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const BookmarksCreateFolder201ResponseCodeEnum number0 = _$bookmarksCreateFolder201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const BookmarksCreateFolder201ResponseCodeEnum unknownDefaultOpenApi = _$bookmarksCreateFolder201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<BookmarksCreateFolder201ResponseCodeEnum> get serializer => _$bookmarksCreateFolder201ResponseCodeEnumSerializer;

  const BookmarksCreateFolder201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<BookmarksCreateFolder201ResponseCodeEnum> get values => _$bookmarksCreateFolder201ResponseCodeEnumValues;
  static BookmarksCreateFolder201ResponseCodeEnum valueOf(String name) => _$bookmarksCreateFolder201ResponseCodeEnumValueOf(name);
}
