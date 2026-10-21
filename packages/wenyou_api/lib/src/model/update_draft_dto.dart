//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_draft_dto.g.dart';

/// UpdateDraftDto
///
/// Properties:
/// * [textFontVersion] - 1 支持字体 v1；2 支持 v1/v2 混合正文无损读写；新端始终发送，包括删除全部字体。新/原正文含字体未声明返回 409/40019；v1 新写受 textFontV1WriteEnabled 控制；v2 新写受 textFontV2WriteEnabled 与版本 pasteAllowed 控制。颜色组合还须 textColorVersion:1。
/// * [textColorVersion] - 支持文本颜色 v1 无损读写；新端始终发送，包括删除全部颜色。新/原正文含颜色未声明返回 409/40016；新写受 textColorV1WriteEnabled 控制。
/// * [markdownContractVersion] - 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
/// * [content] - 更新后的草稿正文
/// * [version] - 当前乐观锁版本
@BuiltValue()
abstract class UpdateDraftDto implements Built<UpdateDraftDto, UpdateDraftDtoBuilder> {
  /// 1 支持字体 v1；2 支持 v1/v2 混合正文无损读写；新端始终发送，包括删除全部字体。新/原正文含字体未声明返回 409/40019；v1 新写受 textFontV1WriteEnabled 控制；v2 新写受 textFontV2WriteEnabled 与版本 pasteAllowed 控制。颜色组合还须 textColorVersion:1。
  @BuiltValueField(wireName: r'textFontVersion')
  UpdateDraftDtoTextFontVersionEnum? get textFontVersion;
  // enum textFontVersionEnum {  1,  2,  };

  /// 支持文本颜色 v1 无损读写；新端始终发送，包括删除全部颜色。新/原正文含颜色未声明返回 409/40016；新写受 textColorV1WriteEnabled 控制。
  @BuiltValueField(wireName: r'textColorVersion')
  UpdateDraftDtoTextColorVersionEnum? get textColorVersion;
  // enum textColorVersionEnum {  1,  };

  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueField(wireName: r'markdownContractVersion')
  UpdateDraftDtoMarkdownContractVersionEnum? get markdownContractVersion;
  // enum markdownContractVersionEnum {  6,  };

  /// 更新后的草稿正文
  @BuiltValueField(wireName: r'content')
  String get content;

  /// 当前乐观锁版本
  @BuiltValueField(wireName: r'version')
  num get version;

  UpdateDraftDto._();

  factory UpdateDraftDto([void updates(UpdateDraftDtoBuilder b)]) = _$UpdateDraftDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateDraftDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateDraftDto> get serializer => _$UpdateDraftDtoSerializer();
}

class _$UpdateDraftDtoSerializer implements PrimitiveSerializer<UpdateDraftDto> {
  @override
  final Iterable<Type> types = const [UpdateDraftDto, _$UpdateDraftDto];

  @override
  final String wireName = r'UpdateDraftDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateDraftDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.textFontVersion != null) {
      yield r'textFontVersion';
      yield serializers.serialize(
        object.textFontVersion,
        specifiedType: const FullType(UpdateDraftDtoTextFontVersionEnum),
      );
    }
    if (object.textColorVersion != null) {
      yield r'textColorVersion';
      yield serializers.serialize(
        object.textColorVersion,
        specifiedType: const FullType(UpdateDraftDtoTextColorVersionEnum),
      );
    }
    if (object.markdownContractVersion != null) {
      yield r'markdownContractVersion';
      yield serializers.serialize(
        object.markdownContractVersion,
        specifiedType: const FullType(UpdateDraftDtoMarkdownContractVersionEnum),
      );
    }
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateDraftDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateDraftDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'textFontVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateDraftDtoTextFontVersionEnum),
          ) as UpdateDraftDtoTextFontVersionEnum;
          result.textFontVersion = valueDes;
          break;
        case r'textColorVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateDraftDtoTextColorVersionEnum),
          ) as UpdateDraftDtoTextColorVersionEnum;
          result.textColorVersion = valueDes;
          break;
        case r'markdownContractVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateDraftDtoMarkdownContractVersionEnum),
          ) as UpdateDraftDtoMarkdownContractVersionEnum;
          result.markdownContractVersion = valueDes;
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
  UpdateDraftDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateDraftDtoBuilder();
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

class UpdateDraftDtoTextFontVersionEnum extends EnumClass {

  /// 1 支持字体 v1；2 支持 v1/v2 混合正文无损读写；新端始终发送，包括删除全部字体。新/原正文含字体未声明返回 409/40019；v1 新写受 textFontV1WriteEnabled 控制；v2 新写受 textFontV2WriteEnabled 与版本 pasteAllowed 控制。颜色组合还须 textColorVersion:1。
  @BuiltValueEnumConst(wireNumber: 1)
  static const UpdateDraftDtoTextFontVersionEnum number1 = _$updateDraftDtoTextFontVersionEnum_number1;
  /// 1 支持字体 v1；2 支持 v1/v2 混合正文无损读写；新端始终发送，包括删除全部字体。新/原正文含字体未声明返回 409/40019；v1 新写受 textFontV1WriteEnabled 控制；v2 新写受 textFontV2WriteEnabled 与版本 pasteAllowed 控制。颜色组合还须 textColorVersion:1。
  @BuiltValueEnumConst(wireNumber: 2)
  static const UpdateDraftDtoTextFontVersionEnum number2 = _$updateDraftDtoTextFontVersionEnum_number2;
  /// 1 支持字体 v1；2 支持 v1/v2 混合正文无损读写；新端始终发送，包括删除全部字体。新/原正文含字体未声明返回 409/40019；v1 新写受 textFontV1WriteEnabled 控制；v2 新写受 textFontV2WriteEnabled 与版本 pasteAllowed 控制。颜色组合还须 textColorVersion:1。
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UpdateDraftDtoTextFontVersionEnum unknownDefaultOpenApi = _$updateDraftDtoTextFontVersionEnum_unknownDefaultOpenApi;

  static Serializer<UpdateDraftDtoTextFontVersionEnum> get serializer => _$updateDraftDtoTextFontVersionEnumSerializer;

  const UpdateDraftDtoTextFontVersionEnum._(String name): super(name);

  static BuiltSet<UpdateDraftDtoTextFontVersionEnum> get values => _$updateDraftDtoTextFontVersionEnumValues;
  static UpdateDraftDtoTextFontVersionEnum valueOf(String name) => _$updateDraftDtoTextFontVersionEnumValueOf(name);
}

class UpdateDraftDtoTextColorVersionEnum extends EnumClass {

  /// 支持文本颜色 v1 无损读写；新端始终发送，包括删除全部颜色。新/原正文含颜色未声明返回 409/40016；新写受 textColorV1WriteEnabled 控制。
  @BuiltValueEnumConst(wireNumber: 1)
  static const UpdateDraftDtoTextColorVersionEnum number1 = _$updateDraftDtoTextColorVersionEnum_number1;
  /// 支持文本颜色 v1 无损读写；新端始终发送，包括删除全部颜色。新/原正文含颜色未声明返回 409/40016；新写受 textColorV1WriteEnabled 控制。
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UpdateDraftDtoTextColorVersionEnum unknownDefaultOpenApi = _$updateDraftDtoTextColorVersionEnum_unknownDefaultOpenApi;

  static Serializer<UpdateDraftDtoTextColorVersionEnum> get serializer => _$updateDraftDtoTextColorVersionEnumSerializer;

  const UpdateDraftDtoTextColorVersionEnum._(String name): super(name);

  static BuiltSet<UpdateDraftDtoTextColorVersionEnum> get values => _$updateDraftDtoTextColorVersionEnumValues;
  static UpdateDraftDtoTextColorVersionEnum valueOf(String name) => _$updateDraftDtoTextColorVersionEnumValueOf(name);
}

class UpdateDraftDtoMarkdownContractVersionEnum extends EnumClass {

  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireNumber: 6)
  static const UpdateDraftDtoMarkdownContractVersionEnum number6 = _$updateDraftDtoMarkdownContractVersionEnum_number6;
  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UpdateDraftDtoMarkdownContractVersionEnum unknownDefaultOpenApi = _$updateDraftDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;

  static Serializer<UpdateDraftDtoMarkdownContractVersionEnum> get serializer => _$updateDraftDtoMarkdownContractVersionEnumSerializer;

  const UpdateDraftDtoMarkdownContractVersionEnum._(String name): super(name);

  static BuiltSet<UpdateDraftDtoMarkdownContractVersionEnum> get values => _$updateDraftDtoMarkdownContractVersionEnumValues;
  static UpdateDraftDtoMarkdownContractVersionEnum valueOf(String name) => _$updateDraftDtoMarkdownContractVersionEnumValueOf(name);
}
