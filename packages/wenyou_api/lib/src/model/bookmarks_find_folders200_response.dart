//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/bookmark_folder_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bookmarks_find_folders200_response.g.dart';

/// BookmarksFindFolders200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class BookmarksFindFolders200Response implements ApiSuccessEnvelope, Built<BookmarksFindFolders200Response, BookmarksFindFolders200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<BookmarkFolderResponseDto> get data;

  BookmarksFindFolders200Response._();

  factory BookmarksFindFolders200Response([void updates(BookmarksFindFolders200ResponseBuilder b)]) = _$BookmarksFindFolders200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BookmarksFindFolders200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BookmarksFindFolders200Response> get serializer => _$BookmarksFindFolders200ResponseSerializer();
}

class _$BookmarksFindFolders200ResponseSerializer implements PrimitiveSerializer<BookmarksFindFolders200Response> {
  @override
  final Iterable<Type> types = const [BookmarksFindFolders200Response, _$BookmarksFindFolders200Response];

  @override
  final String wireName = r'BookmarksFindFolders200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BookmarksFindFolders200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(BookmarkFolderResponseDto)]),
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
    BookmarksFindFolders200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BookmarksFindFolders200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BookmarkFolderResponseDto)]),
          ) as BuiltList<BookmarkFolderResponseDto>;
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
  BookmarksFindFolders200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BookmarksFindFolders200ResponseBuilder();
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

class BookmarksFindFolders200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const BookmarksFindFolders200ResponseCodeEnum number0 = _$bookmarksFindFolders200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const BookmarksFindFolders200ResponseCodeEnum unknownDefaultOpenApi = _$bookmarksFindFolders200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<BookmarksFindFolders200ResponseCodeEnum> get serializer => _$bookmarksFindFolders200ResponseCodeEnumSerializer;

  const BookmarksFindFolders200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<BookmarksFindFolders200ResponseCodeEnum> get values => _$bookmarksFindFolders200ResponseCodeEnumValues;
  static BookmarksFindFolders200ResponseCodeEnum valueOf(String name) => _$bookmarksFindFolders200ResponseCodeEnumValueOf(name);
}
