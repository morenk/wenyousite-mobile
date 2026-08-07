//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/user_sticker_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sticker_import_response_dto.g.dart';

/// StickerImportResponseDto
///
/// Properties:
/// * [id]
/// * [status]
/// * [favorite]
/// * [failureCode]
/// * [failureMessage]
/// * [alreadySaved]
@BuiltValue()
abstract class StickerImportResponseDto implements Built<StickerImportResponseDto, StickerImportResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  StickerImportResponseDtoStatusEnum get status;
  // enum statusEnum {  PROCESSING,  COMPLETED,  FAILED,  };

  @BuiltValueField(wireName: r'favorite')
  UserStickerResponseDto? get favorite;

  @BuiltValueField(wireName: r'failureCode')
  String? get failureCode;

  @BuiltValueField(wireName: r'failureMessage')
  String? get failureMessage;

  @BuiltValueField(wireName: r'alreadySaved')
  bool get alreadySaved;

  StickerImportResponseDto._();

  factory StickerImportResponseDto([void updates(StickerImportResponseDtoBuilder b)]) = _$StickerImportResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickerImportResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickerImportResponseDto> get serializer => _$StickerImportResponseDtoSerializer();
}

class _$StickerImportResponseDtoSerializer implements PrimitiveSerializer<StickerImportResponseDto> {
  @override
  final Iterable<Type> types = const [StickerImportResponseDto, _$StickerImportResponseDto];

  @override
  final String wireName = r'StickerImportResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickerImportResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(StickerImportResponseDtoStatusEnum),
    );
    if (object.favorite != null) {
      yield r'favorite';
      yield serializers.serialize(
        object.favorite,
        specifiedType: const FullType.nullable(UserStickerResponseDto),
      );
    }
    if (object.failureCode != null) {
      yield r'failureCode';
      yield serializers.serialize(
        object.failureCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.failureMessage != null) {
      yield r'failureMessage';
      yield serializers.serialize(
        object.failureMessage,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'alreadySaved';
    yield serializers.serialize(
      object.alreadySaved,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StickerImportResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickerImportResponseDtoBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StickerImportResponseDtoStatusEnum),
          ) as StickerImportResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'favorite':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(UserStickerResponseDto),
          ) as UserStickerResponseDto?;
          if (valueDes == null) continue;
          result.favorite.replace(valueDes);
          break;
        case r'failureCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.failureCode = valueDes;
          break;
        case r'failureMessage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.failureMessage = valueDes;
          break;
        case r'alreadySaved':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.alreadySaved = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StickerImportResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickerImportResponseDtoBuilder();
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

class StickerImportResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PROCESSING')
  static const StickerImportResponseDtoStatusEnum PROCESSING = _$stickerImportResponseDtoStatusEnum_PROCESSING;
  @BuiltValueEnumConst(wireName: r'COMPLETED')
  static const StickerImportResponseDtoStatusEnum COMPLETED = _$stickerImportResponseDtoStatusEnum_COMPLETED;
  @BuiltValueEnumConst(wireName: r'FAILED')
  static const StickerImportResponseDtoStatusEnum FAILED = _$stickerImportResponseDtoStatusEnum_FAILED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const StickerImportResponseDtoStatusEnum unknownDefaultOpenApi = _$stickerImportResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<StickerImportResponseDtoStatusEnum> get serializer => _$stickerImportResponseDtoStatusEnumSerializer;

  const StickerImportResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<StickerImportResponseDtoStatusEnum> get values => _$stickerImportResponseDtoStatusEnumValues;
  static StickerImportResponseDtoStatusEnum valueOf(String name) => _$stickerImportResponseDtoStatusEnumValueOf(name);
}
