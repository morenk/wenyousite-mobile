//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bookmarks_remove200_response.g.dart';

/// BookmarksRemove200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class BookmarksRemove200Response implements ApiSuccessEnvelope, Built<BookmarksRemove200Response, BookmarksRemove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  BookmarksRemove200Response._();

  factory BookmarksRemove200Response([void updates(BookmarksRemove200ResponseBuilder b)]) = _$BookmarksRemove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BookmarksRemove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BookmarksRemove200Response> get serializer => _$BookmarksRemove200ResponseSerializer();
}

class _$BookmarksRemove200ResponseSerializer implements PrimitiveSerializer<BookmarksRemove200Response> {
  @override
  final Iterable<Type> types = const [BookmarksRemove200Response, _$BookmarksRemove200Response];

  @override
  final String wireName = r'BookmarksRemove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BookmarksRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MessageResponseDto),
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
    BookmarksRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BookmarksRemove200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageResponseDto),
          ) as MessageResponseDto;
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
  BookmarksRemove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BookmarksRemove200ResponseBuilder();
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

class BookmarksRemove200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const BookmarksRemove200ResponseCodeEnum number0 = _$bookmarksRemove200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const BookmarksRemove200ResponseCodeEnum unknownDefaultOpenApi = _$bookmarksRemove200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<BookmarksRemove200ResponseCodeEnum> get serializer => _$bookmarksRemove200ResponseCodeEnumSerializer;

  const BookmarksRemove200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<BookmarksRemove200ResponseCodeEnum> get values => _$bookmarksRemove200ResponseCodeEnumValues;
  static BookmarksRemove200ResponseCodeEnum valueOf(String name) => _$bookmarksRemove200ResponseCodeEnumValueOf(name);
}
