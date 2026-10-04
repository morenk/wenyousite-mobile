//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upsert_body_dto.g.dart';

/// UpsertBodyDto
///
/// Properties:
/// * [identityToken] - GET 帖内身份返回的确认 token；新建正文或发言时使用。身份变化返回 409/40011，保留草稿并重新确认
/// * [identityMode] - 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
/// * [content] - 正文（Markdown）；骰子使用内联节点，发布时仍必须包含非骰子可见文字
/// * [version] - 乐观锁版本号。正文已存在时必填（传入过期版本返回 409）；首次创建时忽略
@BuiltValue()
abstract class UpsertBodyDto implements Built<UpsertBodyDto, UpsertBodyDtoBuilder> {
  /// GET 帖内身份返回的确认 token；新建正文或发言时使用。身份变化返回 409/40011，保留草稿并重新确认
  @BuiltValueField(wireName: r'identityToken')
  String? get identityToken;

  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueField(wireName: r'identityMode')
  UpsertBodyDtoIdentityModeEnum? get identityMode;
  // enum identityModeEnum {  ACCOUNT,  RP,  };

  /// 正文（Markdown）；骰子使用内联节点，发布时仍必须包含非骰子可见文字
  @BuiltValueField(wireName: r'content')
  String get content;

  /// 乐观锁版本号。正文已存在时必填（传入过期版本返回 409）；首次创建时忽略
  @BuiltValueField(wireName: r'version')
  num? get version;

  UpsertBodyDto._();

  factory UpsertBodyDto([void updates(UpsertBodyDtoBuilder b)]) = _$UpsertBodyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpsertBodyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpsertBodyDto> get serializer => _$UpsertBodyDtoSerializer();
}

class _$UpsertBodyDtoSerializer implements PrimitiveSerializer<UpsertBodyDto> {
  @override
  final Iterable<Type> types = const [UpsertBodyDto, _$UpsertBodyDto];

  @override
  final String wireName = r'UpsertBodyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpsertBodyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.identityToken != null) {
      yield r'identityToken';
      yield serializers.serialize(
        object.identityToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.identityMode != null) {
      yield r'identityMode';
      yield serializers.serialize(
        object.identityMode,
        specifiedType: const FullType(UpsertBodyDtoIdentityModeEnum),
      );
    }
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    if (object.version != null) {
      yield r'version';
      yield serializers.serialize(
        object.version,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpsertBodyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpsertBodyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'identityToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.identityToken = valueDes;
          break;
        case r'identityMode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpsertBodyDtoIdentityModeEnum),
          ) as UpsertBodyDtoIdentityModeEnum;
          result.identityMode = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpsertBodyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpsertBodyDtoBuilder();
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

class UpsertBodyDtoIdentityModeEnum extends EnumClass {

  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'ACCOUNT')
  static const UpsertBodyDtoIdentityModeEnum ACCOUNT = _$upsertBodyDtoIdentityModeEnum_ACCOUNT;
  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'RP')
  static const UpsertBodyDtoIdentityModeEnum RP = _$upsertBodyDtoIdentityModeEnum_RP;
  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const UpsertBodyDtoIdentityModeEnum unknownDefaultOpenApi = _$upsertBodyDtoIdentityModeEnum_unknownDefaultOpenApi;

  static Serializer<UpsertBodyDtoIdentityModeEnum> get serializer => _$upsertBodyDtoIdentityModeEnumSerializer;

  const UpsertBodyDtoIdentityModeEnum._(String name): super(name);

  static BuiltSet<UpsertBodyDtoIdentityModeEnum> get values => _$upsertBodyDtoIdentityModeEnumValues;
  static UpsertBodyDtoIdentityModeEnum valueOf(String name) => _$upsertBodyDtoIdentityModeEnumValueOf(name);
}
